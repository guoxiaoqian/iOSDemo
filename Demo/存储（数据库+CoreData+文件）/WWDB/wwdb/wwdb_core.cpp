#include "wwdb_core.hpp"
#include "wwdb_meta.hpp"

using namespace wwdb;
static std::mutex GlobalHook_mutex;
static thread_local bool current_in_runner = false;

// ======== STATEMENT HANDLE ========

class wwdb::StatementHandle {
public:
    StatementHandle(DataBase& database, const std::string& sql) {
        ret_ = sqlite3_prepare_v2(database.connection(), sql.data(), -1, &stmt_, nullptr);
        if (ret_ != SQLITE_OK && stmt_) {
            sqlite3_finalize(stmt_);
            stmt_ = nullptr;
        }
    }
    ~StatementHandle() {
        if (stmt_) {
            sqlite3_finalize(stmt_);
        }
    }
    void reset() { if (stmt_) sqlite3_reset(stmt_); }
    sqlite3_stmt* stmt() { return stmt_; }
    int ret() { return ret_; };
private:
    sqlite3_stmt* stmt_ = nullptr;
    int ret_ = SQLITE_OK;
};

// ======== BINDER ========

#ifdef DEBUG
Binder::Binder(const std::function<void(StatementBase&, int)>& functor, const std::string& description) : std::function<void(StatementBase&, int)>(functor), description_(description) {
    
}

std::string Binder::description() const {
    return description_;
}
#endif

std::string wwdb::fillArgument(const bool& v) {
    return v ? "1" : "0";
}

std::string wwdb::fillArgument(const int32_t& v) {
    return to_string(v);
}

std::string wwdb::fillArgument(const uint32_t& v) {
    return to_string(v);
}

std::string wwdb::fillArgument(const int64_t& v) {
    return to_string(v);
}

std::string wwdb::fillArgument(const uint64_t& v) {
    return to_string(v);
}

std::string wwdb::fillArgument(const double& v) {
    return to_string(v);
}

std::string wwdb::fillArgument(const std::string& v) {
    char* ptr = sqlite3_mprintf("%Q", v.c_str());
    std::string result(ptr);
    sqlite3_free(ptr);
    return result;
}

#ifdef DEBUG
#define IMPLEMENT_BIND_ARGUMENT(type, func) \
Binder wwdb::bindArgument(const type& v, bool copy, const ColumnDefinition* c) { \
    if (copy || c->isDynamicValue() || c->isDanglingColumn()) { \
        return Binder([=](StatementBase& s, int col) { \
            func(s.handle()->stmt(), col + 1, v); \
        }, fillArgument(v)); \
    } else { \
        return Binder([=, &v](StatementBase& s, int col) { \
            func(s.handle()->stmt(), col + 1, v); \
        }, fillArgument(v)); \
    } \
}

Binder wwdb::bindArgument(const std::string& v, bool copy, const ColumnDefinition* c) {
    bool isBlob = c && c->isBlob();
    if (copy || (c && (c->isDynamicValue() || c->isDanglingColumn()))) {
        return Binder([=](StatementBase& s, int col) {
            if (isBlob) {
                sqlite3_bind_blob(s.handle()->stmt(), col + 1, v.data(), (int)v.size(), SQLITE_TRANSIENT);
            } else {
                sqlite3_bind_text(s.handle()->stmt(), col + 1, v.data(), (int)v.size(), SQLITE_TRANSIENT);
            }
        }, fillArgument(v));
    } else {
        return Binder([=, &v](StatementBase& s, int col) {
            if (isBlob) {
                sqlite3_bind_blob(s.handle()->stmt(), col + 1, v.data(), (int)v.size(), SQLITE_TRANSIENT);
            } else {
                sqlite3_bind_text(s.handle()->stmt(), col + 1, v.data(), (int)v.size(), SQLITE_TRANSIENT);
            }
        }, fillArgument(v));
    }
}
#else
#define IMPLEMENT_BIND_ARGUMENT(type, func) \
Binder wwdb::bindArgument(const type& v, bool copy, const ColumnDefinition* c) { \
    if (copy || c->isDynamicValue() || c->isDanglingColumn()) { \
        return [=](StatementBase& s, int col) { \
            func(s.handle()->stmt(), col + 1, v); \
        }; \
    } else { \
        return [=, &v](StatementBase& s, int col) { \
            func(s.handle()->stmt(), col + 1, v); \
        }; \
    } \
}

Binder wwdb::bindArgument(const std::string& v, bool copy, const ColumnDefinition* c) {
    bool isBlob = c && c->isBlob();
    if (copy || (c && (c->isDynamicValue() || c->isDanglingColumn()))) {
        return [=](StatementBase& s, int col) {
            if (isBlob) {
                sqlite3_bind_blob(s.handle()->stmt(), col + 1, v.data(), (int)v.size(), SQLITE_TRANSIENT);
            } else {
                sqlite3_bind_text(s.handle()->stmt(), col + 1, v.data(), (int)v.size(), SQLITE_TRANSIENT);
            }
        };
    } else {
        return [=, &v](StatementBase& s, int col) {
            if (isBlob) {
                sqlite3_bind_blob(s.handle()->stmt(), col + 1, v.data(), (int)v.size(), SQLITE_TRANSIENT);
            } else {
                sqlite3_bind_text(s.handle()->stmt(), col + 1, v.data(), (int)v.size(), SQLITE_TRANSIENT);
            }
        };
    }
}
#endif

IMPLEMENT_BIND_ARGUMENT(bool, sqlite3_bind_int)
IMPLEMENT_BIND_ARGUMENT(int32_t, sqlite3_bind_int)
IMPLEMENT_BIND_ARGUMENT(uint32_t, sqlite3_bind_int64)
IMPLEMENT_BIND_ARGUMENT(int64_t, sqlite3_bind_int64)
IMPLEMENT_BIND_ARGUMENT(uint64_t, sqlite3_bind_int64)
IMPLEMENT_BIND_ARGUMENT(double, sqlite3_bind_double)

bool wwdb::retrieveArgument(StatementBase& s, int col, bool* dummy, const ColumnDefinition* c) {
    return !!sqlite3_column_int(s.handle()->stmt(), col);
}

int32_t wwdb::retrieveArgument(StatementBase& s, int col, int32_t* dummy, const ColumnDefinition* c) {
    return sqlite3_column_int(s.handle()->stmt(), col);
}

uint32_t wwdb::retrieveArgument(StatementBase& s,int col, uint32_t* dummy, const ColumnDefinition* c) {
    return sqlite3_column_int(s.handle()->stmt(), col);
}

int64_t wwdb::retrieveArgument(StatementBase& s,int col, int64_t* dummy, const ColumnDefinition* c) {
    return sqlite3_column_int64(s.handle()->stmt(), col);
}

uint64_t wwdb::retrieveArgument(StatementBase& s, int col, uint64_t* dummy, const ColumnDefinition* c) {
    return sqlite3_column_int64(s.handle()->stmt(), col);
}

double wwdb::retrieveArgument(StatementBase& s, int col, double* dummy, const ColumnDefinition* c) {
    return sqlite3_column_double(s.handle()->stmt(), col);
}

std::string wwdb::retrieveArgument(StatementBase& s, int col, std::string* dummy, const ColumnDefinition* c) {
    const char* str = nullptr;
    if (c && c->isBlob()) {
        str = reinterpret_cast<const char*>(sqlite3_column_blob(s.handle()->stmt(), col));
    } else {
        str = reinterpret_cast<const char*>(sqlite3_column_text(s.handle()->stmt(), col));
    }
    int len = sqlite3_column_bytes(s.handle()->stmt(), col);
    if (str && len > 0) {
        return std::string(str, len);
    }
    return std::string();
}

std::string wwdb::fragmentType(const bool* dummy) {
    return "BOOLEAN";
}

std::string wwdb::fragmentType(const int32_t* dummy) {
    return "INTEGER";
}

std::string wwdb::fragmentType(const uint32_t* dummy) {
    return "INTEGER";
}

std::string wwdb::fragmentType(const int64_t* dummy) {
    return "INTEGER";
}

std::string wwdb::fragmentType(const uint64_t* dummy) {
    return "INTEGER";
}

std::string wwdb::fragmentType(const double* dummy) {
    return "DOUBLE";
}

std::string wwdb::fragmentType(const std::string* dummy) {
    return "TEXT";
}

std::string wwdb::quote(const std::string& identifier) {
    static std::set<std::string> keywordSet = { "ABORT", "ACTION", "ADD", "AFTER", "ALL", "ALTER", "ANALYZE", "AND", "AS", "ASC", "ATTACH", "AUTOINCREMENT", "BEFORE", "BEGIN", "BETWEEN", "BY", "CASCADE", "CASE", "CAST", "CHECK", "COLLATE", "COLUMN", "COMMIT", "CONFLICT", "CONSTRAINT", "CREATE", "CROSS", "CURRENT_DATE", "CURRENT_TIME", "CURRENT_TIMESTAMP", "DATABASE", "DEFAULT", "DEFERRABLE", "DEFERRED", "DELETE", "DESC", "DETACH", "DISTINCT", "DROP", "EACH", "ELSE", "END", "ESCAPE", "EXCEPT", "EXCLUSIVE", "EXISTS", "EXPLAIN", "FAIL", "FOR", "FOREIGN", "FROM", "FULL", "GLOB", "GROUP", "HAVING", "IF", "IGNORE", "IMMEDIATE", "IN", "INDEX", "INDEXED", "INITIALLY", "INNER", "INSERT", "INSTEAD", "INTERSECT", "INTO", "IS", "ISNULL", "JOIN", "KEY", "LEFT", "LIKE", "LIMIT", "MATCH", "NATURAL", "NO", "NOT", "NOTNULL", "NULL", "OF", "OFFSET", "ON", "OR", "ORDER", "OUTER", "PLAN", "PRAGMA", "PRIMARY", "QUERY", "RAISE", "RECURSIVE", "REFERENCES", "REGEXP", "REINDEX", "RELEASE", "RENAME", "REPLACE", "RESTRICT", "RIGHT", "ROLLBACK", "ROW", "SAVEPOINT", "SELECT", "SET", "TABLE", "TEMP", "TEMPORARY", "THEN", "TO", "TRANSACTION", "TRIGGER", "UNION", "UNIQUE", "UPDATE", "USING", "VACUUM", "VALUES", "VIEW", "VIRTUAL", "WHEN", "WHERE", "WITH", "WITHOUT" };
    if (keywordSet.find(to_upper(identifier)) != keywordSet.end()) {
        return std::string("\"").append(identifier).append("\"");
    }
    return identifier;
}

std::string wwdb::escapelike(const std::string& text) {
    const std::string escape_char = "\\";
    std::string result = text;
    auto escape = [&](const std::string& keyword) {
        std::string::size_type start = 0;
        do {
            std::string::size_type pos = result.find(keyword, start);
            if (pos != std::string::npos) {
                result.replace(pos, 0, escape_char);
                start += keyword.length() + escape_char.length();
                continue;
            }
            break;
        } while (true);
    };
    escape(escape_char);
    escape("%");
    escape("_");
    return result;
}

class Appender {
public:
    Appender(std::string& output, const std::string& sep = ", ") : output_(output), sep_(sep) {
        ;
    }
    void operator()(const std::string& content) {
        if (first_) {
            first_ = false;
        } else {
            output_.append(sep_);
        }
        output_.append(content);
    }
    void operator()(const std::vector<std::string>& contents) {
        for (auto& content : contents) {
            operator()(content);
        }
    }
    operator bool() const {
        return first_ == false;
    }
private:
    std::string& output_;
    std::string sep_;
    bool first_ = true;
};

// ======== Custom Functions ========

static void uint64GreaterThan(sqlite3_context* ctx, int nargs, sqlite3_value** values) {
    uint64_t value1 = static_cast<uint64_t>(sqlite3_value_int64(values[0]));
    uint64_t value2 = static_cast<uint64_t>(sqlite3_value_int64(values[1]));
    sqlite3_result_int(ctx, value1 > value2);
}

static void uint64LessThan(sqlite3_context* ctx, int nargs, sqlite3_value** values) {
    uint64_t value1 = static_cast<uint64_t>(sqlite3_value_int64(values[0]));
    uint64_t value2 = static_cast<uint64_t>(sqlite3_value_int64(values[1]));
    sqlite3_result_int(ctx, value1 < value2);
}

static void uint64GreaterThanOrEqual(sqlite3_context* ctx, int nargs, sqlite3_value** values) {
    uint64_t value1 = static_cast<uint64_t>(sqlite3_value_int64(values[0]));
    uint64_t value2 = static_cast<uint64_t>(sqlite3_value_int64(values[1]));
    sqlite3_result_int(ctx, value1 >= value2);
}

static void uint64LessThanOrEqual(sqlite3_context* ctx, int nargs, sqlite3_value** values) {
    uint64_t value1 = static_cast<uint64_t>(sqlite3_value_int64(values[0]));
    uint64_t value2 = static_cast<uint64_t>(sqlite3_value_int64(values[1]));
    sqlite3_result_int(ctx, value1 <= value2);
}

static void registerCustomFunctions(sqlite3* sqlite3) {
#if WWDB_UINT64_CUSTOM_FUNCTIONS
    sqlite3_create_function(sqlite3, "UINT64_GT", 2, SQLITE_ANY, NULL, &uint64GreaterThan, NULL, NULL);
    sqlite3_create_function(sqlite3, "UINT64_LT", 2, SQLITE_ANY, NULL, &uint64LessThan, NULL, NULL);
    sqlite3_create_function(sqlite3, "UINT64_GTEQ", 2, SQLITE_ANY, NULL, &uint64GreaterThanOrEqual, NULL, NULL);
    sqlite3_create_function(sqlite3, "UINT64_LTEQ", 2, SQLITE_ANY, NULL, &uint64LessThanOrEqual, NULL, NULL);
#endif
}

static void pragmaConfig(sqlite3* sqlite3) {
    sqlite3_exec(sqlite3, "PRAGMA locking_mode = EXCLUSIVE", NULL, NULL, NULL);
}
// ======== SQL BASE ========

SqlBase::SqlBase() { }

SqlBase::~SqlBase() { }

size_t SqlBase::bindStatement(StatementBase& s) const {
    for (size_t i = 0; i < bind_list_.size(); ++i) {
        bind_list_[i](s, i);
    }
    return bind_list_.size();
}

bool SqlBase::moveNext() {
    return false;
}

size_t SqlBase::bindCount() const {
    return 1;
}

// ======== PREDICATE ========

Predicate::Predicate() { }

Predicate::Predicate(const ColumnBase& column, const std::string& suffix)
: Predicate(column, "", suffix) {
}

Predicate::Predicate(const ColumnBase& column, const std::string& prefix, const std::string& suffix) {
    if (!prefix.empty()) {
        if (!suffix.empty()) {
            expression_ = prefix + " " + column.quoted_column_name() + " " + suffix;
        } else {
            expression_ = prefix + " " + column.quoted_column_name();
        }
    } else {
        if (!suffix.empty()) {
            expression_ = column.quoted_column_name() + " " + suffix;
        } else {
            expression_ = column.quoted_column_name();
        }
    }
    if (!column.bindList().empty()) for (auto& binder : column.bindList()) bind_list_.push_back(binder);
}

Predicate::Predicate(const ColumnBase& column, const std::string& suffix, const Binder& binder)
: Predicate(column, "", suffix, binder) {
    ;
}

Predicate::Predicate(const ColumnBase& column, const std::string& prefix, const std::string& suffix, const Binder& binder)
: Predicate(column, prefix, suffix) {
    bind_list_.push_back(binder);
}

Predicate::Predicate(const ColumnBase& column, const std::string& suffix, const Binder& binder1, const Binder& binder2)
: Predicate(column, "", suffix, binder1, binder2) {
    ;
}

Predicate::Predicate(const ColumnBase& column, const std::string& prefix, const std::string& suffix, const Binder& binder1, const Binder& binder2)
: Predicate(column, prefix, suffix) {
    bind_list_.push_back(binder1);
    bind_list_.push_back(binder2);
}

Predicate Predicate::operator!() const {
    Predicate new_predicate;
    new_predicate.expression_ = std::string("NOT ") + toParenthesisString();
    new_predicate.bind_list_ = bind_list_;
    new_predicate.cacheable_ = cacheable_;
    new_predicate.is_compound_ = true;
    return new_predicate;
}

Predicate Predicate::operator&&(const Predicate &other) const {
    Predicate new_predicate;
    new_predicate.expression_ = toParenthesisString() + " AND " + other.toParenthesisString();
    new_predicate.bind_list_ = bind_list_;
    new_predicate.bind_list_.insert(new_predicate.bind_list_.end(), other.bind_list_.begin(), other.bind_list_.end());
    new_predicate.cacheable_ = cacheable_ && other.cacheable_;
    new_predicate.is_compound_ = true;
    return new_predicate;
}

Predicate Predicate::operator||(const Predicate &other) const {
    Predicate new_predicate;
    new_predicate.expression_ = toParenthesisString() + " OR " + other.toParenthesisString();
    new_predicate.bind_list_ = bind_list_;
    new_predicate.bind_list_.insert(new_predicate.bind_list_.end(), other.bind_list_.begin(), other.bind_list_.end());
    new_predicate.cacheable_ = cacheable_ && other.cacheable_;
    new_predicate.is_compound_ = true;
    return new_predicate;
}

std::string Predicate::toString() const {
    return expression_;
}

std::string Predicate::toParenthesisString() const {
    if (is_compound_) {
        return std::string("(").append(expression_).append(")");
    } else {
        return toString();
    }
}

bool Predicate::cacheable() const {
    return cacheable_;
}

SetExpr::SetExpr(const ColumnBase& column, const Binder& binder) {
    expression_ = quote(column.column_name());
    bind_list_.push_back(binder);
}

Subquery::Subquery(const std::string& sql, const std::vector<Binder>& binders) {
    expression_ = sql;
    bind_list_ = binders;
}

Subquery Subquery::union_(const Subquery& other) {
    std::vector<Binder> list = bindList();
    list.insert(list.end(), other.bindList().begin(), other.bindList().end());
    return Subquery(std::string("SELECT * FROM (").append(expression()).append(") UNION SELECT * FROM (").append(other.expression()).append(")"), list);
}

Subquery Subquery::except(const Subquery& other) {
    std::vector<Binder> list = bindList();
    list.insert(list.end(), other.bindList().begin(), other.bindList().end());
    return Subquery(std::string("SELECT * FROM (").append(expression()).append(") EXCEPT SELECT * FROM (").append(other.expression()).append(")"), list);
}

// ======== EXECUTOR ========

DataBaseExecutor::DataBaseExecutor(DataBase* database) : statement_db_(database) {
    ;
}

DataBaseExecutor::~DataBaseExecutor() {
    ;
}

DataBase* DataBaseExecutor::statementDB() {
    return statement_db_;
}

#ifdef WWDB_ENABLE_KVTABLE
std::string DataBaseExecutor::getkv(const std::string& key, const std::string& default_value) {
    return statementDB()->getKeyValue(key, default_value);
}

void DataBaseExecutor::setkv(const std::string& key, const std::string& value) {
    statementDB()->setKeyValue(key, value);
}

#if WWDB_ASYNC
Promise<std::string> DataBaseExecutor::async_getkv(const std::string& key, const std::string& default_value) {
    return statementDB()->getKeyValueAsync(key, default_value);
}
#endif
#endif

// ======== DATABASE ========

DataBase::DataBase(sqlite3* connection, bool connection_owner) : connection_(connection), connection_owner_(connection_owner) {
    ;
}

DataBase::~DataBase() {
    statement_cache_.clear();
    if (connection_owner_ && connection_) {
        sqlite3_close(connection_);
    }
}

sqlite3* DataBase::JustOpen(const std::string& db_path, const std::string& password) {
    sqlite3* connection = nullptr;
    int err = sqlite3_open_v2(db_path.c_str(), &connection, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | WWDB_OPEN_EXTRA_FLAG, nullptr);
#if WWDB_HAS_SQLITE_KEY_FUNC
	if (err == SQLITE_OK && !password.empty()) {
		err = sqlite3_key(connection, password.c_str(), password.length());
	}
#endif
    if (err == SQLITE_OK) {
        return connection;
    } else {
        if (connection) {
            sqlite3_close(connection);
        }
        return nullptr;
    }
}

void DataBase::onOpen() {
    pragmaConfig(connection_);
    registerCustomFunctions(connection_);
}

DataBase* DataBase::statementDB() {
    return this;
}

std::unique_ptr<DataBase::Transaction> DataBase::transaction(DataBase::Transaction::DefaultAction action) {
    return std::unique_ptr<DataBase::Transaction>(new Transaction(this, action));
}

void DataBase::runInTransaction(const std::function<void(DataBase& db)>& callback) {
    auto scoped_transaction = transaction();
    callback(*this);
}

void DataBase::beginTransaction() {
#if WWDB_ASYNC
    if (shouldPostTaskRunner()) {
        runTask([=](const ReplyRunner& replyRunner){
            beginTransactionImpl();
        });
        return;
    }
#endif
    beginTransactionImpl();
}

bool DataBase::beginTransactionImpl() {
    if (transaction_nesting_ == 0) {
        transaction_force_rollback_ = false;
        bool ret = execute("BEGIN TRANSACTION");
        if (ret) {
            ++transaction_nesting_;
        } else {
            return false;
        }
    }
    return true;
}

void DataBase::commitTransaction() {
#if WWDB_ASYNC
    if (shouldPostTaskRunner()) {
        runTask([=](const ReplyRunner& replyRunner){
            commitTransactionImpl();
        });
        return;
    }
#endif
    commitTransactionImpl();
}

bool DataBase::commitTransactionImpl() {
    if (transaction_force_rollback_) {
        return rollbackTransactionImpl();
    } else if (transaction_nesting_ == 1) {
        bool ret = execute("COMMIT");
        if (ret) {
            --transaction_nesting_;
        } else {
            return false;
        }
    }
    return true;
}

void DataBase::rollbackTransaction() {
#if WWDB_ASYNC
    if (shouldPostTaskRunner()) {
        runTask([=](const ReplyRunner& replyRunner){
            rollbackTransactionImpl();
        });
        return;
    }
#endif
    rollbackTransactionImpl();
}

bool DataBase::rollbackTransactionImpl() {
    if (transaction_nesting_ == 1) {
        bool ret = execute("ROLLBACK");
        if (ret) {
            --transaction_nesting_;
        } else {
            return false;
        }
    } else {
        transaction_force_rollback_ = true;
    }
    return true;
}

bool DataBase::doesTableExist(const std::string& table_name) {
    auto& _ = table<sqlite_master>().placeholder();
    auto table = select<sqlite_master>(_.type == "table" && _.name == table_name).one();
    return !!table;
}

bool DataBase::doesIndexExist(const std::string& index_name) {
    auto& _ = table<sqlite_master>().placeholder();
    auto table = select<sqlite_master>(_.type == "index" && _.name == index_name).one();
    return !!table;
}

bool DataBase::doesColumnExist(const std::string& table_name, const std::string& column_name) {
    std::string sql = std::string("PRAGMA TABLE_INFO(").append(table_name).append(")");
    for (auto& one : select<table_info>(sql).all()) {
        if (one->name == column_name) return true;
    }
    return false;
}

std::vector<std::string> DataBase::existingColumns(const std::string& table_name) {
    std::string sql = std::string("PRAGMA TABLE_INFO(").append(table_name).append(")");
    return select<table_info>(sql).WWDB_MAP(cols<table_info>(), name);
}

std::vector<std::string> DataBase::existingIndexes(const std::string& table_name) {
    auto& _ = table<sqlite_master>().placeholder();
    auto result = _.name.self();
    select<sqlite_master>(result).where(_.type == "index" &&  _.tbl_name == table_name).all();
    return result.rows;
}

bool DataBase::vacuum() {
    return execute("VACCUM");
}

typed_key_map<std::map<std::string, DataBase::AlterHandler>>& DataBase::alterHandlers() {
    return alter_handlers_;
}

#if WWDB_ASYNC
bool DataBase::hasTaskRunner() {
    return !!task_runner_;
}

bool DataBase::shouldPostTaskRunner() {
    return !!task_runner_ && !current_in_runner;
}

void DataBase::setTaskRunner(const TaskRunner& runner) {
    task_runner_ = runner;
}

void DataBase::runTask(const std::function<void(const ReplyRunner& replyRunner)>& task) {
    task_runner_([=](const ReplyRunner& replyRunner){
        current_in_runner = true;
        task(replyRunner);
        current_in_runner = false;
    });
}
#endif

// KVTable Feature

#ifdef WWDB_ENABLE_KVTABLE

namespace wwdb { struct KVPair {
    std::string key;
    std::string value;
};}

WWDB_TABLE(wwdb::KVPair, WWDB_ENABLE_KVTABLE)
WWDB_COLUMN(key, PRIMARY)
WWDB_COLUMN(value, BLOB)
WWDB_END

std::string DataBase::getKeyValue(const std::string& key, const std::string& default_value) {
    auto _ = cols<KVPair>();
    auto result = select<KVPair>(_.key == key).one();
    if (result) {
        return result->value;
    }
    return default_value;
}

void DataBase::setKeyValue(const std::string& key, const std::string& value) {
#if WWDB_ASYNC
    if (shouldPostTaskRunner()) {
        runTask([=](const ReplyRunner& replyRunner){
            setKeyValueImpl(key, value);
        });
        return;
    }
#endif
    setKeyValueImpl(key, value);
}

void DataBase::setKeyValueImpl(const std::string& key, const std::string& value) {
    if (value.empty()) {
        auto _ = cols<KVPair>();
        delete_<KVPair>(_.key == key).execute();
    } else {
        KVPair pair{ key, value };
        replace<KVPair>(pair).execute();
    }
}

#if WWDB_ASYNC
Promise<std::string> DataBase::getKeyValueAsync(const std::string& key, const std::string& default_value) {
    Promise<std::string> p;
    runTask([=](const ReplyRunner& replyRunner){
        auto result = getKeyValue(key, default_value);
        replyRunner([=](){
            p.resolve(result);
        });
    });
    return p;
}
#endif
#endif

void DataBase::onStatementError(int errorCode, const wwdb::StatementBase* statement) {
    std::string sqlite_error = sqlite3_errmsg(connection_);
    callOnErrorHooks(errorCode, sqlite_error, statement);
}

void DataBase::onLogicError(const std::string &error) {
    callOnErrorHooks(SQLITE_ERROR, error, nullptr);
}

DataBase::Transaction::Transaction(DataBase* database, DefaultAction action) : database_(database), action_(action) {
    database->beginTransaction();
}

DataBase::Transaction::~Transaction() {
    if (database_) {
        if (action_ == DefaultAction::Commit) {
            database_->commitTransaction();
        } else if (action_ == DefaultAction::Rollback) {
            database_->rollbackTransaction();
        }
    }
}

void DataBase::Transaction::commit() {
    if (database_) {
        database_->commitTransaction();
        database_ = nullptr;
    }
}

void DataBase::Transaction::rollback() {
    if (database_) {
        database_->rollbackTransaction();
        database_ = nullptr;
    }
}

StatementHandle* DataBase::getCachedStatement(const std::string& sql) {
    auto iter = statement_cache_.find(sql);
    if (iter != statement_cache_.end()) {
        iter->second->reset();
        return iter->second.get();
    } else {
        StatementHandle *handle = new StatementHandle(*this, sql);
        statement_cache_[sql] = std::unique_ptr<StatementHandle>(handle);
        return handle;
    }
}

std::unique_ptr<StatementHandle> DataBase::getUniqueStatement(const std::string& sql) {
    return std::unique_ptr<StatementHandle>(new StatementHandle(*this, sql));
}

bool DataBase::execute(const std::string& sql) {
    return StatementRunBase(*this).executeSync(sql);
}

void DataBase::registerHook(HookBase* hook) {
    if (hook) {
        hooks_.push_back(hook);
    }
}

void DataBase::unregisterHook(HookBase* hook) {
    for (auto iter = hooks_.begin(); iter != hooks_.end(); ++iter) {
        if (*iter == hook) {
            hooks_.erase(iter);
            break;
        }
    }
}

void DataBase::registerOwnedHook(HookBase* hook) {
    if (hook) {
        hooks_.push_back(hook);
        hook_refs_.push_back(std::unique_ptr<HookBase>(hook));
    }
}

void DataBase::callBeforeExecuteHooks(const StatementBase& statement) {
    if (!ignore_global_hooks_) {
        std::lock_guard<std::mutex> lock(GlobalHook_mutex);
        for (auto& hook : HookBase::globalHooks()) hook->beforeExecute(statement);
    }
    for (auto& hook : hooks_) hook->beforeExecute(statement);
}

void DataBase::callAfterExecuteHooks(const StatementBase& statement) {
    for (auto& hook : hooks_) hook->afterExecute(statement);
    if (!ignore_global_hooks_) {
        std::lock_guard<std::mutex> lock(GlobalHook_mutex);
        for (auto& hook : HookBase::globalHooks()) hook->afterExecute(statement);
    }
}

void DataBase::callOnErrorHooks(int errorCode, const std::string& errorMessage, const wwdb::StatementBase* statement) {
    for (auto& hook : hooks_) hook->onError(errorCode, errorMessage, statement);
    if (!ignore_global_hooks_) {
        std::lock_guard<std::mutex> lock(GlobalHook_mutex);
        for (auto& hook : HookBase::globalHooks()) hook->onError(errorCode, errorMessage, statement);
    }
}

void DataBase::ignoreGlobalHooks(bool value) {
    ignore_global_hooks_ = value;
}

// ======== TABLE ========

TableProperty::TableProperty(const char* table_name) : table_name_(table_name) {
    ;
}

TableProperty::TableProperty(const std::string& table_name) : table_name_(table_name) {
    ;
}

TableProperty::TableProperty(const PropertyType& type) : type_(type) {
    ;
}

TableProperty::TableProperty(const PropertyType& type, const std::string& table_name, const FTSTokenize tokenize) : type_(type) {
    table_name_ = table_name;
    fts_tokenize_ = tokenize;
}

std::string TableProperty::TokenizeString(const FTSTokenize tokenize) {
    switch (tokenize) {
        case FTSTokenize::Porter:
            return "porter";
        case FTSTokenize::ICU:
            return "icu";
        default:
            return "simple";
    }
}

TableBase::TableBase(DataBase& db, const std::string& table_name, const std::vector<TableProperty>& properties) : db_(db) {
    for (auto& p : properties) {
        switch (p.type_) {
            case TableProperty::PropertyType::TableName:
                table_name_ = p.table_name_;
                break;
            case TableProperty::PropertyType::FTS3TableName:
                fts_table_name_ = p.table_name_;
                fts_module_ = TableProperty::FTSModule::FTS3;
                fts_tokenize_ = p.fts_tokenize_;
                break;
            case TableProperty::PropertyType::FTS4TableName:
                fts_table_name_ = p.table_name_;
                fts_module_ = TableProperty::FTSModule::FTS4;
                fts_tokenize_ = p.fts_tokenize_;
                break;
            case TableProperty::PropertyType::DoNotCreateOrAlter:
                do_not_create_or_alter_ = true;
                break;
        }
    }
    if (table_name_.empty()) {
        std::string class_name = table_name;
        std::string::size_type pos = class_name.rfind("::");
        if (pos != std::string::npos) {
            class_name = class_name.substr(pos + 2);
        }
        table_name_ = class_name;
    }
}

TableBase::TableBase(TableBase&& other) : db_(other.db_) {
    table_name_ = std::move(other.table_name_);
    fts_table_name_ = std::move(other.fts_table_name_);
    fts_module_ = std::move(other.fts_module_);
    fts_tokenize_ = std::move(other.fts_tokenize_);
    column_definitions_ = std::move(other.column_definitions_);
    table_indexes_ = std::move(other.table_indexes_);
    do_not_create_or_alter_ = std::move(other.do_not_create_or_alter_);
    prepared_ = std::move(other.prepared_);
}

bool TableBase::createOrAlter() {
    return createOrAlter([](const std::string& column_name){return true;});
}

bool TableBase::createOrAlter(const std::function<bool(const std::string& column_name)>& alter_column_handler) {
    // Pure FTS table, don't need create in this step.
    if (fts_module_ != TableProperty::FTSModule::None && fts_table_name_.empty()) {
        return true;
    }
    
    if (db().doesTableExist(table_name_)) {
        // Alter
        auto transaction = db_.transaction(DataBase::Transaction::DefaultAction::Rollback);
        auto existing_columns_vec = db().existingColumns(table_name_);
        for (auto& col : *column_definitions_) {
            bool exist = false;
            for (auto& existcol : existing_columns_vec) {
                if (col.column_name().length() == existcol.length() && sqlite3_stricmp(col.column_name().c_str(), existcol.c_str()) == 0) {
                    exist = true;
                    break;
                }
            }
            if (!exist) {
                std::string altersql("ALTER TABLE ");
                altersql.append(quote(table_name_)).append(" ADD COLUMN ").append(col.fragment());
                bool ret = StatementRunBase(db()).executeSync(altersql);
                if (ret == false) return false;
                if (alter_column_handler(col.column_name()) == false) return false;
            }
        }
        transaction->commit();
    } else {
        // Create
        std::string createsql("CREATE TABLE IF NOT EXISTS ");
        createsql.append(quote(table_name_)).append(" (");
        Appender columns_appender(createsql);
        for (auto& column_definition : *column_definitions_) {
            columns_appender(column_definition.fragment());
        }
        createsql.append(")");
        bool ret = StatementRunBase(*this).executeSync(createsql);
        if (ret == false) return false;
    }
    // Index
    if (createIndex() == false) return false;
    return true;
}

bool TableBase::createIndex() {
    for (auto& index : *table_indexes_) {
        std::string full_index_name;
        if (prefix_tblname_to_indexes_) {
            full_index_name = table_name_;
            full_index_name.append("_");
            full_index_name.append(index.index_name());
        } else {
            full_index_name = index.index_name();
        }
        if (!db().doesIndexExist(full_index_name)) {
            std::string createsql(index.unique() ? "CREATE UNIQUE INDEX IF NOT EXISTS " : "CREATE INDEX IF NOT EXISTS ");
            createsql.append(quote(full_index_name)).append(" ON ").append(quote(table_name_)).append("(");
            Appender column_appender(createsql);
            for (auto& column : index.columns()) {
                column_appender(quote(column.column_name()));
            }
            createsql.append(")");
            bool ret = StatementRunBase(*this).executeSync(createsql);
            if (ret == false) return false;
        }
    }
    return true;
}

bool TableBase::rebuildIndex(const std::function<void()>& operations) {
    auto existing_indexes = db().existingIndexes(quote(table_name_));
    if (existing_indexes.empty()) {
        operations();
    } else {
        auto transaction = db_.transaction(DataBase::Transaction::DefaultAction::Rollback);
        for (auto& index : existing_indexes) {
            std::string dropsql("DROP INDEX ");
            dropsql.append(quote(index));
            StatementRunBase(*this).executeSync(dropsql);
        }
        operations();
        createIndex();
        transaction->commit();
    }
    return true;
}

bool TableBase::createFTSTable() {
    if (fts_module_ == TableProperty::FTSModule::None) return false;
    const std::string& fts_table_name = ftsTableName();
    if (fts_table_name.empty()) return false;

    if (db().doesTableExist(fts_table_name)) {
        // FTS Table Do Not Support Alter Columns
        auto existing_columns_vec = db().existingColumns(fts_table_name);
        std::set<std::string> existing_columns(existing_columns_vec.begin(), existing_columns_vec.end());
        for (auto& col : *column_definitions_) {
            if (col.ftsColumnName().empty() || col.ftsColumnName() == "docid") continue;
            if (existing_columns.find(col.ftsColumnName()) == existing_columns.end()) {
                db().onLogicError("FTS table do not support alter columns!");
                return false;
            }
        }
    } else {
        switch (fts_module_) {
            case TableProperty::FTSModule::FTS3:
                return createFTS3Table();
            case TableProperty::FTSModule::FTS4:
                return createFTS4Table();
            default:
                return false;
        }
    }
    return false;
}

const std::string& TableBase::ftsTableName() {
    return fts_table_name_.empty() ? table_name_ : fts_table_name_;
}

bool TableBase::createFTS3Table() {
    const std::string& fts_table_name = ftsTableName();
    auto transaction = db_.transaction(DataBase::Transaction::DefaultAction::Rollback);
    // Create FTS Table
    std::string createsql("CREATE VIRTUAL TABLE ");
    createsql.append(quote(fts_table_name)).append(" USING fts3(tokenize=");
    createsql.append(TableProperty::TokenizeString(fts_tokenize_)).append(", ");
    Appender column_appender(createsql);
    for (auto& definition : *column_definitions_) {
        if (definition.ftsColumnName().empty() || definition.ftsColumnName() == "docid") continue;
        column_appender(quote(definition.ftsColumnName()));
    }
    createsql.append(")");
    if (!column_appender) {
        db().onLogicError("Attempt to create empty FTS table!");
        return false;
    }
    bool ret = StatementRunBase(*this).executeSync(createsql);
    if (ret == false) {
        db().onLogicError("Create FTS table failed!");
        return false;
    }
    
    // Prepare FTS Columns
    std::string table_docid;
    std::vector<std::string> table_col, fts_col;
    for (size_t i = 0; i < column_definitions_->size(); ++i) {
        auto& definition = column_definitions_->at(i);
        if (!definition.ftsColumnName().empty()) {
            table_col.push_back(definition.column_name());
            fts_col.push_back(definition.ftsColumnName());
            if (definition.ftsColumnName() == "docid") {
                table_docid = definition.column_name();
            }
        }
    }
    if (table_docid.empty()) {
        table_docid = "rowid";
        table_col.push_back(table_docid);
        fts_col.push_back("docid");
    }
    
    // If this table is FTS, do not migrate & create trigger.
    if (fts_table_name_.empty()) return true;
    
    // Migrate Existing Data
    std::string migratesql("INSERT INTO ");
    migratesql.append(quote(fts_table_name)).append("(");
    Appender migrate_ftscol_appender(migratesql);
    for (auto& col : fts_col) {
        migrate_ftscol_appender(quote(col));
    }
    migratesql.append(") SELECT ");
    Appender migrate_tablecol_appender(migratesql);
    for (auto& col : table_col) {
        migrate_tablecol_appender(quote(col));
    }
    migratesql.append(" FROM ").append(quote(table_name_));
    ret = StatementRunBase(*this).executeSync(migratesql);
    if (ret == false) {
        db().onLogicError("Migrate existing data failed!");
        return false;
    }
    
    // Create FTS Triggers
    std::string insertsql("CREATE TRIGGER ");
    insertsql.append(fts_table_name).append("_oninsert AFTER INSERT ON ").append(quote(table_name_)).append(" BEGIN ");
    insertsql.append("INSERT INTO ").append(quote(fts_table_name)).append("(");
    Appender insert_ftscol_appender(insertsql);
    for (auto& col : fts_col) {
        insert_ftscol_appender(quote(col));
    }
    insertsql.append(") VALUES (");
    Appender insert_tablecol_appender(insertsql);
    for (auto& col : table_col) {
        insert_tablecol_appender(std::string("new.").append(quote(col)));
    }
    insertsql.append("); END;");
    ret = StatementRunBase(*this).executeSync(insertsql);
    if (ret == false) {
        db().onLogicError("Create FTS insert trigger failed!");
        return false;
    }
    
    std::string updatesql("CREATE TRIGGER ");
    updatesql.append(fts_table_name).append("_onupdate AFTER UPDATE ON ").append(quote(table_name_)).append(" BEGIN ");
    updatesql.append("UPDATE ").append(quote(fts_table_name)).append(" SET ");
    Appender update_tablecol_appender(updatesql);
    for (auto& col : table_col) {
        update_tablecol_appender(quote(col).append(" = new.").append(quote(col)));
    }
    updatesql.append(" WHERE docid = old.").append(quote(table_docid)).append("; END;");
    ret = StatementRunBase(*this).executeSync(updatesql);
    if (ret == false) {
        db().onLogicError("Create FTS update trigger failed!");
        return false;
    }
    
    std::string deletesql("CREATE TRIGGER ");
    deletesql.append(fts_table_name).append("_ondelete AFTER DELETE ON ").append(quote(table_name_)).append(" BEGIN ");
    deletesql.append("DELETE FROM ").append(quote(fts_table_name)).append(" WHERE docid = old.").append(quote(table_docid)).append("; END;");
    ret = StatementRunBase(*this).executeSync(deletesql);
    if (ret == false) {
        db().onLogicError("Create FTS delete trigger failed!");
        return false;
    }

    transaction->commit();
    return true;
}

bool TableBase::createFTS4Table() {
    const std::string& fts_table_name = ftsTableName();
    auto transaction = db_.transaction(DataBase::Transaction::DefaultAction::Rollback);
    // Create FTS Table
    std::string createsql("CREATE VIRTUAL TABLE ");
    createsql.append(quote(fts_table_name)).append(" USING fts4(tokenize=");
    createsql.append(TableProperty::TokenizeString(fts_tokenize_)).append(", ");

    // If this table is FTS, do not create external content.
    if (!fts_table_name_.empty()) {
        createsql.append("content=\"").append(table_name_).append("\", ");
    }

    createsql.append("matchinfo=\"fts3\", ");

    Appender column_appender(createsql);
    for (auto& definition : *column_definitions_) {
        if (definition.ftsColumnName().empty() || definition.ftsColumnName() == "docid") continue;
        column_appender(quote(definition.ftsColumnName()));
    }
    createsql.append(")");
    if (!column_appender) {
        db().onLogicError("Attempt to create empty FTS table!");
        return false;
    }
    bool ret = StatementRunBase(*this).executeSync(createsql);
    if (ret == false) {
        db().onLogicError("Create FTS table failed!");
        return false;
    }
    
    // Prepare FTS Columns
    std::string table_docid;
    std::vector<std::string> table_col, fts_col;
    for (size_t i = 0; i < column_definitions_->size(); ++i) {
        auto& definition = column_definitions_->at(i);
        if (!definition.ftsColumnName().empty()) {
            table_col.push_back(definition.column_name());
            fts_col.push_back(definition.ftsColumnName());
            if (definition.ftsColumnName() == "docid") {
                table_docid = definition.column_name();
            }
        }
    }
    if (table_docid.empty()) {
        table_docid = "rowid";
        table_col.push_back(table_docid);
        fts_col.push_back("docid");
    }
    
    // If this table is FTS, do not migrate & create trigger.
    if (fts_table_name_.empty()) return true;
    
    // Migrate Existing Data
    std::string migratesql("INSERT INTO ");
    migratesql.append(quote(fts_table_name)).append("(");
    Appender migrate_ftscol_appender(migratesql);
    for (auto& col : fts_col) {
        migrate_ftscol_appender(quote(col));
    }
    migratesql.append(") SELECT ");
    Appender migrate_tablecol_appender(migratesql);
    for (auto& col : table_col) {
        migrate_tablecol_appender(quote(col));
    }
    migratesql.append(" FROM ").append(quote(table_name_));
    ret = StatementRunBase(*this).executeSync(migratesql);
    if (ret == false) {
        db().onLogicError("Migrate existing data failed!");
        return false;
    }
    
    // Create FTS Triggers
    std::string afterinsertsql("CREATE TRIGGER ");
    afterinsertsql.append(fts_table_name).append("_afterinsert AFTER INSERT ON ").append(quote(table_name_)).append(" BEGIN ");
    afterinsertsql.append("INSERT INTO ").append(quote(fts_table_name)).append("(");
    Appender insert_ftscol_appender(afterinsertsql);
    for (auto& col : fts_col) {
        insert_ftscol_appender(quote(col));
    }
    afterinsertsql.append(") VALUES (");
    Appender insert_tablecol_appender(afterinsertsql);
    for (auto& col : table_col) {
        insert_tablecol_appender(std::string("new.").append(quote(col)));
    }
    afterinsertsql.append("); END;");
    ret = StatementRunBase(*this).executeSync(afterinsertsql);
    if (ret == false) {
        db().onLogicError("Create FTS insert trigger failed!");
        return false;
    }
    
    std::string beforeupdatesql("CREATE TRIGGER ");
    beforeupdatesql.append(fts_table_name).append("_beforeupdate BEFORE UPDATE ON ").append(quote(table_name_)).append(" BEGIN ");
    beforeupdatesql.append("DELETE FROM ").append(quote(fts_table_name)).append(" WHERE docid = old.").append(quote(table_docid)).append("; END;");
    ret = StatementRunBase(*this).executeSync(beforeupdatesql);
        if (ret == false) {
        db().onLogicError("Create FTS before update trigger failed!");
        return false;
    }
        
    std::string afterupdatesql("CREATE TRIGGER ");
    afterupdatesql.append(fts_table_name).append("_afterupdate AFTER UPDATE ON ").append(quote(table_name_)).append(" BEGIN ");
    afterupdatesql.append("INSERT INTO ").append(quote(fts_table_name)).append("(");
    Appender update_ftscol_appender(afterupdatesql);
    for (auto& col : fts_col) {
        update_ftscol_appender(quote(col));
    }
    afterupdatesql.append(") VALUES (");
    Appender update_tablecol_appender(afterupdatesql);
    for (auto& col : table_col) {
        update_tablecol_appender(std::string("new.").append(quote(col)));
    }
    afterupdatesql.append("); END;");
    ret = StatementRunBase(*this).executeSync(afterupdatesql);
    if (ret == false) {
        db().onLogicError("Create FTS after update trigger failed!");
        return false;
    }

    std::string beforedeletesql("CREATE TRIGGER ");
    beforedeletesql.append(fts_table_name).append("_beforedelete BEFORE DELETE ON ").append(quote(table_name_)).append(" BEGIN ");
    beforedeletesql.append("DELETE FROM ").append(quote(fts_table_name)).append(" WHERE docid = old.").append(quote(table_docid)).append("; END;");
    ret = StatementRunBase(*this).executeSync(beforedeletesql);
    if (ret == false) {
        db().onLogicError("Create FTS before delete trigger failed!");
        return false;
    }

    transaction->commit();
    return true;
}

bool TableBase::dropIfExist() {
    auto transaction = db_.transaction(DataBase::Transaction::DefaultAction::Rollback);
    std::string dropsql("DROP TABLE IF EXISTS ");
    dropsql.append(quote(table_name_));
    bool ret = StatementRunBase(*this).executeSync(dropsql);
    if (fts_module_ != TableProperty::FTSModule::None && !fts_table_name_.empty()) {
        std::string dropftssql("DROP TABLE IF EXISTS ");
        dropftssql.append(quote(fts_table_name_));
        ret = StatementRunBase(*this).executeSync(dropftssql) || ret;
    }
    transaction->commit();
    if (ret) {
        prepared_ = false;
    }
    return ret;
}

bool TableBase::translateMatchPredicate(std::string& predicate) const {
    if (fts_module_ == TableProperty::FTSModule::None) return false;
    if (fts_table_name_.empty()) return false;
    
    std::string::size_type start;
    std::string::size_type length;
    auto find = [&](const std::string& keyword) {
        std::string::size_type pos = predicate.find(keyword);
        if (pos != std::string::npos) {
            start = pos;
            length = keyword.length();
            return true;
        }
        return false;
    };
    
    std::string table_docid;
    while (find("[[WWDB_FTS_DOCID]]")) {
        if (table_docid.empty()) {
            for (size_t i = 0; i < column_definitions_->size(); ++i) {
                auto& definition = column_definitions_->at(i);
                if (definition.ftsColumnName() == "docid") {
                    table_docid = definition.column_name();
                }
            }
            if (table_docid.empty()) {
                table_docid = "rowid";
            }
        }
        predicate.replace(start, length, table_docid);
    }
    
    while (find("[[WWDB_FTS_TABLE]]")) {
        predicate.replace(start, length, quote(fts_table_name_));
    }

    return true;
}

sqlite3* TableBase::connection() const {
    return db_.connection();
}

// ======== COLUMN DEFINITION ========

ColumnDefinition::ColumnDefinition(const std::string& column_name, const std::string& default_type_name, const std::vector<ColumnConstraint>& constraints) : ColumnBase(column_name) {
    std::string fragment;
    auto appender = [&](const std::string& v) {
        if (!fragment.empty()) fragment.append(" ");
        return fragment.append(v);
    };
    bool has_name = false, has_type = false;
    for (auto& constraint : constraints) {
        if (!has_name && constraint.type_ > ColumnConstraint::ConstraintType::__ImplicitColumnNameHere) {
            appender(quote(column_name));
            has_name = true;
        }
        if (!has_type && constraint.type_ > ColumnConstraint::ConstraintType::__ImplicitColumnTypeHere) {
            appender(default_type_name);
            has_type = true;
        }
        switch (constraint.type_) {
            case wwdb::ColumnConstraint::ConstraintType::ColumnName:
                appender(quote(constraint.column_name_));
                column_name_ = constraint.column_name_;
                has_name = true;
                break;
            case wwdb::ColumnConstraint::ConstraintType::Blob:
                if (!has_type) appender("BLOB");
                is_blob_ = true;
                has_type = true;
                break;
            case wwdb::ColumnConstraint::ConstraintType::DefaultValue:
                appender("DEFAULT");
                appender(constraint.default_value_);
                break;
            case wwdb::ColumnConstraint::ConstraintType::Primary:
                appender("PRIMARY KEY");
                is_primary_ = true;
                break;
            case wwdb::ColumnConstraint::ConstraintType::NotNull:
                appender("NOT NULL");
                break;
            case wwdb::ColumnConstraint::ConstraintType::Unique:
                appender("UNIQUE");
                break;
            case wwdb::ColumnConstraint::ConstraintType::AutoIncrement:
                appender("AUTOINCREMENT");
                is_autoincrement_ = true;
                break;
            case wwdb::ColumnConstraint::ConstraintType::DanglingColumn:
                is_dangling_column_ = true;
                break;
            case wwdb::ColumnConstraint::ConstraintType::FullTextSearchDocId:
                fts_column_name_ = "docid";
                break;
            case wwdb::ColumnConstraint::ConstraintType::FullTextSearchColumn:
                if (constraint.column_name_.empty()) {
                    fts_column_name_ = column_name_;
                } else {
                    fts_column_name_ = constraint.column_name_;
                }
                break;
            case wwdb::ColumnConstraint::ConstraintType::DynamicValue:
                is_dynamic_value_ = true;
                break;
            default:
                break;
        }
    }
    expression_ = fragment;
}

ColumnConstraint::ColumnConstraint(const ConstraintType& type) : type_(type) {
    ;
}

ColumnConstraint::ColumnConstraint(const char* name) : type_(ConstraintType::ColumnName), column_name_(name) {
    ;
}

ColumnConstraint::ColumnConstraint(const std::string& name) : type_(ConstraintType::ColumnName), column_name_(name) {
    ;
}

ColumnConstraint::ColumnConstraint(const ConstraintType& type, const std::string& content) : type_(type) {
    if (type == ConstraintType::ColumnName) {
        column_name_ = content;
    } else if (type == ConstraintType::DefaultValue) {
        default_value_ = content;
    } else if (type == ConstraintType::FullTextSearchColumn) {
        column_name_ = content;
    }
}

bool ColumnConstraint::operator<(const ColumnConstraint& other) const {
    return type_ < other.type_;
}

// ======== STATEMENT ========

StatementBase::StatementBase(DataBase& database, const std::string& sql) : database_(database), sql_(sql), executed_(new bool(false)) {
    ;
}

StatementBase::StatementBase(TableBase& table) : database_(table.db()), table_(&table), executed_(new bool(false)) {
    ;
}

DataBase& StatementBase::database() const {
    return database_;
}

const TableBase* StatementBase::table() const {
    return table_;
}

const std::string& StatementBase::sql() const {
    return sql_;
}

const bool StatementBase::cacheable() const {
    return cacheable_;
}

const uint64_t StatementBase::changes() const {
    return changes_;
}

StatementHandle* StatementBase::handle() {
    return handle_;
}

bool StatementBase::step() {
    int ret = checkError(sqlite3_step(handle()->stmt()));
    return ret == SQLITE_ROW;
}

bool StatementBase::run() {
    int ret = SQLITE_ERROR;
    while(true) {
        ret = checkError(sqlite3_step(handle()->stmt()));
        if (ret == SQLITE_ROW) continue;
        break;
    };
    return ret == SQLITE_DONE;
}

int StatementBase::checkError(int err) {
    bool succeeded = (err == SQLITE_OK || err == SQLITE_ROW || err == SQLITE_DONE);
    if (!succeeded) {
        database_.onStatementError(err, this);
    }
    return err;
}

bool StatementBase::shouldExecuteInDestructor() const {
    if (executed_ && !*executed_ && executed_.use_count() == 1) return true;
    return false;
}

bool StatementBase::markExecuted() {
    if (executed_ && *executed_) return false;
    *executed_ = true;
    return true;
}

std::string StatementRunBase::conflictAsString(const ConflictTerm conflict) {
    switch (conflict) {
        case ConflictTerm::Rollback:
            return "ROLLBACK";
        case ConflictTerm::Abort:
            return "ABORT";
        case ConflictTerm::Fail:
            return "FAIL";
        case ConflictTerm::Ignore:
            return "IGNORE";
        case ConflictTerm::Replace:
            return "REPLACE";
        default:
            return "";
    }
}

bool StatementRunBase::execute(const std::string& sql) {
#if WWDB_ASYNC
    if (database().shouldPostTaskRunner()) {
        database().runTask([sql, thiz = std::move(*this)](const DataBase::ReplyRunner&) mutable {
            thiz.StatementRunBase::executeSync(sql);
        });
        executed_.reset();
        return true;
    }
#endif
    return StatementRunBase::executeSync(sql);
}

bool StatementRunBase::executeSync(const std::string& sql) {
    if (!markExecuted()) return false;
    if (table_) table_->prepare();
    sql_ = sql;
    if (cacheable_) {
        handle_ = database_.getCachedStatement(sql);
    } else {
        handle_owned_ = database_.getUniqueStatement(sql);
        handle_ = handle_owned_.get();
    }
    if (handle_->ret() != SQLITE_OK) {
        database().onStatementError(handle_->ret(), this);
        return false;
    }
    database().callBeforeExecuteHooks(*this);
    bool ret = false;
    if (bindCount() == 0) {
        bindStatement(*this);
        ret = run();
        if (ret) {
            changes_ = sqlite3_changes(database_.connection());
        }
    } else {
        std::unique_ptr<DataBase::Transaction> transaction;
        if (bindCount() > 1) {
            transaction = database().transaction();
        }
        do {
            bindStatement(*this);
            ret = run();
            handle()->reset();
            if (ret) {
                changes_ += sqlite3_changes(database_.connection());
            }
        } while (moveNext());
    }
    database().callAfterExecuteHooks(*this);
    return ret;
}

// ======== SELECT ========

StatementSelectBase::StatementSelectBase(TableBase& table) : StatementBase(table) {
    ;
}

StatementSelectBase::StatementSelectBase(TableBase& table, const Predicate& predicate) : StatementBase(table), where_(predicate) {
    ;
}

StatementSelectBase::StatementSelectBase(TableBase& table, const std::string& sql) : StatementBase(table) {
    sql_ = sql;
}

StatementSelectBase& StatementSelectBase::distinct() {
    distinct_ = true;
    return *this;
}

StatementSelectBase& StatementSelectBase::where(const Predicate& predicate) {
    where_ = predicate;
    return *this;
}

StatementSelectBase& StatementSelectBase::orderBy(const ColumnBase& column, OrderTerm orderTerm) {
    orderBy(std::make_pair(column.column_name(), orderTerm));
    return *this;
}

StatementSelectBase& StatementSelectBase::orderBy(const ColumnOrderTerm& columnOrderTerm) {
    orderBy_.push_back(columnOrderTerm);
    return *this;
}

StatementSelectBase& StatementSelectBase::limit(const int& limit) {
    limit_ = limit;
    return *this;
}

StatementSelectBase& StatementSelectBase::offset(const int& offset) {
    offset_ = offset;
    return *this;
}

StatementSelectBase& StatementSelectBase::groupBy(const ColumnBase& column) {
    groupBy_.push_back(column);
    return *this;
}

StatementSelectBase& StatementSelectBase::having(const Predicate& predicate) {
    having_ = predicate;
    return *this;
}

std::string StatementSelectBase::makeSql() {
    std::string sql;
    sql.append("SELECT ");
    if (distinct_) {
        sql.append("DISTINCT ");
    }
    if (is_count_query_ && column_names_.empty()) {
        sql.append("COUNT(*)");
    } else {
        if (is_count_query_) sql.append("COUNT(");
        Appender sql_appender(sql);
        for (auto& column_name : column_names_) {
            sql_appender(quote(column_name));
        }
        if (is_count_query_) sql.append(")");
    }
    sql.append(" FROM ").append(quote(table_->tableName()));
    if (where_ && where_->isValid()) {
        sql.append(" WHERE ").append(where_->toString());
        bind_list_.insert(bind_list_.end(), where_->bind_list_.begin(), where_->bind_list_.end());
        cacheable_ = cacheable_ && where_->cacheable();
    }
    if (!orderBy_.empty()) {
        sql.append(" ORDER BY ");
        Appender sql_appender(sql);
        for (auto& orderBy : orderBy_) {
            sql_appender(quote(orderBy.first));
            if (orderBy.second == OrderTerm::ASC) {
                sql.append(" ASC");
            } else if (orderBy.second == OrderTerm::DESC) {
                sql.append(" DESC");
            }
        }
    }
    if (limit_ > 0) {
        sql.append(" LIMIT ?");
        bind_list_.push_back(bindArgument(limit_));
    }
    if (offset_ > 0) {
        sql.append(" OFFSET ?");
        bind_list_.push_back(bindArgument(offset_));
    }
    if (!groupBy_.empty()) {
        sql.append(" GROUP BY ");
        Appender sql_appender(sql);
        for (auto& groupBy : groupBy_) {
            sql_appender(quote(groupBy.column_name()));
        }
        if (having_ && having_->isValid()) {
            sql.append(" HAVING ").append(having_->toString());
            bind_list_.insert(bind_list_.end(), having_->bind_list_.begin(), having_->bind_list_.end());
            cacheable_ = cacheable_ && having_->cacheable();
        }
    }
    table()->translateMatchPredicate(sql);
    return sql;
}

size_t StatementSelectBase::count() {
    is_count_query_ = true;
    size_t result = 0;
    execute([&](StatementBase& s){
        result = sqlite3_column_int(s.handle()->stmt(), 0);
        // for count query, changes is always useless 1, so set result count to changes.
        changes_ = result;
        return false;
    });
    return result;
}

bool StatementSelectBase::execute(const StatementHandler& handler) {
    if (!markExecuted()) return false;
    if (table_) table_->prepare();
    if (sql_.empty() && table_) sql_ = makeSql();
    if (cacheable_) {
        handle_ = database_.getCachedStatement(sql_);
    } else {
        handle_owned_ = database_.getUniqueStatement(sql_);
        handle_ = handle_owned_.get();
    }
    if (handle_->ret() != SQLITE_OK) {
        database().onStatementError(handle_->ret(), this);
        return false;
    }
    bindStatement(*this);
    database().callBeforeExecuteHooks(*this);
    while (step()) {
        ++changes_;
        bool ret = handler(*this);
        if (!ret) break;
    }
	handle_->reset();
    database().callAfterExecuteHooks(*this);
    return true;
}

StatementSelectBase::operator Subquery() {
    if (!*executed_) sql_ = makeSql();
    markExecuted();
    return Subquery(sql_, bind_list_);
}

// ======== INSERT ========

StatementInsertBase& StatementInsertBase::batch(bool batch) {
    enable_batch_insert_ = batch;
    return *this;
}

StatementInsertBase& StatementInsertBase::reindex(bool reindex) {
    rebuild_table_index_ = reindex;
    return *this;
}

StatementInsertBase& StatementInsertBase::conflict(ConflictTerm conflict) {
    conflict_ = conflict;
    return *this;
}

StatementInsertBase& StatementInsertBase::includesAutoIncrement(bool includesAutoIncrement) {
    includes_autoincrement_ = includesAutoIncrement;
    return *this;
}

StatementInsertBase::~StatementInsertBase() {
    if (shouldExecuteInDestructor()) execute();
}

bool StatementInsertBase::execute() {
    if (rebuild_table_index_) {
        bool result;
        table_->rebuildIndex([&](){
            result = executeInternal();
        });
        return result;
    } else {
        return executeInternal();
    }
}

bool StatementInsertBase::executeInternal() {
    if (bindCount() == 0) {
        markExecuted();
        return false;
    } else if (enable_batch_insert_) {
        if (!markExecuted()) return false;
        // Read current limit first
        int parameter_limit = sqlite3_limit(database().connection(), SQLITE_LIMIT_VARIABLE_NUMBER, -1);
        int object_count = (int)bindCount();
        int column_count = 0;
        for (size_t i = 0; i < column_names_.size(); ++i) {
            if (shouldInsertColumn(i)) {
                ++column_count;
            }
        }
        parameter_limit = std::min(parameter_limit, WWDB_BATCH_INSERT_PIECE * column_count);
        std::unique_ptr<DataBase::Transaction> transaction = database().transaction();
        if (column_count * object_count <= parameter_limit) {
            return executePiecewise(makeSql(object_count), object_count, 1);
        } else {
            int slice = parameter_limit / column_count;
            bool ret = executePiecewise(makeSql(slice), slice, object_count / slice);
            if (ret) {
                slice = object_count % slice;
                if (slice > 0) {
                    ret = executePiecewise(makeSql(slice), slice, 1);
                }
            }
            return ret;
        }
    } else {
        return StatementRunBase::executeSync(makeSql());
    }
}

bool StatementInsertBase::executePiecewise(const std::string& sql, int slice, int times) {
    if (table_) table_->prepare();
#if DEBUG
    // Misuse check: avoid inserting with conflict term but not have any row constraints.
    if (conflict_ != ConflictTerm::NotSet) {
        bool pass = [&](){
            if (table_->tableIndexes() && !table_->tableIndexes()->empty()) {
                for (auto& iter : *table_->tableIndexes()) {
                    if (iter.unique()) return true;
                }
            }
            if (table_->columnDefinitions() && !table_->columnDefinitions()->empty()) {
                for (auto& iter : *table_->columnDefinitions()) {
                    if (iter.isPrimary()) return true;
                }
            }
            return false;
        }();
        if (!pass) assert("Insert with conflict term requires either a primary column or any unique indexes.");
    }
#endif
    sql_ = sql;
    if (cacheable_) {
        handle_ = database_.getCachedStatement(sql);
    } else {
        handle_owned_ = database_.getUniqueStatement(sql);
        handle_ = handle_owned_.get();
    }
    if (handle_->ret() != SQLITE_OK) {
        database().onStatementError(handle_->ret(), this);
        return false;
    }
    database().callBeforeExecuteHooks(*this);
    bool ret = false;
    for (int i = 0; i < times; ++i) {
        bind_offset_ = 0;
        for (int j = 0; j < slice; ++j) {
            bind_offset_ += bindStatement(*this);
            moveNext();
        }
        ret = run();
        handle()->reset();
        if (ret) {
            changes_ += sqlite3_changes(database_.connection());
        } else {
            break;
        }
    }
    database().callAfterExecuteHooks(*this);
    return ret;
}

std::string StatementInsertBase::makeSql(int slice) {
    std::string sql("INSERT");
    if (conflict_ != ConflictTerm::NotSet) {
        sql.append(" OR ").append(conflictAsString(conflict_));
    }
    sql.append(" INTO ").append(quote(table_->tableName()));
    if (!column_names_.empty()) {
        sql.append(" (");
        Appender sql_col_appender(sql);
        for (size_t i = 0; i < column_names_.size(); ++i) {
            if (shouldInsertColumn(i)) {
                sql_col_appender(quote(column_names_[i]));
            }
        }
        sql.append(") VALUES ");
        bool should_append_comma_val = false;
        for (int p = 0; p < slice; ++p) {
            if (should_append_comma_val) sql.append(", ");
            should_append_comma_val = true;
            sql.append("(");
            Appender sql_data_appender(sql);
            for (size_t i = 0; i < column_names_.size(); ++i) {
                if (shouldInsertColumn(i)) {
                    sql_data_appender("?");
                }
            }
            sql.append(")");
        }
    }
    return sql;
}

bool StatementInsertBase::shouldInsertColumn(int i) const {
    if (includes_autoincrement_) return true;
    if (column_autoincrement_index_.empty()) return true;
    if (column_autoincrement_index_.find(i) == column_autoincrement_index_.end()) return true;
    return false;
}

// ======== UPDATE ========

StatementUpdateBase::StatementUpdateBase(TableBase& table, const Predicate& predicate) : StatementRunBase(table) {
    where(predicate);
}

StatementUpdateBase::~StatementUpdateBase() {
    if (shouldExecuteInDestructor()) execute();
}

StatementUpdateBase& StatementUpdateBase::conflict(ConflictTerm conflict) {
    conflict_ = conflict;
    return *this;
}

StatementUpdateBase& StatementUpdateBase::where(const Predicate& predicate) {
    where_ = predicate;
    return *this;
}

StatementUpdateBase& StatementUpdateBase::set(const SetExpr& setexpr) {
    sets_.push_back(setexpr);
    return *this;
}

bool StatementUpdateBase::execute() {
#if WWDB_ASYNC
    if (database().shouldPostTaskRunner()) {
        database().runTask([thiz = std::move(*this)](const DataBase::ReplyRunner&) mutable {
            thiz.StatementRunBase::executeSync(thiz.makeSql());
        });
        executed_.reset();
        return true;
    }
#endif
    return StatementRunBase::executeSync(makeSql());
}

std::string StatementUpdateBase::makeSql() {
    std::string sql("UPDATE ");
    sql.append(quote(table_->tableName()));
    if (conflict_ != ConflictTerm::NotSet) {
        sql.append(" OR ").append(conflictAsString(conflict_));
    }
    if (!sets_.empty()) {
        sql.append(" SET ");
        Appender sql_appender(sql);
        for (auto& set : sets_) {
            sql_appender(std::string(set.expression()).append(" = ?"));
            bind_list_.push_back(set.bindList().back());
        }
    }
    if (where_ && where_->isValid()) {
        sql.append(" WHERE ").append(where_->toString());
        bind_list_.insert(bind_list_.end(), where_->bindList().begin(), where_->bindList().end());
        cacheable_ = cacheable_ && where_->cacheable();
    }
    table_->translateMatchPredicate(sql);
    return sql;
}

// ======== DELETE ========

StatementDeleteBase::StatementDeleteBase(TableBase& table) : StatementRunBase(table) {
    ;
}

StatementDeleteBase::StatementDeleteBase(TableBase& table, const Predicate& predicate) : StatementRunBase(table) {
    where(predicate);
}

StatementDeleteBase::~StatementDeleteBase() {
    if (shouldExecuteInDestructor()) execute();
}

StatementDeleteBase& StatementDeleteBase::where(const Predicate& predicate) {
    where_ = predicate;
    return *this;
}

bool StatementDeleteBase::execute() {
#if WWDB_ASYNC
    if (database().shouldPostTaskRunner()) {
        database().runTask([thiz = std::move(*this)](const DataBase::ReplyRunner&) mutable {
            thiz.StatementRunBase::executeSync(thiz.makeSql());
        });
        executed_.reset();
        return true;
    }
#endif
    return StatementRunBase::executeSync(makeSql());
}

std::string StatementDeleteBase::makeSql() {
    std::string sql;
    sql.append("DELETE FROM ").append(quote(table_->tableName()));
    if (where_ && where_->isValid()) {
        sql.append(" WHERE ").append(where_->toString());
        bind_list_.insert(bind_list_.end(), where_->bindList().begin(), where_->bindList().end());
        cacheable_ = cacheable_ && where_->cacheable();
    }
    table_->translateMatchPredicate(sql);
    return sql;
}

// ======== HOOK ========

HookBase::~HookBase() {
    ;
}

void HookBase::beforeExecute(const wwdb::StatementBase &statement) {
    ;
}

void HookBase::afterExecute(const wwdb::StatementBase &statement) {
    ;
}

void HookBase::onError(int errorCode, const std::string errorMessage, const StatementBase* statement) {
    ;
}

void HookBase::registerGlobalHook(HookBase* hook) {
    std::lock_guard<std::mutex> lock(GlobalHook_mutex);
    globalHooks().push_back(hook);
}

void HookBase::unregisterGlobalHook(HookBase* hook) {
    std::lock_guard<std::mutex> lock(GlobalHook_mutex);
    for (auto iter = globalHooks().begin(); iter != globalHooks().end(); ++iter) {
        if (*iter == hook) {
            globalHooks().erase(iter);
            break;
        }
    }
}

std::vector<HookBase*>& HookBase::globalHooks() {
    static std::vector<HookBase*> hooks_;
    return hooks_;
}
