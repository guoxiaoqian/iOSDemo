#ifndef wwdb_internal_hpp
#define wwdb_internal_hpp

#include <string>
#include <vector>
#include <deque>
#include <set>
#include <map>
#include <algorithm>
#include <functional>
#include <memory>
#include "wwdb_base.hpp"
#include "wwdb_config.hpp"

struct sqlite3;

namespace wwdb {
class ColumnBase;
class ColumnDefinition;
class Predicate;
class SetExpr;
class Subquery;
class TableBase;
class HookBase;
class StatementBase;
class StatementHandle;
class DataBase;
class DataBaseCompat;
template<class C> class ObjectFeederBase;
template<class C, class T> class Column;
template<class C, class T> class VirtualColumn;
template<class C, class T> class AggregateColumn;
template<class C, class T1, class T2> class PairColumn;
template<class C, class ...T> class TupleColumn;
template<class C, class S> class Table;
template<class C, class S> class ORM;
template<class C, class S> class StatementSelect;
template<class C, class S> class StatementInsert;
template<class C, class S> class StatementUpdate;
template<class C, class S> class StatementDelete;
    
namespace scope {
    template<int i = 0>
    class MainScope {
        
    };
}

enum class ConflictTerm {
    NotSet,
    Rollback,
    Abort,
    Fail,
    Ignore,
    Replace
};

#ifdef DEBUG
class Binder : public std::function<void(StatementBase&, int)> {
public:
    Binder(const std::function<void(StatementBase&, int)>& functor, const std::string& description);
    std::string description() const;
private:
    std::string description_;
};
#else
typedef std::function<void(StatementBase&, int)> Binder;
#endif
using BindList = std::vector<Binder>;

class SqlBase {
public:
    virtual ~SqlBase();
    using BindList = std::vector<Binder>;
    virtual size_t bindStatement(StatementBase& s) const;
    virtual bool moveNext();
    virtual size_t bindCount() const;
    bool isValid() const {
        return !expression_.empty();
    }
    inline const std::string& expression() const { return expression_; }
    inline const BindList& bindList() const { return bind_list_; }
protected:
    SqlBase();
    BindList bind_list_;
    std::string expression_;
    friend class StatementSelectBase;
};

class ColumnBase : public SqlBase {
public:
    ColumnBase() : column_name_("") { }
    inline bool isValid() const { return !column_name_.empty(); }
    inline const std::string& column_name() const { return column_name_; }
    const std::string& quoted_column_name() const;
protected:
    explicit ColumnBase(const std::string& column_name) : column_name_(column_name) { }
    std::string column_name_;
    mutable std::string quoted_column_name_;
};

class ColumnConstraint {
public:
    // note: DO NOT change the order!
    enum class ConstraintType {
        ColumnName,
        __ImplicitColumnNameHere,
        Blob,
        __ImplicitColumnTypeHere,
        DefaultValue,
        Primary,
        NotNull,
        Unique,
        AutoIncrement,
        DanglingColumn,
        FullTextSearchDocId,
        FullTextSearchColumn,
        DynamicValue,
        End // should be the last one
    };
    ColumnConstraint(const ConstraintType& type);
    ColumnConstraint(const char* name);
    ColumnConstraint(const std::string& name);
    ColumnConstraint(const ConstraintType& type, const std::string& content);
    bool operator<(const ColumnConstraint& other) const;
public:
    ConstraintType type_;
    std::string column_name_;
    std::string default_value_;
};

class ColumnDefinition : public ColumnBase {
public:
    ColumnDefinition(const std::string& default_column_name, const std::string& default_type_name, const std::vector<ColumnConstraint>& constraints);
    static ColumnDefinition DoNotUse() { return ColumnDefinition(); }
    std::string fragment() const { return expression(); }
    bool isBlob() const { return is_blob_; }
    bool isAutoIncrement() const { return is_autoincrement_; }
    bool isPrimary() const { return is_primary_; }
    bool isDanglingColumn() const { return is_dangling_column_; }
    bool isDynamicValue() const { return is_dynamic_value_; }
    const std::string& ftsColumnName() const { return fts_column_name_; }
private:
    ColumnDefinition() { }
    bool is_blob_ = false;
    bool is_autoincrement_ = false;
    bool is_primary_ = false;
    bool is_dangling_column_ = false;
    bool is_dynamic_value_ = false;
    std::string fts_column_name_;
};
    
enum class OrderTerm {
    NotSet,
    ASC,
    DESC
};
typedef std::pair<std::string, OrderTerm> ColumnOrderTerm;

template<class C, class S = wwdb::scope::MainScope<0>>
class ORM {};
    
class TableProperty {
public:
    enum class PropertyType {
        TableName,
        FTS3TableName,
        FTS4TableName,
        DoNotCreateOrAlter
    };
    enum class FTSModule {
        None,
        FTS3,
        FTS4
    };
    enum class FTSTokenize {
        Simple,
        Porter,
        ICU
    };
    TableProperty(const char* table_name);
    TableProperty(const std::string& table_name);
    TableProperty(const PropertyType& type);
    TableProperty(const PropertyType& type, const std::string& table_name, const FTSTokenize tokenize);
    bool operator<(const TableProperty& other) const;
    static std::string TokenizeString(const FTSTokenize tokenize);
public:
    PropertyType type_ = PropertyType::TableName;
    std::string table_name_;
    FTSModule fts_module_ = FTSModule::None;
    FTSTokenize fts_tokenize_ = FTSTokenize::Simple;
};

class TableIndex : public SqlBase {
public:
    TableIndex(const std::string& index_name, const bool unique, const std::initializer_list<ColumnDefinition>& columns) : index_name_(index_name), columns_(columns), unique_(unique) {
        columns_.pop_back();
    }
    inline const std::string& index_name() const { return index_name_; }
    inline const std::vector<ColumnDefinition>& columns() const { return columns_; }
    inline const bool unique() const { return unique_; }
protected:
    std::string index_name_;
    std::vector<ColumnDefinition> columns_;
    const bool unique_ = false;
};

class TableBase {
public:
    virtual void prepare() = 0;
    bool createOrAlter();
    bool createOrAlter(const std::function<bool(const std::string& column_name)>& alter_column_handler);
    bool createFTSTable();
    bool rebuildIndex(const std::function<void()>& operations);
    bool dropIfExist();
    bool translateMatchPredicate(std::string& predicate) const;
    sqlite3* connection() const;
    inline const std::string& tableName() const { return table_name_; }
    inline void setTableName(const std::string& table_name) { table_name_ = table_name; }
    inline void setFTSTableName(const std::string& table_name) { fts_table_name_ = table_name; }
    inline void setPrefixIndexes(bool prefix_tblname_to_indexes) { prefix_tblname_to_indexes_ = prefix_tblname_to_indexes; }
    inline bool doNotCreateOrAlter() { return do_not_create_or_alter_; }
    inline DataBase& db() const { return db_; }
    inline const std::vector<ColumnDefinition>* columnDefinitions() const { return column_definitions_; }
    inline const std::vector<TableIndex>* tableIndexes() const { return table_indexes_; }
protected:
    TableBase(DataBase& db, const std::string& table_name, const std::vector<TableProperty>& properties = {});
    TableBase(TableBase&& other);
    const std::string& ftsTableName();
    bool createIndex();
    bool createFTS3Table();
    bool createFTS4Table();
    DataBase& db_;
    std::string table_name_;
    std::string fts_table_name_;
    bool prefix_tblname_to_indexes_ = false;
    TableProperty::FTSModule fts_module_ = TableProperty::FTSModule::None;
    TableProperty::FTSTokenize fts_tokenize_ = TableProperty::FTSTokenize::Simple;
    const std::vector<ColumnDefinition>* column_definitions_ = nullptr;
    const std::vector<TableIndex>* table_indexes_ = nullptr;
    bool do_not_create_or_alter_ = false;
    bool prepared_ = false;
};

// ======== STATEMENT ========

class StatementBase : public SqlBase {
public:
    using StatementHandler = std::function<bool(StatementBase&)>;
    explicit StatementBase(DataBase& database, const std::string& sql = "");
    explicit StatementBase(TableBase& table);
    DataBase& database() const;
    const TableBase* table() const;
    const std::string& sql() const;
    const bool cacheable() const;
    const uint64_t changes() const;
    StatementHandle* handle();
    bool step();
    bool run();
    int checkError(int err);
protected:
    bool shouldExecuteInDestructor() const;
    bool markExecuted();
    DataBase& database_;
    TableBase* table_ = nullptr;
    StatementHandle* handle_ = nullptr;
    std::shared_ptr<StatementHandle> handle_owned_;
    std::string sql_;
    bool cacheable_ = true;
    std::shared_ptr<bool> executed_;
    uint64_t changes_ = 0;
};

template<class C, class S>
class StatementTypeBase {
public:
    typedef std::function<void(StatementBase&, int, C&, const ColumnDefinition*)> Decoder;
    typedef std::function<wwdb::Binder(const C&, bool, const ColumnDefinition*)> Encoder;
    StatementTypeBase();
    const std::vector<std::string>& columnNames() const;
    const std::vector<ColumnDefinition>& definitions() const;
    const std::vector<Decoder>& decoders() const;
    const std::vector<Encoder>& encoders() const;
};

class StatementRunBase : public StatementBase {
public:

    using StatementBase::StatementBase;
    bool execute(const std::string& sql);
    bool executeSync(const std::string& sql);
protected:
    std::string conflictAsString(const ConflictTerm conflict);
};

// ======== SELECT ========
    
class StatementSelectBase : public StatementBase {
public:
    explicit StatementSelectBase(TableBase& table);
    StatementSelectBase(TableBase& table, const Predicate& predicate);
    StatementSelectBase(TableBase& table, const std::string& sql);
    StatementSelectBase& distinct();
    StatementSelectBase& where(const Predicate& predicate);
    StatementSelectBase& orderBy(const ColumnBase& column, OrderTerm desc = OrderTerm::NotSet);
    StatementSelectBase& orderBy(const ColumnOrderTerm& columnOrderTerm);
    StatementSelectBase& limit(const int& limit);
    StatementSelectBase& offset(const int& offset);
    StatementSelectBase& groupBy(const ColumnBase& column);
    StatementSelectBase& having(const Predicate& predicate);
    size_t count();
    bool execute(const StatementHandler& handler);
    operator Subquery();
protected:
    std::string makeSql();
    bool is_count_query_ = false;
    std::vector<std::string> column_names_;
    bool distinct_ = false;
    entity_ptr<Predicate> where_;
    std::vector<ColumnOrderTerm> orderBy_;
    int limit_ = 0;
    int offset_ = 0;
    std::vector<ColumnBase> groupBy_;
    entity_ptr<Predicate> having_;
};

template<class C, class S>
class StatementSelect : public StatementSelectBase, public StatementTypeBase<C, S> {
public:
    using StatementSelectBase::StatementSelectBase;
    template<class T> StatementSelect& column(const Column<C, T>& column);
    template<class T1, class... TS> StatementSelect& column(const Column<C, T1>& c1, const Column<C, TS>&... cs);
    StatementSelect& defaultColumns();
    void fillColumnsIfEmpty();
    std::unique_ptr<C> one();
    bool one(C& result);
    std::vector<std::unique_ptr<C>> all();
    std::vector<C> allraw();
    void all(std::vector<C>&);
    void all(std::vector<std::unique_ptr<C>>&);
    void each(std::function<bool(const C&)> handler);
    template<class R> std::vector<R> map(std::function<R(const C&)> handler);
    operator std::unique_ptr<C>();
    operator std::vector<std::unique_ptr<C>>();
    operator std::vector<C>();
#if WWDB_ASYNC
    Promise<std::vector<C>> async_all();
    Promise<std::shared_ptr<C>> async_one();
    Promise<size_t> async_count();
#endif
    StatementSelect& distinct();
    StatementSelect& where(const Predicate& predicate);
    StatementSelect& orderBy(const ColumnBase& column, OrderTerm desc = OrderTerm::NotSet);
    StatementSelect& orderBy(const ColumnOrderTerm& column);
    StatementSelect& orderBy(const ColumnOrderTerm& column, const ColumnOrderTerm& cs...);
    StatementSelect& limit(const int& limit);
    StatementSelect& offset(const int& offset);
    StatementSelect& groupBy(const ColumnBase& column);
    StatementSelect& having(const Predicate& predicate);
protected:
    std::string makeSql();
    std::vector<typename StatementTypeBase<C, S>::Decoder> column_decoders_;
    std::vector<const ColumnDefinition*> column_definitions_;
};

// ======== INSERT ========
    
class StatementInsertBase : public StatementRunBase {
public:
    using StatementRunBase::StatementRunBase;
    ~StatementInsertBase();
    StatementInsertBase& batch(bool batch);
    StatementInsertBase& reindex(bool reindex);
    StatementInsertBase& conflict(ConflictTerm);
    StatementInsertBase& includesAutoIncrement(bool includesAutoIncrement);
    bool execute();
protected:
    std::string makeSql(int slice = 1);
    bool shouldInsertColumn(int i) const;
    bool executeInternal();
    bool executePiecewise(const std::string& sql, int slice, int times);
    ConflictTerm conflict_ = ConflictTerm::NotSet;
    bool enable_batch_insert_ = true;
    bool rebuild_table_index_ = false;
    bool includes_autoincrement_ = false;
    size_t bind_offset_ = 0;
    std::vector<std::string> column_names_;
    std::set<int> column_autoincrement_index_;
};

template<class C, class S>
class StatementInsert : public StatementInsertBase, public StatementTypeBase<C, S> {
public:
    using StatementInsertBase::StatementInsertBase;
    StatementInsert(TableBase& table, const C& obj);
    StatementInsert(TableBase& table, std::decay_t<C>&& obj);
    StatementInsert(TableBase& table, const std::vector<C>& objs);
    StatementInsert(TableBase& table, std::vector<C>&& objs);
    StatementInsert(TableBase& table, const std::vector<std::unique_ptr<C>>& objs);
    StatementInsert(TableBase& table, std::vector<std::unique_ptr<C>>&& objs);
    ~StatementInsert();
    StatementInsert& batch(bool batch);
    StatementInsert& reindex(bool reindex);
    StatementInsert& conflict(ConflictTerm conflictTerm);
    StatementInsert& includesAutoIncrement(bool includesAutoIncrement);
    StatementInsert& object(const C& obj);
    StatementInsert& object(std::decay_t<C>&& obj);
    template<typename Container> StatementInsert& objects(const Container& container);
    template<typename Container> StatementInsert& objects(Container&& container);
    template<typename Container> StatementInsert& objectRefs(const Container& container);
    template<typename Container> StatementInsert& objectRefs(Container&& container);

    bool execute();
    virtual size_t bindStatement(StatementBase& s) const override;
    virtual bool moveNext() override;
    virtual size_t bindCount() const override;
protected:
    void prepareColumns();
    std::deque<std::shared_ptr<ObjectFeederBase<C>>> obj_feeders_;
};

// ======== UPDATE ========
    
class StatementUpdateBase : public StatementRunBase {
public:
    using StatementRunBase::StatementRunBase;
    StatementUpdateBase(TableBase& table, const Predicate& where);
    ~StatementUpdateBase();
    StatementUpdateBase& conflict(ConflictTerm);
    StatementUpdateBase& where(const Predicate& predicate);
    StatementUpdateBase& set(const SetExpr& setexpr);
    bool execute();
protected:
    virtual std::string makeSql();
    ConflictTerm conflict_ = ConflictTerm::NotSet;
    entity_ptr<Predicate> where_;
    std::vector<SetExpr> sets_;
};
    
template<class C, class S>
class StatementUpdate : public StatementUpdateBase, public StatementTypeBase<C, S> {
public:
    using StatementUpdateBase::StatementUpdateBase;
    StatementUpdate& conflict(ConflictTerm conflictTerm);
    StatementUpdate& where(const Predicate& predicate);
    StatementUpdate& set(const SetExpr& setexpr);
    StatementUpdate& set(const SetExpr& setexpr, const SetExpr& setexprs...);
    StatementUpdate& set(const C& obj);
};
    
// ======== DELETE ========
    
class StatementDeleteBase : public StatementRunBase {
public:
    using StatementRunBase::StatementRunBase;
    explicit StatementDeleteBase(TableBase& table);
    StatementDeleteBase(TableBase& table, const Predicate& where);
    ~StatementDeleteBase();
    StatementDeleteBase& where(const Predicate& predicate);
    bool execute();
protected:
    std::string makeSql();
    entity_ptr<Predicate> where_;
};
    
template<class C, class S>
class StatementDelete : public StatementDeleteBase, public StatementTypeBase<C, S> {
public:
    using StatementDeleteBase::StatementDeleteBase;
    StatementDelete& where(const Predicate& predicate);
};
    
// ======== HOOK ========
    
class HookBase {
public:
    virtual ~HookBase();
    virtual void beforeExecute(const StatementBase& statement);
    virtual void afterExecute(const StatementBase& statement);
    virtual void onError(int errorCode, const std::string errorMessage, const StatementBase* statement);
    static void registerGlobalHook(HookBase* hook);
    static void unregisterGlobalHook(HookBase* hook);
    static std::vector<HookBase*>& globalHooks();
};

}

#endif /* wwdb_internal_hpp */
