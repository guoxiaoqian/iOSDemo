#ifndef wwdb_performance_hpp
#define wwdb_performance_hpp

#include "wwdb_core.hpp"
#include <map>
#include <memory>

namespace wwdb {
    
struct PerformanceRecord {
    std::string table;
    std::string sql;
    std::string tag;
    std::string version;
    uint64_t time;
    uint64_t cost;
    uint64_t affect;
    std::string hit_index;
    std::string error;
    bool reported;
    const StatementBase* statement;
};

struct PerformanceStatisticsItem {
    std::string table;
    std::string sql;
    uint64_t timestart;
    uint64_t count;
    uint64_t cost_avg;
    uint64_t cost_max;
    uint64_t cost_med;
    uint64_t cost_std;
    uint64_t affect_avg;
    uint64_t affect_max;
    uint64_t affect_med;
    uint64_t affect_std;
    std::string error;
};

}

namespace wwdb {

class PerformanceMonitor : public DataBaseExecutor {
public:
    class Hook : public HookBase {
    public:
        Hook(PerformanceMonitor* monitor, const std::string& version);
        virtual void beforeExecute(const StatementBase& statement) override;
        virtual void afterExecute(const StatementBase& statement) override;
        virtual void onError(int errorCode, const std::string errorMessage, const StatementBase* statement) override;
    private:
        void logSql(const wwdb::StatementBase &statement) const;
        std::map<const StatementBase*, std::unique_ptr<PerformanceRecord>> records_;
        PerformanceMonitor* monitor_;
        std::string version_;
    };
    
    class Analyser {
    public:
        static std::string hitIndex(const wwdb::StatementBase& statement);
        static std::string expandSql(const wwdb::StatementBase& statement);
    };
    
    PerformanceMonitor(const std::string& dbpath, const std::string& version);
    bool available();
    Hook* spawnHook();

    bool retrieveAndMarkRecords(uint64_t time, std::vector<PerformanceRecord>& outrecords);
    
    // This static method should be called on a background thread.
    static std::vector<PerformanceStatisticsItem> computeStatistics(const std::vector<PerformanceRecord>& records, const std::function<uint64_t(uint64_t)>& classifier);
    // This static method has no default implementation. You should implement this method if a global monitor is used.
    static PerformanceMonitor* globalMonitor();
protected:
    // Must override these following methods when use in multithreading environment.
    virtual void lock();
    virtual void unlock();
    // Override this to obtain records. Be sure call super's implementation.
    virtual void appendRecordQueue(std::unique_ptr<PerformanceRecord>&& record);
    // Override this to do batch commits.
    virtual void commitRecordQueue();
    virtual DataBase* statementDB() override;
private:
    bool removeObsoleteRecords();
    std::unique_ptr<DataBase> db_;
    std::string version_;
    std::vector<std::unique_ptr<PerformanceRecord>> records_;
    int insertCount_ = -1;
};

}

#endif /* wwdb_performance_hpp */
