#ifndef wwdb_core_hpp
#define wwdb_core_hpp

#include "wwdb_internal.hpp"

#undef min
#undef max

namespace wwdb {
    
class Predicate : public SqlBase {
public:
    explicit Predicate();
    Predicate operator!() const;
    Predicate operator&&(const Predicate& other) const;
    Predicate operator||(const Predicate& other) const;
    std::string toString() const;
    std::string toParenthesisString() const;
    bool cacheable() const;
private:
    explicit Predicate(const std::string& predicate);
    explicit Predicate(const ColumnBase& column, const std::string& suffix);
    explicit Predicate(const ColumnBase& column, const std::string& prefix, const std::string& suffix);
    explicit Predicate(const ColumnBase& column, const std::string& suffix, const Binder& binder);
    explicit Predicate(const ColumnBase& column, const std::string& prefix, const std::string& suffix, const Binder& binder);
    explicit Predicate(const ColumnBase& column, const std::string& suffix, const Binder& binder1, const Binder& binder2);
    explicit Predicate(const ColumnBase& column, const std::string& prefix, const std::string& suffix, const Binder& binder1, const Binder& binder2);
    template<class Container> explicit Predicate(const ColumnBase& column, const std::string& prefix, const std::string& suffix, const Container& binders, bool cacheable = true);
    template<class C, class S> friend class ORM;
    template<class C, class T> friend class Column;
    template<class C, class T1, class T2> friend class PairColumn;
    template<class C, class ...T> friend class TupleColumn;
    bool cacheable_ = true;
    bool is_compound_ = false;
};
    
class SetExpr : public SqlBase {
public:
    SetExpr(const ColumnBase& column, const Binder& binder);
};
    
class Subquery : public SqlBase {
public:
    Subquery(const std::string& sql, const std::vector<Binder>& binders);
    Subquery union_(const Subquery& other);
    Subquery except(const Subquery& other);
};

template<class C, class T>
class Column : public ColumnBase {
public:
    using Decoder = std::function<void(StatementBase&, int, C&, const ColumnDefinition*)>;
    using Encoder = std::function<Binder(const C&, bool, const ColumnDefinition*)>;
    Column(const std::string& default_column_name,
           const std::initializer_list<ColumnConstraint>& constraints,
           const Decoder& decoder, const Encoder& encoder);
    const std::string& extractColumnNameConstraint(const std::string& default_name, const std::initializer_list<ColumnConstraint>& constraints);
    std::vector<ColumnConstraint> prepareColumnConstraint(const std::initializer_list<ColumnConstraint>& constraints);
    Predicate operator==(const T& arg);
    Predicate operator>(const T& arg);
    Predicate operator<(const T& arg);
    Predicate operator<=(const T& arg);
    Predicate operator>=(const T& arg);
    Predicate operator!=(const T& arg);
    Predicate isNull();
    // WARNING: Before adding '%' or '_', user input part should be escaped by escapelike() function.
    Predicate like(const T& arg);
    // WARNING: Before adding '%' or '_', user input part should be escaped by escapelike() function.
    Predicate glob(const T& arg);
    Predicate match(const T& arg);
    // WARNING: Before adding '%' or '_', user input part should be escaped by escapelike() function.
    Predicate matchlike(const T& matcharg, const T& likearg);
    Predicate between(const T& lower, const T& upper);
    Predicate notBetween(const T& lower, const T& upper);
    Predicate in(const std::initializer_list<T>& container);
    Predicate in(const Subquery& subquery);
    template<class Container> Predicate in(const Container& container);
    Predicate notIn(const std::initializer_list<T>& container);
    Predicate notIn(const Subquery& subquery);
    template<class Container> Predicate notIn(const Container& container);
    SetExpr operator=(const T& arg);
    
    VirtualColumn<C, T> operator+(const T& arg);
    VirtualColumn<C, T> operator-(const T& arg);
    VirtualColumn<C, T> operator*(const T& arg);
    VirtualColumn<C, T> operator/(const T& arg);
    VirtualColumn<C, T> operator%(const T& arg);
    VirtualColumn<C, T> operator&(const T& arg);
    VirtualColumn<C, T> operator|(const T& arg);
    VirtualColumn<C, T> operator~();
    
    VirtualColumn<C, uint64_t> length();
    VirtualColumn<C, std::string> lower();
    VirtualColumn<C, std::string> upper();
    // WARNING: Different from SQLite, the left-most character of X is number 0!
    VirtualColumn<C, std::string> substr(int begin, int length = -1);
    VirtualColumn<C, std::string> trim();
    VirtualColumn<C, T> self();
    
    AggregateColumn<C, uint64_t> count();
    AggregateColumn<C, T> avg();
    AggregateColumn<C, T> max();
    AggregateColumn<C, T> min();
    AggregateColumn<C, T> sum();
    AggregateColumn<C, T> total();
    
    ColumnOrderTerm asc();
    ColumnOrderTerm desc();
    
    template<class T2> PairColumn<C, T, T2> operator,(const Column<C, T2>& next);
    
    inline const std::vector<ColumnConstraint>& constraints() const { return constraints_; }
    inline const ColumnDefinition& definition() const { return definition_; }
    inline const Decoder& decoder() const { return decoder_; }
    inline const Encoder& encoder() const { return encoder_; }
protected:
    template<class Container> Predicate expandInitializer(const std::string& keyword, const Container& container);
private:
    using ColumnBase::ColumnBase;
    std::vector<ColumnConstraint> constraints_;
    ColumnDefinition definition_;
    Decoder decoder_;
    Encoder encoder_;
};
    
template<class C, class T>
class VirtualColumn : public Column<C, T> {
public:
    explicit VirtualColumn(const std::string& expression);
    explicit VirtualColumn(const Column<C, T>& column);
    VirtualColumn(const ColumnBase& column, const std::string& expression);
    VirtualColumn(const ColumnBase& column, const std::string& expression, const Binder& binder);
    VirtualColumn(const ColumnBase& column, const std::string& expression, const Binder& binder1, const Binder& binder2);
    T& value();
    std::vector<T> rows;
};
    
template<class C, class T>
class AggregateColumn : public VirtualColumn<C, T> {
public:
    using VirtualColumn<C, T>::VirtualColumn;
};

template<class C, class T1, class T2>
class PairColumn : public ColumnBase {
public:
    PairColumn(const Column<C, T1>& c1, const Column<C, T2>& c2);
    
    Predicate in(const std::initializer_list<std::pair<T1, T2>>& container);
    template<class Container> Predicate in(const Container& container);
    Predicate notIn(const std::initializer_list<std::pair<T1, T2>>& container);
    template<class Container> Predicate notIn(const Container& container);
    
    template<class T3> TupleColumn<C, T1, T2, T3> operator,(const Column<C, T3>& next);
protected:
    template<class Container> Predicate expandInitializer(const std::string& keyword, const Container& container);
private:
    std::pair<Column<C, T1>, Column<C, T2>> columns_;
};

template<class C, class ...T>
class TupleColumn : public ColumnBase {
public:
    TupleColumn(const Column<C, T>& ...cs);
    TupleColumn(const std::tuple<Column<C, T>...>& tuple);
    
    Predicate in(const std::initializer_list<std::tuple<T...>>& container);
    template<class Container> Predicate in(const Container& container);
    Predicate notIn(const std::initializer_list<std::tuple<T...>>& container);
    template<class Container> Predicate notIn(const Container& container);
    
    template<class TN> TupleColumn<C, T..., TN> operator,(const Column<C, TN>& next);
protected:
    template<class Container> Predicate expandInitializer(const std::string& keyword, const Container& container);
private:
    std::tuple<Column<C, T>...> columns_;
};

class GenericExecutor {
public:
    template<class C, class S = scope::MainScope<0>> const ORM<C, S>& cols();
    template<class C, class S = scope::MainScope<0>> const ORM<C, S>& placeholder();
    
    template<class C, class S = scope::MainScope<0>> StatementSelect<C, S> select();
    template<class C, class S = scope::MainScope<0>> StatementSelect<C, S> select(const Predicate& predicate);
    template<class C, class S = scope::MainScope<0>> StatementSelect<C, S> select(const std::string& sql);
    template<class C, class S = scope::MainScope<0>, class... TS> StatementSelect<C, S> select(const Column<C, TS>&... cs);

    template<class C, class S = scope::MainScope<0>> StatementInsert<C, S> insert(const C& object);
    template<class C, class S = scope::MainScope<0>> StatementInsert<C, S> insert(std::decay_t<C>&& object);
    template<class C, class S = scope::MainScope<0>> StatementInsert<C, S> insert(const std::vector<C>& objects);
    template<class C, class S = scope::MainScope<0>> StatementInsert<C, S> insert(std::vector<C>&& objects);
    template<class C, class S = scope::MainScope<0>> StatementInsert<C, S> insert(const std::vector<std::unique_ptr<C>>& objects);
    template<class C, class S = scope::MainScope<0>> StatementInsert<C, S> insert(std::vector<std::unique_ptr<C>>&& objects);
    template<class C, class S = scope::MainScope<0>> StatementInsert<C, S> replace(const C& object);
    template<class C, class S = scope::MainScope<0>> StatementInsert<C, S> replace(std::decay_t<C>&& object);
    template<class C, class S = scope::MainScope<0>> StatementInsert<C, S> replace(const std::vector<C>& objects);
    template<class C, class S = scope::MainScope<0>> StatementInsert<C, S> replace(std::vector<C>&& objects);
    template<class C, class S = scope::MainScope<0>> StatementInsert<C, S> replace(const std::vector<std::unique_ptr<C>>& objects);
    template<class C, class S = scope::MainScope<0>> StatementInsert<C, S> replace(std::vector<std::unique_ptr<C>>&& objects);

    template<class C, class S = scope::MainScope<0>> StatementUpdate<C, S> update(const Predicate& predicate);
    
    template<class C, class S = scope::MainScope<0>> StatementDelete<C, S> delete_();
    template<class C, class S = scope::MainScope<0>> StatementDelete<C, S> delete_(const Predicate& predicate);
    template<class C, class S = scope::MainScope<0>> StatementDelete<C, S> remove();
    template<class C, class S = scope::MainScope<0>> StatementDelete<C, S> remove(const Predicate& predicate);
protected:
    virtual DataBase* statementDB() = 0;
};

template<class C, class S = scope::MainScope<0>>
class SpecializedExecutor {
public:
    const ORM<C, S>& cols();
    const ORM<C, S>& placeholder();
    
    StatementSelect<C, S> select();
    StatementSelect<C, S> select(const Predicate& predicate);
    StatementSelect<C, S> select(const std::string& sql);
    template<class... TS> StatementSelect<C, S> select(const Column<C, TS>&... cs);
    
    StatementInsert<C, S> insert(const C& object);
    StatementInsert<C, S> insert(std::decay_t<C>&& object);
    StatementInsert<C, S> insert(const std::vector<C>& container);
    StatementInsert<C, S> insert(std::vector<C>&& container);
    StatementInsert<C, S> insert(const std::vector<std::unique_ptr<C>>& container);
    StatementInsert<C, S> insert(std::vector<std::unique_ptr<C>>&& container);

    StatementInsert<C, S> replace(const C& object);
    StatementInsert<C, S> replace(std::decay_t<C>&& object);
    StatementInsert<C, S> replace(const std::vector<C>& container);
    StatementInsert<C, S> replace(std::vector<C>&& container);
    StatementInsert<C, S> replace(const std::vector<std::unique_ptr<C>>& container);
    StatementInsert<C, S> replace(std::vector<std::unique_ptr<C>>&& container);

    StatementUpdate<C, S> update(const Predicate& predicate);
    
    StatementDelete<C, S> delete_();
    StatementDelete<C, S> delete_(const Predicate& predicate);
    StatementDelete<C, S> remove();
    StatementDelete<C, S> remove(const Predicate& predicate);
protected:
    virtual DataBase* statementDB() = 0;
    virtual Table<C, S>& table();
};

class DataBaseExecutor : public GenericExecutor {
public:
    explicit DataBaseExecutor(DataBase* database);
    virtual ~DataBaseExecutor();
#ifdef WWDB_ENABLE_KVTABLE
    std::string getkv(const std::string& key, const std::string& default_value = "");
    void setkv(const std::string& key, const std::string& value);
#if WWDB_ASYNC
    Promise<std::string> async_getkv(const std::string& key, const std::string& default_value = "");
#endif
#endif
protected:
    virtual DataBase* statementDB();
private:
    DataBase* statement_db_;
};

template<class C, class S = scope::MainScope<0>>
class TableExecutor : public SpecializedExecutor<C, S> {
public:
    explicit TableExecutor(DataBase* database);
    virtual ~TableExecutor();
#ifdef WWDB_ENABLE_KVTABLE
    std::string getkv(const std::string& key, const std::string& default_value = "");
    void setkv(const std::string& key, const std::string& value);
#if WWDB_ASYNC
    Promise<std::string> async_getkv(const std::string& key, const std::string& default_value = "");
#endif
#endif
protected:
    virtual DataBase* statementDB();
    const ORM<C, S>& _;
private:
    DataBase* statement_db_;
};

class DataBase : public GenericExecutor {
public:
    class Transaction {
    public:
        enum class DefaultAction {
            Commit,
            Rollback
        };
        Transaction(DataBase* database, DefaultAction action);
        ~Transaction();
        void commit();
        void rollback();
    private:
        DataBase* database_;
        DefaultAction action_;
    };
    virtual ~DataBase();
    template<class DBClass = DataBase> static std::unique_ptr<DBClass> Open(const std::string& db_path);
	template<class DBClass = DataBase> static std::unique_ptr<DBClass> Open(const std::string& db_path, const std::string& password);
    inline sqlite3* connection() { return connection_; }
    std::unique_ptr<Transaction> transaction(Transaction::DefaultAction action = Transaction::DefaultAction::Commit);
    void runInTransaction(const std::function<void(DataBase& db)>& callback);
    void beginTransaction();
    void commitTransaction();
    void rollbackTransaction();
    bool doesTableExist(const std::string& table_name);
    bool doesIndexExist(const std::string& index_name);
    bool doesColumnExist(const std::string& table_name, const std::string& column_name);
    // Always return lowercase column names.
    std::vector<std::string> existingColumns(const std::string& table_name);
    std::vector<std::string> existingIndexes(const std::string& table_name);
    bool vacuum();
#ifdef WWDB_ENABLE_KVTABLE
    std::string getKeyValue(const std::string& key, const std::string& default_value = "");
    void setKeyValue(const std::string& key, const std::string& value);
#if WWDB_ASYNC
    Promise<std::string> getKeyValueAsync(const std::string& key, const std::string& default_value = "");
#endif
#endif
    virtual void onStatementError(int errorCode, const wwdb::StatementBase* statement);
    virtual void onLogicError(const std::string& errorMessage);
    
    using TableAccessor = std::function<void*()>;
    using AlterHandler = std::function<bool()>;
    template<class C, class S = scope::MainScope<0>> Table<C, S>& table(const std::string& table_name = "", const std::string& fts_table_name = "", bool prefix_tblname_to_indexes = false);
    template<class C, class S = scope::MainScope<0>> void setAlterHandler(const std::string& column_name, const AlterHandler& alter_handler);
    typed_key_map<std::map<std::string, AlterHandler>>& alterHandlers();
#if WWDB_ASYNC
    using ReplyRunner = std::function<void(const std::function<void()>&)>;
    using TaskRunner = std::function<void(const std::function<void(const ReplyRunner&)>)>;
    bool hasTaskRunner();
    bool shouldPostTaskRunner();
    void setTaskRunner(const TaskRunner& runner);
    void runTask(const std::function<void(const ReplyRunner& replyRunner)>& task);
#endif
    
    StatementHandle* getCachedStatement(const std::string& sql);
    std::unique_ptr<StatementHandle> getUniqueStatement(const std::string& sql);
    bool execute(const std::string& sql);

    void registerHook(HookBase* hook);
    void unregisterHook(HookBase* hook);
    void registerOwnedHook(HookBase* hook);
    void callBeforeExecuteHooks(const wwdb::StatementBase& statement);
    void callAfterExecuteHooks(const wwdb::StatementBase& statement);
    void callOnErrorHooks(int errorCode, const std::string& errorMessage, const wwdb::StatementBase* statement);
    void ignoreGlobalHooks(bool value);
protected:
    static sqlite3* JustOpen(const std::string& db_path, const std::string& password = "");
    virtual void onOpen();
    virtual DataBase* statementDB() override;
    virtual bool beginTransactionImpl();
    virtual bool commitTransactionImpl();
    virtual bool rollbackTransactionImpl();
    void setKeyValueImpl(const std::string& key, const std::string& value);
private:
    DataBase(sqlite3* connection, bool connection_owner = true);
    DataBase(const DataBase& other) = delete;
    DataBase& operator=(const DataBase& other) = delete;
    friend class DataBaseCompat;
    sqlite3* connection_;
    bool connection_owner_;
    std::map<std::string, std::unique_ptr<StatementHandle>> statement_cache_;
    int transaction_nesting_ = 0;
    bool transaction_force_rollback_ = false;
    std::vector<HookBase*> hooks_;
    std::vector<std::unique_ptr<HookBase>> hook_refs_;
    bool ignore_global_hooks_ = false;
    typed_cache table_cache_;
    std::map<std::string, typed_cache> named_table_cache_;
    typed_key_map<std::map<std::string, AlterHandler>> alter_handlers_;
#if WWDB_ASYNC
    TaskRunner task_runner_;
#endif
};

// ======== TABLE ========

template<class C, class S = scope::MainScope<0>>
class Table : public TableBase, public SpecializedExecutor<C, S> {
public:
    using ObjType = C;
    using Obj = std::unique_ptr<ObjType>;
    using ObjVec = std::vector<Obj>;
    using Cols = ORM<C, S>;
    explicit Table(DataBase& db);
    Table(Table&& other);
    virtual ~Table();
    virtual void prepare() override;
protected:
    virtual DataBase* statementDB() override;
    virtual Table<C, S>& table() override;
private:
    const std::string GetPropertyTableName();
    const std::string GetPropertyFTSTableName();
};

}

// the implementations of templated classes and functions are included here.
// the internal macros used by following macros are included here.
#include "wwdb_impl.hpp"

// ======== MACRO ========

#define WWDB_TABLE(className, ...) __WWDB_TABLE(className, __VA_ARGS__)
#define WWDB_SCOPED_TABLE(className, scopeClass, ...) __WWDB_SCOPED_TABLE(className, scopeClass, __VA_ARGS__)
#define WWDB_INDEXED_TABLE(className, index, ...) __WWDB_INDEXED_TABLE(className, index, __VA_ARGS__)
#define WWDB_END __WWDB_END
#define WWDB_COLUMN(propName, ...) __WWDB_COLUMN(propName, __VA_ARGS__)
#define WWDB_COLUMN_DYN(columnName, extractFunc, ...) __WWDB_COLUMN_DYN(columnName, extractFunc, __VA_ARGS__)
#define WWDB_ON_SELECT(decodeFunc) __WWDB_ON_SELECT(decodeFunc)
#define WWDB_INDEX(indexName, ...) __WWDB_INDEX(indexName, false, __VA_ARGS__)
#define WWDB_UNIQUE_INDEX(indexName, ...) __WWDB_INDEX(indexName, true, __VA_ARGS__)
#define WWDB_PROPERTY(...) __WWDB_PROPERTY(__VA_ARGS__)
#define WWDB_SIMPLE_TABLE(className, ...) __WWDB_SIMPLE_TABLE(className, __VA_ARGS__)

#define WWDB_USE(...) __WWDB_USE(__VA_ARGS__)
#define WWDB_MAP(cols, statement) __WWDB_MAP(cols, statement)

#endif /* wwdb_hpp */
