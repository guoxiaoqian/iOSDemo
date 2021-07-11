#include "wwdb_performance.hpp"
#include "wwdb_meta.hpp"
#include "math.h"

using namespace wwdb;

WWDB_TABLE(PerformanceRecord)
WWDB_PROPERTY(table, sql, tag, version, time, cost, affect, hit_index, error)
WWDB_COLUMN(reported, DEFAULT(false))
WWDB_END

static bool compress_in_expr(std::string& sql) {
    bool result = false;
    std::string::size_type start = 0;
    do {
        start = sql.find("IN (?", start);
        if (start == std::string::npos) break;
        
        if (sql.length() < start + 4) break;
        start += 4;
        if (sql[start] == 'S') continue; // SELECT subquery
        
        std::string::size_type end = sql.find(")", start);
        if (end == std::string::npos) break;
        
        sql[start] = '?';
        sql.erase(start + 1, end - start - 1);
        start += 1;
        result = true;
    } while(true);
    return result;
}

static bool compress_batch_insert(std::string& sql) {
    bool result = false;
    do {
        std::string::size_type check = sql.find("INSERT ", 0);
        if (check != 0) break;
        
        std::string::size_type start = sql.find("VALUES (", 0);
        if (start == std::string::npos) break;
        start += 8;
        
        std::string::size_type end = sql.find(")", start);
        if (end == std::string::npos) break;
        if (sql.length() <= end + 1) break;
        
        sql.erase(end + 1, sql.length() - end - 1);
        result = true;
    } while(false);
    return result;
}

static bool clip_long_expr(std::string& sql) {
    if (sql.length() > 2000) {
        sql = sql.substr(0, 2000);
        return true;
    }
    return false;
}

// ======== Hook ========

PerformanceMonitor::Hook::Hook(PerformanceMonitor* monitor, const std::string& version)
    : monitor_(monitor), version_(version) {
    ;
}

void PerformanceMonitor::Hook::beforeExecute(const wwdb::StatementBase &statement) {
    std::unique_ptr<PerformanceRecord> record(new PerformanceRecord);
    record->statement = &statement;
    record->time = WWDB_TIME_NOW_US;
    record->cost = WWDB_TIME_STEADY_US;
    records_[&statement] = std::move(record);
}

void PerformanceMonitor::Hook::afterExecute(const wwdb::StatementBase &statement) {
#ifdef DEBUG
    logSql(statement);
#endif
    auto now = WWDB_TIME_STEADY_US;
    auto iter = records_.find(&statement);
    if (iter != records_.end()) {
        auto& record = iter->second;
        record->table = statement.table() ? statement.table()->tableName() : "";
        record->sql = statement.sql();
        record->version = version_;
        record->tag = statement.cacheable() ? "cached" : "unique";
        record->affect = statement.changes();
        record->hit_index = "";//Analyser::hitIndex(statement);
        record->cost = now - record->cost;
        record->reported = false;
        if (!record->error.empty()) {
            WWDB_LOG_ERROR << "[WWDB] SQL error: " << record->error << ", statement: " << record->sql;
        }
        compress_batch_insert(record->sql);
        compress_in_expr(record->sql);
        clip_long_expr(record->sql);
        monitor_->appendRecordQueue(std::move(record));
        records_.erase(iter);
    }
}

void PerformanceMonitor::Hook::onError(int errorCode, const std::string errorMessage, const StatementBase* statement) {
    if (statement) {
        auto iter = records_.find(statement);
        if (iter != records_.end()) {
            auto& record = iter->second;
            record->error = errorMessage;
        }
    } else {
        WWDB_LOG_ERROR << "[WWDB] Logic error: " << errorMessage;
    }
}

void PerformanceMonitor::Hook::logSql(const wwdb::StatementBase &statement) const {
    WWDB_LOG_INFO << "SQL will execute \"" << statement.sql() << "\"";
    WWDB_LOG_INFO << "(ExpandBindList) \"" << Analyser::expandSql(statement) << "\"";
}

std::string PerformanceMonitor::Analyser::hitIndex(const wwdb::StatementBase &statement) {
    std::string uppersql = statement.sql();
    std::transform(uppersql.begin(), uppersql.end(), uppersql.begin(), ::toupper);
    if (uppersql.find("SELECT ") == 0 || uppersql.find("INSERT ") == 0 || uppersql.find("UPDATE ") == 0 || uppersql.find("DELETE ") == 0) {
        std::string explain("EXPLAIN QUERY PLAN ");
        explain.append(statement.sql());
        std::replace(explain.begin(), explain.end(), '?', '0');
        
        auto result = statement.database().select<query_plan>(explain).one();
        if (result) {
            std::string::size_type pos = result->detail.find("USING ");
            if (pos == std::string::npos) {
                return "NONE";
            } else {
                return result->detail.substr(pos + 6);
            }
        }
    }
    return "";
}

std::string PerformanceMonitor::Analyser::expandSql(const wwdb::StatementBase &statement) {
    std::string sql = statement.sql();
    if (sql.find("INSERT ") == 0) {
        return sql;
    }
    std::string expanded;
    size_t bind_index = 0;
    for (auto iter = sql.begin(); iter != sql.end(); ++iter) {
        if (*iter == '?') {
            if (bind_index < statement.bindList().size()) {
#ifdef DEBUG
                expanded.append(statement.bindList()[bind_index++].description());
#else
                expanded.append("?");
#endif
            } else {
                expanded.append("'[ERROR:out of bind range]'");
            }
        } else {
            expanded.push_back(*iter);
        }
    }
    return expanded;
}

// ======== PerformanceMonitor ========

PerformanceMonitor::PerformanceMonitor(const std::string& dbpath, const std::string& version) : db_(DataBase::Open(dbpath)), DataBaseExecutor(nullptr), version_(version) {
    if (db_) {
        db_->ignoreGlobalHooks(true);
    } else {
        WWDB_LOG_ERROR << "wwdb performance db open failed";
    }
}

bool PerformanceMonitor::available() {
    return db_.get() != nullptr;
}

PerformanceMonitor::Hook* PerformanceMonitor::spawnHook() {
    if (available()) {
        return new Hook(this, version_);
    }
    return nullptr;
}

void PerformanceMonitor::appendRecordQueue(std::unique_ptr<PerformanceRecord>&& record) {
    if (available()) {
        lock();
        records_.push_back(std::move(record));
        unlock();
        commitRecordQueue();
    }
}

void PerformanceMonitor::commitRecordQueue() {
    if (available()) {
        decltype(records_) local_records;
        lock();
        records_.swap(local_records);
        unlock();
        size_t count = local_records.size();
        
        db_->beginTransaction();
        insert<PerformanceRecord>(std::move(local_records));
        db_->commitTransaction();
        
        // Remove obsolete records on first insertion and every 1000 insertions
        if (insertCount_ == -1 || insertCount_ > 1000) {
            if (removeObsoleteRecords()) {
                insertCount_ = 0;
            } else {
                insertCount_ += count;
            }
        }
    }
}

void PerformanceMonitor::lock() {
    ;
}

void PerformanceMonitor::unlock() {
    ;
}

bool PerformanceMonitor::retrieveAndMarkRecords(uint64_t maxtime, std::vector<PerformanceRecord>& outrecords) {
    if (available()) {
        size_t orig_size = outrecords.size();
        auto& _ = db_->cols<PerformanceRecord>();
        select<PerformanceRecord>(_.reported == 0 && _.time < maxtime).all(outrecords);
        update<PerformanceRecord>(_.reported == false && _.time < maxtime).set(_.reported = true);
        return outrecords.size() > orig_size;
    }
    return false;
}

template<class T>
static T calc_medium_helper(std::vector<T>& vec) {
    if (vec.empty()) {
        return 0;
    } else if (vec.size() % 2 == 0) {
        // even
        size_t l_pos = vec.size() / 2;
        size_t r_pos = vec.size() / 2 - 1;
        std::nth_element(vec.begin(), vec.begin() + r_pos, vec.end());
        T r = vec[r_pos];
        std::nth_element(vec.begin(), vec.begin() + l_pos, vec.begin() + r_pos);
        T l = vec[l_pos];
        return (l + r) / 2;
    } else {
        // odd
        size_t pos = (vec.size() - 1) / 2;
        std::nth_element(vec.begin(), vec.begin() + pos, vec.end());
        return vec[pos];
    }
}

std::vector<PerformanceStatisticsItem> PerformanceMonitor::computeStatistics(const std::vector<PerformanceRecord>& records, const std::function<uint64_t(uint64_t)>& classifier) {
    std::map<std::pair<uint64_t, std::string>, std::vector<const PerformanceRecord*>> clusters;
    for (auto& record : records) {
        clusters[std::make_pair(classifier(record.time), record.sql)].push_back(&record);
    }
    
    std::vector<PerformanceStatisticsItem> result;
    for (auto& cluster : clusters) {
        result.push_back(PerformanceStatisticsItem());
        auto& item = result.back();
        item.table = cluster.second.empty() ? "" : cluster.second.front()->table;
        item.sql = cluster.first.second;
        item.timestart = cluster.first.first;
        item.count = cluster.second.size();
        item.cost_max = 0;
        item.affect_max = 0;
        
        uint64_t cost_sum = 0, affect_sum = 0;
        std::vector<uint64_t> cost_vec, affect_vec;
        std::set<std::string> error_set;
        cost_vec.reserve(cluster.second.size());
        affect_vec.reserve(cluster.second.size());
        
        for (auto& record : cluster.second) {
            cost_sum += record->cost;
            if (item.cost_max < record->cost) item.cost_max = record->cost;
            cost_vec.push_back(record->cost);
            
            affect_sum += record->affect;
            if (item.affect_max < record->affect) item.affect_max = record->affect;
            affect_vec.push_back(record->affect);
            
            if (!record->error.empty()) error_set.insert(record->error);
        }
        
        item.cost_avg = cost_sum / item.count;
        item.affect_avg = affect_sum / item.count;
        item.cost_med = calc_medium_helper(cost_vec);
        item.affect_med = calc_medium_helper(affect_vec);
        
        if (!error_set.empty()) {
            for (auto& err : error_set) {
                if (!item.error.empty()) {
                    item.error = item.error.append(";");
                }
                item.error = item.error.append(err);
            }
        }
        
        uint64_t cost_var = 0, affect_var = 0;
        for (auto& record : cluster.second) {
            int64_t cost_delta = (int64_t)item.cost_avg - record->cost;
            cost_var += cost_delta * cost_delta;

            int64_t affect_delta = (int64_t)item.affect_avg - record->affect;
            affect_var += affect_delta * affect_delta;
        }

        item.cost_std = static_cast<uint64_t>(sqrt(cost_var / cluster.second.size()));
        item.affect_std = static_cast<uint64_t>(sqrt(affect_var / cluster.second.size()));
    }
    
    return result;
}

bool PerformanceMonitor::removeObsoleteRecords() {
    if (available()) {
        constexpr uint64_t MOST_KEEP_RECORDS = 20000;
        size_t count = select<PerformanceRecord>().count();
        if (count > MOST_KEEP_RECORDS) {
            WWDB_LOG_WARN << "remove " << count - MOST_KEEP_RECORDS << " obsolete records.";
            auto rowid = VirtualColumn<PerformanceRecord, int64_t>("rowid");
            auto& _ = db_->cols<PerformanceRecord>();
            Subquery query = select<PerformanceRecord>(rowid).orderBy(_.time.asc()).limit((int)(count - MOST_KEEP_RECORDS));
            delete_<PerformanceRecord>(rowid.in(query));
            return true;
        }
    }
    return false;
}

wwdb::DataBase* PerformanceMonitor::statementDB() {
    return db_.get();
}
