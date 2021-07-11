#ifndef wwdb_impl_hpp
#define wwdb_impl_hpp

#include <string>
#include <vector>
#include <algorithm>
#include <functional>

namespace wwdb {
    
// ======== UTILITY DECLARE ========
    
extern std::string fillArgument(const bool& v);
extern std::string fillArgument(const int32_t& v);
extern std::string fillArgument(const uint32_t& v);
extern std::string fillArgument(const int64_t& v);
extern std::string fillArgument(const uint64_t& v);
extern std::string fillArgument(const double& v);
extern std::string fillArgument(const std::string& v);
extern Binder bindArgument(const bool& v, bool copy = true, const ColumnDefinition* c = nullptr);
extern Binder bindArgument(const int32_t& v, bool copy = true, const ColumnDefinition* c = nullptr);
extern Binder bindArgument(const uint32_t& v, bool copy = true, const ColumnDefinition* c = nullptr);
extern Binder bindArgument(const int64_t& v, bool copy = true, const ColumnDefinition* c = nullptr);
extern Binder bindArgument(const uint64_t& v, bool copy = true, const ColumnDefinition* c = nullptr);
extern Binder bindArgument(const double& v, bool copy = true, const ColumnDefinition* c = nullptr);
extern Binder bindArgument(const std::string& v, bool copy = true, const ColumnDefinition* c = nullptr);
extern bool retrieveArgument(StatementBase& s, int col, bool* dummy, const ColumnDefinition* c = nullptr);
extern int32_t retrieveArgument(StatementBase& s, int col, int32_t* dummy, const ColumnDefinition* c = nullptr);
extern uint32_t retrieveArgument(StatementBase& s, int col, uint32_t* dummy, const ColumnDefinition* c = nullptr);
extern int64_t retrieveArgument(StatementBase& s, int col, int64_t* dummy, const ColumnDefinition* c = nullptr);
extern uint64_t retrieveArgument(StatementBase& s, int col, uint64_t* dummy, const ColumnDefinition* c = nullptr);
extern double retrieveArgument(StatementBase& s, int col, double* dummy, const ColumnDefinition* c = nullptr);
extern std::string retrieveArgument(StatementBase& s, int col, std::string* dummy, const ColumnDefinition* c = nullptr);
extern std::string fragmentType(const bool* dummy);
extern std::string fragmentType(const int32_t* dummy);
extern std::string fragmentType(const uint32_t* dummy);
extern std::string fragmentType(const int64_t* dummy);
extern std::string fragmentType(const uint64_t* dummy);
extern std::string fragmentType(const double* dummy);
extern std::string fragmentType(const std::string* dummy);
extern std::string quote(const std::string& identifier);
extern std::string escapelike(const std::string& text);
    
// ======== ORM ========
    
template<class className, class scopeClass>
class ORMBase {
    typedef typename StatementTypeBase<className, scopeClass>::Decoder _decoder_;
    typedef typename StatementTypeBase<className, scopeClass>::Encoder _encoder_;
public:
    typedef className _cls_;
    class StaticFields {
    public:
        StaticFields(const std::string& in_class_name, std::vector<TableProperty>&& tableProperties) : class_name(in_class_name), properties(tableProperties) { }
        template<class ColumnType> void initField(ColumnType& column, uint32_t order) {
            if (columns.find(&column) != columns.end()) return;
            size_t index = std::count_if(column_orders.begin(), column_orders.end(), [&](uint32_t i){ return i < order; });
            columns.insert(&column);
            column_orders.insert(column_orders.begin() + index, order);
            column_names.insert(column_names.begin() + index, column.column_name());
            decoders.insert(decoders.begin() + index, column.decoder());
            encoders.insert(encoders.begin() + index, column.encoder());
            definitions.insert(definitions.begin() + index, column.definition());
        }
        std::string class_name;
        std::set<ColumnBase*> columns;
        std::vector<uint32_t> column_orders;
        std::vector<std::string> column_names;
        std::vector<_decoder_> decoders;
        std::vector<_encoder_> encoders;
        std::vector<ColumnDefinition> definitions;
        std::vector<TableIndex> indexes;
        std::vector<TableProperty> properties;
    };
};
    
// ======== FEEDER ========
    
template<class C>
class ObjectFeederBase {
public:
    virtual ~ObjectFeederBase();
    virtual const C* operator()() const = 0;
    virtual bool moveNext() = 0;
    virtual size_t count() const = 0;
};

template<class C>
class ObjectFeeder : public ObjectFeederBase<C> {
public:
    explicit ObjectFeeder(const C* obj);
    explicit ObjectFeeder(const C& obj);
    explicit ObjectFeeder(C&& obj);
    virtual const C* operator()() const override;
    virtual bool moveNext() override;
    virtual size_t count() const override;
private:
    const C* ptr_ = nullptr;
    std::shared_ptr<C> obj_ref_;
};

template<class C, class Container>
class ObjectFeederContainer : public ObjectFeederBase<C> {
public:
    explicit ObjectFeederContainer(const Container* container);
    explicit ObjectFeederContainer(const Container& container);
    explicit ObjectFeederContainer(Container&& container);
    virtual const C* operator()() const override;
    virtual bool moveNext() override;
    virtual size_t count() const override;
private:
    const Container* container_ = nullptr;
    std::shared_ptr<Container> container_ref_;
    typename Container::const_iterator iter_;
};

template<class C, class Container>
class ObjectFeederRefContainer : public ObjectFeederBase<C> {
public:
    explicit ObjectFeederRefContainer(const Container* container);
    explicit ObjectFeederRefContainer(const Container& container);
    explicit ObjectFeederRefContainer(Container&& container);
    virtual const C* operator()() const override;
    virtual bool moveNext() override;
    virtual size_t count() const override;
private:
    const Container* container_;
    std::shared_ptr<Container> container_ref_;
    typename Container::const_iterator iter_;
};
    
template<class C>
ObjectFeederBase<C>::~ObjectFeederBase() {
    ;
}

template<class C>
ObjectFeeder<C>::ObjectFeeder(const C* obj) {
    ptr_ = obj;
}

template<class C>
ObjectFeeder<C>::ObjectFeeder(const C& obj) {
    obj_ref_ = std::make_shared<C>(obj);
    ptr_ = obj_ref_.get();
}

template<class C>
ObjectFeeder<C>::ObjectFeeder(C&& obj) {
    obj_ref_ = std::make_shared<C>(std::move(obj));
    ptr_ = obj_ref_.get();
}

template<class C>
const C* ObjectFeeder<C>::operator()() const {
    return ptr_;
}

template<class C>
bool ObjectFeeder<C>::moveNext() {
    return false;
}

template<class C>
size_t ObjectFeeder<C>::count() const {
    return ptr_ ? 1 : 0;
}

template<class C, class Container>
ObjectFeederContainer<C, Container>::ObjectFeederContainer(const Container* container) {
    container_ = container;
    iter_ = container_->begin();
}

template<class C, class Container>
ObjectFeederContainer<C, Container>::ObjectFeederContainer(const Container& container) {
    container_ref_ = std::make_shared<Container>(container);
    container_ = container_ref_.get();
    iter_ = container_->begin();
}

template<class C, class Container>
ObjectFeederContainer<C, Container>::ObjectFeederContainer(Container&& container) {
    container_ref_ = std::make_shared<Container>(std::move(container));
    container_ = container_ref_.get();
    iter_ = container_->begin();
}

template<class C, class Container>
const C* ObjectFeederContainer<C, Container>::operator()() const {
    if (iter_ != container_->end()) {
        return &*iter_;
    }
    return nullptr;
}
    
template<class C, class Container>
bool ObjectFeederContainer<C, Container>::moveNext() {
    if (iter_ != container_->end()) {
        ++iter_;
        if (iter_ != container_->end()) {
            return true;
        }
    }
    return false;
}
    
template<class C, class Container>
size_t ObjectFeederContainer<C, Container>::count() const {
    return container_ ? container_->size() : 0;
}

template<class C, class Container>
ObjectFeederRefContainer<C, Container>::ObjectFeederRefContainer(const Container* container) {
    container_ = container;
    iter_ = container_->begin();
}

template<class C, class Container>
ObjectFeederRefContainer<C, Container>::ObjectFeederRefContainer(const Container& container) {
    container_ref_ = std::make_shared<Container>(container);
    container_ = container_ref_.get();
    iter_ = container_->begin();
}

template<class C, class Container>
ObjectFeederRefContainer<C, Container>::ObjectFeederRefContainer(Container&& container) {
    container_ref_ = std::make_shared<Container>(std::move(container));
    container_ = container_ref_.get();
    iter_ = container_->begin();
}

template<class C, class Container>
const C* ObjectFeederRefContainer<C, Container>::operator()() const {
    if (iter_ != container_->end()) {
        return (*iter_).get();
    }
    return nullptr;
}

template<class C, class Container>
bool ObjectFeederRefContainer<C, Container>::moveNext() {
    if (iter_ != container_->end()) {
        ++iter_;
        return true;
    }
    return false;
}

template<class C, class Container>
size_t ObjectFeederRefContainer<C, Container>::count() const {
    return container_ ? container_->size() : 0;
}

// ======== COLUMN ========
    
inline const std::string& ColumnBase::quoted_column_name() const {
    if (!column_name_.empty() && quoted_column_name_.empty()) {
        quoted_column_name_ = quote(column_name_);
    }
    return quoted_column_name_;
}
    
template<class C, class T>
Column<C, T>::Column(const std::string& default_column_name,
       const std::initializer_list<ColumnConstraint>& constraints,
       const typename Column::Decoder& decoder, const typename Column::Encoder& encoder)
    : ColumnBase(extractColumnNameConstraint(default_column_name, constraints)),
      constraints_(prepareColumnConstraint(constraints)),
      definition_(ColumnDefinition(column_name(), fragmentType((T*)nullptr), constraints_)),
      decoder_(decoder), encoder_(encoder) {
    ;
}

template<class C, class T>
const std::string& Column<C, T>::extractColumnNameConstraint(const std::string& default_name, const std::initializer_list<ColumnConstraint>& constraints) {
    for (auto& constraint : constraints) {
        if (constraint.type_ == ColumnConstraint::ConstraintType::ColumnName) {
            return constraint.column_name_;
        }
    }
    return default_name;
}

template<class C, class T>
std::vector<ColumnConstraint> Column<C, T>::prepareColumnConstraint(const std::initializer_list<ColumnConstraint>& constraints) {
    std::vector<ColumnConstraint> v(constraints);
    std::sort(v.begin(), v.end());
    v.push_back(ColumnConstraint::ConstraintType::End);
    return v;
}
    
template<class Container>
Predicate::Predicate(const ColumnBase& column, const std::string& prefix, const std::string& suffix, const Container& binders, bool cacheable)
: Predicate(column, prefix, suffix) {
    for (auto& b : binders) bind_list_.push_back(b);
    cacheable_ = cacheable;
}

template<class C, class T>
Predicate Column<C, T>::operator==(const T& arg) {
    return Predicate(*this, "= ?", bindArgument(arg));
}

template<class C, class T>
Predicate Column<C, T>::operator>(const T& arg) {
#if WWDB_UINT64_CUSTOM_FUNCTIONS
    if (std::is_same<T, uint64_t>::value) {
        return Predicate(*this, "UINT64_GT(", ", ?)", bindArgument(arg));
    }
#endif
    return Predicate(*this, "> ?", bindArgument(arg));
}

template<class C, class T>
Predicate Column<C, T>::operator<(const T& arg) {
#if WWDB_UINT64_CUSTOM_FUNCTIONS
    if (std::is_same<T, uint64_t>::value) {
        return Predicate(*this, "UINT64_LT(", ", ?)", bindArgument(arg));
    }
#endif
    return Predicate(*this, "< ?", bindArgument(arg));
}

template<class C, class T>
Predicate Column<C, T>::operator<=(const T& arg) {
#if WWDB_UINT64_CUSTOM_FUNCTIONS
    if (std::is_same<T, uint64_t>::value) {
        return Predicate(*this, "UINT64_LTEQ(", ", ?)", bindArgument(arg));
    }
#endif
    return Predicate(*this, "<= ?", bindArgument(arg));
}

template<class C, class T>
Predicate Column<C, T>::operator>=(const T& arg) {
#if WWDB_UINT64_CUSTOM_FUNCTIONS
    if (std::is_same<T, uint64_t>::value) {
        return Predicate(*this, "UINT64_GTEQ(", ", ?)", bindArgument(arg));
    }
#endif
    return Predicate(*this, ">= ?", bindArgument(arg));
}

template<class C, class T>
Predicate Column<C, T>::operator!=(const T& arg) {
    return Predicate(*this, "!= ?", bindArgument(arg));
}

template<class C, class T>
Predicate Column<C, T>::isNull() {
    return Predicate(*this, "IS NULL");
}

template<class C, class T>
Predicate Column<C, T>::like(const T& arg) {
    return Predicate(*this, "LIKE ? ESCAPE '\\'", bindArgument(arg));
}

template<class C, class T>
Predicate Column<C, T>::glob(const T& arg) {
    return Predicate(*this, "GLOB ? ESCAPE '\\'", bindArgument(arg));
}

template<class C, class T>
Predicate Column<C, T>::match(const T& arg) {
    return Predicate(*this, "[[WWDB_FTS_DOCID]] IN (SELECT docid FROM [[WWDB_FTS_TABLE]] WHERE", "MATCH ?)", bindArgument(arg));
}

template<class C, class T>
Predicate Column<C, T>::matchlike(const T& matcharg, const T& likearg) {
    return Predicate(*this, "[[WWDB_FTS_DOCID]] IN (SELECT docid FROM [[WWDB_FTS_TABLE]] WHERE", "MATCH ? GROUP BY docid HAVING " + quoted_column_name() + " LIKE ? ESCAPE '\\')", bindArgument(matcharg), bindArgument(likearg));
}

template<class C, class T>
Predicate Column<C, T>::between(const T& lower, const T& upper) {
#if WWDB_UINT64_CUSTOM_FUNCTIONS
    static_assert(!std::is_same<T, uint64_t>::value, "uint64 should not be used in between expression!");
#endif
    return Predicate(*this, "BETWEEN ? AND ?", bindArgument(lower), bindArgument(upper));
}

template<class C, class T>
Predicate Column<C, T>::notBetween(const T& lower, const T& upper) {
#if WWDB_UINT64_CUSTOM_FUNCTIONS
    static_assert(!std::is_same<T, uint64_t>::value, "uint64 should not be used in between expression!");
#endif
    return Predicate(*this, "NOT BETWEEN ? AND ?", bindArgument(lower), bindArgument(upper));
}

template<class C, class T>
Predicate Column<C, T>::in(const std::initializer_list<T>& container) {
    return expandInitializer<std::initializer_list<T>>("IN", container);
}

template<class C, class T>
Predicate Column<C, T>::in(const Subquery& subquery) {
    return Predicate(*this, "", std::string("IN (").append(subquery.expression()).append(")"), subquery.bindList(), false);
}

template<class C, class T> template<class Container>
Predicate Column<C, T>::in(const Container& container) {
    return expandInitializer("IN", container);
}

template<class C, class T>
Predicate Column<C, T>::notIn(const std::initializer_list<T>& container) {
    return expandInitializer<std::initializer_list<T>>("NOT IN", container);
}
    
template<class C, class T>
Predicate Column<C, T>::notIn(const Subquery& subquery) {
    return Predicate(*this, "", std::string("NOT IN (").append(subquery.expression()).append(")"), subquery.bindList(), false);
}

template<class C, class T> template<class Container>
Predicate Column<C, T>::notIn(const Container& container) {
    return expandInitializer("NOT IN", container);
}

template<class C, class T>
SetExpr Column<C, T>::operator=(const T& arg) {
    return SetExpr(*this, bindArgument(arg));
}

template<class C, class T>
VirtualColumn<C, T> Column<C, T>::operator+(const T& arg) {
    static_assert((std::is_same<decltype(*(T*)nullptr + arg), T>::value, true), "operator+ is not supported for class T");
    return VirtualColumn<C, T>(*this, std::string(quoted_column_name()).append(" + ?"), bindArgument(arg));
}

template<class C, class T>
VirtualColumn<C, T> Column<C, T>::operator-(const T& arg) {
    static_assert((std::is_same<decltype(*(T*)nullptr - arg), T>::value, true), "operator- is not supported for class T");
    return VirtualColumn<C, T>(*this, std::string(quoted_column_name()).append(" - ?"), bindArgument(arg));
}

template<class C, class T>
VirtualColumn<C, T> Column<C, T>::operator*(const T& arg) {
    static_assert((std::is_same<decltype(*(T*)nullptr * arg), T>::value, true), "operator* is not supported for class T");
    return VirtualColumn<C, T>(*this, std::string(quoted_column_name()).append(" * ?"), bindArgument(arg));
}

template<class C, class T>
VirtualColumn<C, T> Column<C, T>::operator/(const T& arg) {
    static_assert((std::is_same<decltype(*(T*)nullptr / arg), T>::value, true), "operator/ is not supported for class T");
    return VirtualColumn<C, T>(*this, std::string(quoted_column_name()).append(" / ?"), bindArgument(arg));
}

template<class C, class T>
VirtualColumn<C, T> Column<C, T>::operator%(const T& arg) {
    static_assert((std::is_same<decltype(*(T*)nullptr % arg), T>::value, true), "operator% is not supported for class T");
    return VirtualColumn<C, T>(*this, std::string(quoted_column_name()).append(" % ?"), bindArgument(arg));
}

template<class C, class T>
VirtualColumn<C, T> Column<C, T>::operator&(const T& arg) {
    static_assert((std::is_same<decltype(*(T*)nullptr & arg), T>::value, true), "operator& is not supported for class T");
    return VirtualColumn<C, T>(*this, std::string(quoted_column_name()).append(" & ?"), bindArgument(arg));
}

template<class C, class T>
VirtualColumn<C, T> Column<C, T>::operator|(const T& arg) {
    static_assert((std::is_same<decltype(*(T*)nullptr | arg), T>::value, true), "operator| is not supported for class T");
    return VirtualColumn<C, T>(*this, std::string(quoted_column_name()).append(" | ?"), bindArgument(arg));
}

template<class C, class T>
VirtualColumn<C, T> Column<C, T>::operator~() {
    static_assert((std::is_same<decltype(~*(T*)nullptr), T>::value, true), "operator~ is not supported for class T");
    return VirtualColumn<C, T>(*this, std::string("~").append(quoted_column_name()));
}

template<class C, class T>
VirtualColumn<C, uint64_t> Column<C, T>::length() {
    return VirtualColumn<C, uint64_t>(*this, std::string("length(").append(quoted_column_name()).append(")"));
}
    
template<class C, class T>
VirtualColumn<C, std::string> Column<C, T>::lower() {
    return VirtualColumn<C, std::string>(*this, std::string("lower(").append(quoted_column_name()).append(")"));
}

template<class C, class T>
VirtualColumn<C, std::string> Column<C, T>::upper() {
    return VirtualColumn<C, std::string>(*this, std::string("upper(").append(quoted_column_name()).append(")"));
}

template<class C, class T>
VirtualColumn<C, std::string> Column<C, T>::substr(int begin, int length) {
    // In SQLite, the left-most character of X is number 1. So we add 1 to 'begin' below.
    if (length == -1) {
        return VirtualColumn<C, std::string>(*this, std::string("substr(").append(quoted_column_name()).append(", ?)"), bindArgument(begin + 1));
    } else {
        return VirtualColumn<C, std::string>(*this, std::string("substr(").append(quoted_column_name()).append(", ?, ?)"), bindArgument(begin + 1), bindArgument(length));
    }
}

template<class C, class T>
VirtualColumn<C, std::string> Column<C, T>::trim() {
    return VirtualColumn<C, std::string>(*this, std::string("trim(").append(quoted_column_name()).append(")"));
}

template<class C, class T>
VirtualColumn<C, T> Column<C, T>::self() {
    return VirtualColumn<C, T>(*this);
}

template<class C, class T>
AggregateColumn<C, uint64_t> Column<C, T>::count() {
    return AggregateColumn<C, uint64_t>(*this, std::string("count(").append(quoted_column_name()).append(")"));
}

template<class C, class T>
AggregateColumn<C, T> Column<C, T>::avg() {
    return AggregateColumn<C, T>(*this, std::string("avg(").append(quoted_column_name()).append(")"));
}

template<class C, class T>
AggregateColumn<C, T> Column<C, T>::max() {
    return AggregateColumn<C, T>(*this, std::string("max(").append(quoted_column_name()).append(")"));
}

template<class C, class T>
AggregateColumn<C, T> Column<C, T>::min() {
    return AggregateColumn<C, T>(*this, std::string("min(").append(quoted_column_name()).append(")"));
}

template<class C, class T>
AggregateColumn<C, T> Column<C, T>::sum() {
    return AggregateColumn<C, T>(*this, std::string("sum(").append(quoted_column_name()).append(")"));
}

template<class C, class T>
AggregateColumn<C, T> Column<C, T>::total() {
    return AggregateColumn<C, T>(*this, std::string("total(").append(quoted_column_name()).append(")"));
}

template<class C, class T>
ColumnOrderTerm Column<C, T>::asc() {
    return std::make_pair(quoted_column_name(), OrderTerm::ASC);
}

template<class C, class T>
ColumnOrderTerm Column<C, T>::desc() {
    return std::make_pair(quoted_column_name(), OrderTerm::DESC);
}

template<class C, class T> template<class Container>
Predicate Column<C, T>::expandInitializer(const std::string& keyword, const Container& container) {
    std::vector<Binder> binders;
    std::string expr(keyword);
    expr.append(" (");
    int i = 0;
    // only expand as placeholder when size equal or less than WWDB_MAX_IN_PLACEHOLDER(default 100).
    bool expand_as_placeholder = container.size() <= (WWDB_MAX_IN_PLACEHOLDER);
    for (auto& arg : container) {
        if (i++ > 0) expr.append(", ");
        if (expand_as_placeholder) {
            expr.append("?");
            binders.push_back(bindArgument(arg));
        } else {
            expr.append(fillArgument(arg));
        }
    }
    expr.append(")");
    return Predicate(*this, "", expr, binders, false);
}

template<class C, class T> template<class T2>
PairColumn<C, T, T2> Column<C, T>::operator,(const Column<C, T2>& next) {
    return PairColumn<C, T, T2>(*this, next);
}

// ======== Virtual Column ========

template<class C, class T>
VirtualColumn<C, T>::VirtualColumn(const std::string& expression)
    : Column<C, T>(expression,
                   { ColumnConstraint::ConstraintType::DanglingColumn },
                   [=](wwdb::StatementBase& s, int col, C& obj, const ColumnDefinition* c){ rows.emplace_back(retrieveArgument(s, col, (T*)nullptr, c)); },
                   [=](const C& obj, bool copy, const ColumnDefinition* c){ return bindArgument(rows.back(), true, c); })
{
    ;
}

template<class C, class T>
VirtualColumn<C, T>::VirtualColumn(const Column<C, T>& column) 
    : VirtualColumn<C, T>(column, column.quoted_column_name()) 
{
    ;
}
    
template<class C, class T>
VirtualColumn<C, T>::VirtualColumn(const ColumnBase& column, const std::string& expression)
    : VirtualColumn<C, T>(expression)
{
    if (!column.bindList().empty()) {
        this->bind_list_ = column.bindList();
    }
}

template<class C, class T>
VirtualColumn<C, T>::VirtualColumn(const ColumnBase& column, const std::string& expression, const Binder& binder)
    : VirtualColumn<C, T>(column, expression)
{
    this->bind_list_.push_back(binder);
}
    
template<class C, class T>
VirtualColumn<C, T>::VirtualColumn(const ColumnBase& column, const std::string& expression, const Binder& binder1, const Binder& binder2)
    : VirtualColumn<C, T>(column, expression, binder1)
{
    this->bind_list_.push_back(binder2);
}

template<class C, class T>
T& VirtualColumn<C, T>::value() {
    return rows.back();
}

// ======== Pair Column ========

template<class C, class T1, class T2>
PairColumn<C, T1, T2>::PairColumn(const Column<C, T1>& c1, const Column<C, T2>& c2)
    : ColumnBase(std::string("(").append(c1.quoted_column_name()).append(", ").append(c2.quoted_column_name()).append(")")),
      columns_(std::make_pair(c1, c2))
{
    ;
}

template<class C, class T1, class T2>
Predicate PairColumn<C, T1, T2>::in(const std::initializer_list<std::pair<T1, T2>>& container) {
    return expandInitializer<std::initializer_list<std::pair<T1, T2>>>("IN", container);
}

template<class C, class T1, class T2> template<class Container>
Predicate PairColumn<C, T1, T2>::in(const Container& container) {
    return expandInitializer("IN", container);
}

template<class C, class T1, class T2>
Predicate PairColumn<C, T1, T2>::notIn(const std::initializer_list<std::pair<T1, T2>>& container) {
    return expandInitializer<std::initializer_list<std::pair<T1, T2>>>("NOT IN", container);
}

template<class C, class T1, class T2> template<class Container>
Predicate PairColumn<C, T1, T2>::notIn(const Container& container) {
    return expandInitializer("NOT IN", container);
}

template<class C, class T1, class T2> template<class T3>
TupleColumn<C, T1, T2, T3> PairColumn<C, T1, T2>::operator,(const Column<C, T3>& next) {
    return TupleColumn<C, T1, T2, T3>(columns_.first, columns_.second, next);
}

template<class C, class T1, class T2> template<class Container>
Predicate PairColumn<C, T1, T2>::expandInitializer(const std::string& keyword, const Container& container) {
    std::vector<Binder> binders;
    std::string expr(keyword);
    expr.append(" (VALUES ");
    int i = 0;
    // only expand as placeholder when size equal or less than WWDB_MAX_IN_PLACEHOLDER(default 100).
    bool expand_as_placeholder = container.size() <= (WWDB_MAX_IN_PLACEHOLDER);
    for (auto& arg : container) {
        if (i++ > 0) expr.append(", ");
        expr.append("(");
        if (expand_as_placeholder) {
            expr.append("?");
            binders.push_back(bindArgument(arg.first));
            expr.append(", ?");
            binders.push_back(bindArgument(arg.second));
        } else {
            expr.append(fillArgument(arg.first));
            expr.append(", ");
            expr.append(fillArgument(arg.second));
        }
        expr.append(")");
    }
    expr.append(")");
    return Predicate(*this, "", expr, binders, false);
}

// ======== Tuple Column ========

static std::string varidicColumnNameHelper(const std::initializer_list<std::string>& quoted_column_names) {
    std::string result("(");
    int i = 0;
    for (auto& name : quoted_column_names) {
        if (i++ > 0) result.append(", ");
        result.append(name);
    }
    result.append(")");
    return result;
}

template<class T, int N>
struct tupleColumnNameHelper {
    static void make(const T& tuple, std::string& result) {
        tupleColumnNameHelper<T, N - 1>::make(tuple, result);
        result.append(", ");
        result.append(std::get<N>(tuple).quoted_column_name());
    }
};

template<class T>
struct tupleColumnNameHelper<T, 0> {
    static void make(const T& tuple, std::string& result) {
        result.append(std::get<0>(tuple).quoted_column_name());
    }
};

template <typename T>
std::string makeTupleColumnName(const T& tuple) {
    std::string result("(");
    tupleColumnNameHelper<T, std::tuple_size<T>::value - 1>::make(tuple, result);
    result.append(")");
    return result;
}

template<class C, class ...T>
TupleColumn<C, T...>::TupleColumn(const Column<C, T>& ...cs)
    : ColumnBase(varidicColumnNameHelper({ cs.quoted_column_name()... })),
      columns_(std::make_tuple(cs...))
{
    ;
}

template<class C, class ...T>
TupleColumn<C, T...>::TupleColumn(const std::tuple<Column<C, T>...>& tuple)
    : ColumnBase(makeTupleColumnName(tuple)),
      columns_(tuple)
{
    ;
}

template<class C, class ...T>
Predicate TupleColumn<C, T...>::in(const std::initializer_list<std::tuple<T...>>& container) {
    return expandInitializer<std::initializer_list<std::tuple<T...>>>("IN", container);
}

template<class C, class ...T> template<class Container>
Predicate TupleColumn<C, T...>::in(const Container& container) {
    return expandInitializer("IN", container);
}

template<class C, class ...T>
Predicate TupleColumn<C, T...>::notIn(const std::initializer_list<std::tuple<T...>>& container) {
    return expandInitializer<std::initializer_list<std::tuple<T...>>>("NOT IN", container);
}

template<class C, class ...T> template<class Container>
Predicate TupleColumn<C, T...>::notIn(const Container& container) {
    return expandInitializer("NOT IN", container);
}

template<class C, class ...T> template<class TN>
TupleColumn<C, T..., TN> TupleColumn<C, T...>::operator,(const Column<C, TN>& next) {
    return TupleColumn<C, T..., TN>(std::tuple_cat(columns_, std::make_tuple(next)));
}

template<class T, int N>
struct bindTupleHelper {
    static void bind(const T& tuple, std::string& expr, std::vector<Binder>& binders) {
        bindTupleHelper<T, N - 1>::bind(tuple, expr, binders);
        expr.append(", ?");
        binders.push_back(bindArgument(std::get<N>(tuple)));
    }
};

template<class T>
struct bindTupleHelper<T, 0> {
    static void bind(const T& tuple, std::string& expr, std::vector<Binder>& binders) {
        expr.append("?");
        binders.push_back(bindArgument(std::get<0>(tuple)));
    }
};

template <typename T>
void bindTuple(const T& tuple, std::string& expr, std::vector<Binder>& binders) {
    return bindTupleHelper<T, std::tuple_size<T>::value - 1>::bind(tuple, expr, binders);
}

template<class T, int N>
struct fillTupleHelper {
    static void fill(const T& tuple, std::string& expr) {
        fillTupleHelper<T, N - 1>::fill(tuple, expr);
        expr.append(", ");
        expr.append(fillArgument(std::get<N>(tuple)));
    }
};

template<class T>
struct fillTupleHelper<T, 0> {
    static void fill(const T& tuple, std::string& expr) {
        expr.append(fillArgument(std::get<0>(tuple)));
    }
};

template <typename T>
void fillTuple(const T& tuple, std::string& expr) {
    return fillTupleHelper<T, std::tuple_size<T>::value - 1>::fill(tuple, expr);
}

template<class C, class ...T> template<class Container>
Predicate TupleColumn<C, T...>::expandInitializer(const std::string& keyword, const Container& container) {
    std::vector<Binder> binders;
    std::string expr(keyword);
    expr.append(" (VALUES ");
    int i = 0;
    // only expand as placeholder when size equal or less than WWDB_MAX_IN_PLACEHOLDER(default 100).
    bool expand_as_placeholder = container.size() <= (WWDB_MAX_IN_PLACEHOLDER);
    for (auto& arg : container) {
        if (i++ > 0) expr.append(", ");
        expr.append("(");
        if (expand_as_placeholder) {
            bindTuple(arg, expr, binders);
        } else {
            fillTuple(arg, expr);
        }
        expr.append(")");
    }
    expr.append(")");
    return Predicate(*this, "", expr, binders, false);
}

// ======== EXECUTOR ========

template<class C, class S>
const ORM<C, S>& GenericExecutor::cols() {
    return placeholder<C, S>();
}

template<class C, class S>
const ORM<C, S>& GenericExecutor::placeholder() {
    static ORM<C, S> placeholder;
    return placeholder;
}

template<class C, class S>
StatementSelect<C, S> GenericExecutor::select() {
    StatementSelect<C, S> statement(statementDB()->table<C, S>());
    return statement;
}

template<class C, class S>
StatementSelect<C, S> GenericExecutor::select(const Predicate& predicate) {
    StatementSelect<C, S> statement(statementDB()->table<C, S>(), predicate);
    return statement;
}

template<class C, class S>
StatementSelect<C, S> GenericExecutor::select(const std::string& sql) {
    StatementSelect<C, S> statement(statementDB()->table<C, S>(), sql);
    return statement;
}
    
template<class C, class S, class... TS>
StatementSelect<C, S> GenericExecutor::select(const Column<C, TS>&... cs) {
    StatementSelect<C, S> statement(statementDB()->table<C, S>());
    statement.column(cs...);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> GenericExecutor::insert(const C& object) {
    StatementInsert<C, S> statement(statementDB()->table<C, S>(), object);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> GenericExecutor::insert(std::decay_t<C>&& object) {
    StatementInsert<C, S> statement(statementDB()->table<C, S>(), std::move(object));
    return statement;
}

template<class C, class S>
StatementInsert<C, S> GenericExecutor::insert(const std::vector<C>& objects) {
    StatementInsert<C, S> statement(statementDB()->table<C, S>(), objects);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> GenericExecutor::insert(std::vector<C>&& objects) {
    StatementInsert<C, S> statement(statementDB()->table<C, S>(), std::move(objects));
    return statement;
}

template<class C, class S>
StatementInsert<C, S> GenericExecutor::insert(const std::vector<std::unique_ptr<C>>& objects) {
    StatementInsert<C, S> statement(statementDB()->table<C, S>(), objects);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> GenericExecutor::insert(std::vector<std::unique_ptr<C>>&& objects) {
    StatementInsert<C, S> statement(statementDB()->table<C, S>(), std::move(objects));
    return statement;
}

template<class C, class S>
StatementInsert<C, S> GenericExecutor::replace(const C& object) {
    StatementInsert<C, S> statement(statementDB()->table<C, S>(), object);
    statement.conflict(ConflictTerm::Replace);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> GenericExecutor::replace(std::decay_t<C>&& object) {
    StatementInsert<C, S> statement(statementDB()->table<C, S>(), std::move(object));
    statement.conflict(ConflictTerm::Replace);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> GenericExecutor::replace(const std::vector<C>& objects) {
    StatementInsert<C, S> statement(statementDB()->table<C, S>(), objects);
    statement.conflict(ConflictTerm::Replace);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> GenericExecutor::replace(std::vector<C>&& objects) {
    StatementInsert<C, S> statement(statementDB()->table<C, S>(), std::move(objects));
    statement.conflict(ConflictTerm::Replace);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> GenericExecutor::replace(std::vector<std::unique_ptr<C>>&& objects) {
    StatementInsert<C, S> statement(statementDB()->table<C, S>(), std::move(objects));
    statement.conflict(ConflictTerm::Replace);
    return statement;
}

template<class C, class S>
StatementUpdate<C, S> GenericExecutor::update(const Predicate& predicate) {
    StatementUpdate<C, S> statement(statementDB()->table<C, S>(), predicate);
    return statement;
}

template<class C, class S>
StatementDelete<C, S> GenericExecutor::delete_() {
    StatementDelete<C, S> statement(statementDB()->table<C, S>());
    return statement;
}

template<class C, class S>
StatementDelete<C, S> GenericExecutor::delete_(const Predicate& predicate) {
    StatementDelete<C, S> statement(statementDB()->table<C, S>(), predicate);
    return statement;
}

template<class C, class S>
StatementDelete<C, S> GenericExecutor::remove() {
    StatementDelete<C, S> statement(statementDB()->table<C, S>());
    return statement;
}

template<class C, class S>
StatementDelete<C, S> GenericExecutor::remove(const Predicate& predicate) {
    StatementDelete<C, S> statement(statementDB()->table<C, S>(), predicate);
    return statement;
}

// ======== Specialized ========
    
template<class C, class S>
const ORM<C, S>& SpecializedExecutor<C, S>::cols() {
    return statementDB()->template cols<C, S>();
}

template<class C, class S>
const ORM<C, S>& SpecializedExecutor<C, S>::placeholder() {
    return statementDB()->template placeholder<C, S>();
}

template<class C, class S>
StatementSelect<C, S> SpecializedExecutor<C, S>::select() {
    StatementSelect<C, S> statement(table());
    return statement;
}

template<class C, class S>
StatementSelect<C, S> SpecializedExecutor<C, S>::select(const Predicate& predicate) {
    StatementSelect<C, S> statement(table(), predicate);
    return statement;
}

template<class C, class S>
StatementSelect<C, S> SpecializedExecutor<C, S>::select(const std::string& sql) {
    StatementSelect<C, S> statement(table(), sql);
    return statement;
}

template<class C, class S> template<class... TS>
StatementSelect<C, S> SpecializedExecutor<C, S>::select(const Column<C, TS>&... cs) {
    StatementSelect<C, S> statement(table());
    statement.column(cs...);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> SpecializedExecutor<C, S>::insert(const C& object) {
    StatementInsert<C, S> statement(table(), object);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> SpecializedExecutor<C, S>::insert(std::decay_t<C>&& object) {
    StatementInsert<C, S> statement(table(), std::move(object));
    return statement;
}

template<class C, class S>
StatementInsert<C, S> SpecializedExecutor<C, S>::insert(const std::vector<C>& container) {
    StatementInsert<C, S> statement(table(), container);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> SpecializedExecutor<C, S>::insert(std::vector<C>&& container) {
    StatementInsert<C, S> statement(table(), std::move(container));
    return statement;
}

template<class C, class S>
StatementInsert<C, S> SpecializedExecutor<C, S>::insert(const std::vector<std::unique_ptr<C>>& container) {
    StatementInsert<C, S> statement(table(), container);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> SpecializedExecutor<C, S>::insert(std::vector<std::unique_ptr<C>>&& container) {
    StatementInsert<C, S> statement(table(), std::move(container));
    return statement;
}

template<class C, class S>
StatementInsert<C, S> SpecializedExecutor<C, S>::replace(const C& object) {
    StatementInsert<C, S> statement(table(), object);
    statement.conflict(ConflictTerm::Replace);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> SpecializedExecutor<C, S>::replace(std::decay_t<C>&& object) {
    StatementInsert<C, S> statement(table(), std::move(object));
    statement.conflict(ConflictTerm::Replace);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> SpecializedExecutor<C, S>::replace(const std::vector<C>& container) {
    StatementInsert<C, S> statement(table(), container);
    statement.conflict(ConflictTerm::Replace);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> SpecializedExecutor<C, S>::replace(std::vector<C>&& container) {
    StatementInsert<C, S> statement(table(), std::move(container));
    statement.conflict(ConflictTerm::Replace);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> SpecializedExecutor<C, S>::replace(const std::vector<std::unique_ptr<C>>& container) {
    StatementInsert<C, S> statement(table(), container);
    statement.conflict(ConflictTerm::Replace);
    return statement;
}

template<class C, class S>
StatementInsert<C, S> SpecializedExecutor<C, S>::replace(std::vector<std::unique_ptr<C>>&& container) {
    StatementInsert<C, S> statement(table(), std::move(container));
    statement.conflict(ConflictTerm::Replace);
    return statement;
}

template<class C, class S>
StatementUpdate<C, S> SpecializedExecutor<C, S>::update(const Predicate& predicate) {
    StatementUpdate<C, S> statement(table(), predicate);
    return statement;
}

template<class C, class S>
StatementDelete<C, S> SpecializedExecutor<C, S>::delete_() {
    StatementDelete<C, S> statement(table());
    return statement;
}

template<class C, class S>
StatementDelete<C, S> SpecializedExecutor<C, S>::delete_(const Predicate& predicate) {
    StatementDelete<C, S> statement(table(), predicate);
    return statement;
}

template<class C, class S>
StatementDelete<C, S> SpecializedExecutor<C, S>::remove() {
    StatementDelete<C, S> statement(table());
    return statement;
}

template<class C, class S>
StatementDelete<C, S> SpecializedExecutor<C, S>::remove(const Predicate& predicate) {
    StatementDelete<C, S> statement(table(), predicate);
    return statement;
}

template<class C, class S>
Table<C, S>& SpecializedExecutor<C, S>::table() {
    return statementDB()->template table<C, S>();
}

template<class C, class S>
TableExecutor<C, S>::TableExecutor(DataBase* database)
    : _(database->template cols<C, S>()), statement_db_(database) {
    ;
}

template<class C, class S>
TableExecutor<C, S>::~TableExecutor() {
    ;
}

template<class C, class S>
DataBase* TableExecutor<C, S>::statementDB() {
    return statement_db_;
}

#ifdef WWDB_ENABLE_KVTABLE
template<class C, class S>
std::string TableExecutor<C, S>::getkv(const std::string& key, const std::string& default_value) {
    return statementDB()->getKeyValue(key, default_value);
}

template<class C, class S>
void TableExecutor<C, S>::setkv(const std::string& key, const std::string& value) {
    statementDB()->setKeyValue(key, value);
}
    
#if WWDB_ASYNC
template<class C, class S>
Promise<std::string> TableExecutor<C, S>::async_getkv(const std::string& key, const std::string& default_value) {
    return statementDB()->getKeyValueAsync(key, default_value);
}
#endif
#endif

// ======== DATABASE ========
    
template<class DBClass>
std::unique_ptr<DBClass> DataBase::Open(const std::string& db_path) {
	return Open<DBClass>(db_path, "");
}

template<class DBClass>
std::unique_ptr<DBClass> DataBase::Open(const std::string& db_path, const std::string& password) {
	sqlite3* connection = JustOpen(db_path, password);
	if (connection) {
		std::unique_ptr<DBClass> ptr(new DBClass(connection));
		ptr->onOpen();
		return ptr;
	}
	else {
		return nullptr;
	}
}

template<class C, class S>
Table<C, S>& DataBase::table(const std::string& table_name, const std::string& fts_table_name, bool prefix_tblname_to_indexes) {
    typed_cache& table_cache = table_name.empty() ? table_cache_ : named_table_cache_[table_name];
    Table<C, S>* cached_table = table_cache.get<Table<C, S>>();
    if (cached_table) {
        return *cached_table;
    } else {
        Table<C, S>* table_instance = table_cache.set(Table<C, S>(*this));
        if (!table_name.empty()) table_instance->setTableName(table_name);
        if (!fts_table_name.empty()) table_instance->setFTSTableName(fts_table_name);
        if (prefix_tblname_to_indexes) table_instance->setPrefixIndexes(prefix_tblname_to_indexes);
        return *table_instance;
    }
}
    
template<class C, class S>
void DataBase::setAlterHandler(const std::string& column_name, const AlterHandler& alter_handler) {
    auto handlers = alter_handlers_.use<Table<C, S>>();
    (*handlers)[column_name] = alter_handler;
}

// ======== STATEMENT ========

template<class C, class S>
StatementTypeBase<C, S>::StatementTypeBase() {
    ORM<C, S>::ensure_initialized();
}

template<class C, class S>
const std::vector<std::string>& StatementTypeBase<C, S>::columnNames() const {
    return ORM<C, S>::static_fields().column_names;
}

template<class C, class S>
const std::vector<ColumnDefinition>& StatementTypeBase<C, S>::definitions() const {
    return ORM<C, S>::static_fields().definitions;
}

template<class C, class S>
const std::vector<typename StatementTypeBase<C, S>::Decoder>& StatementTypeBase<C, S>::decoders() const {
    return ORM<C, S>::static_fields().decoders;
}

template<class C, class S>
const std::vector<typename StatementTypeBase<C, S>::Encoder>& StatementTypeBase<C, S>::encoders() const {
    return ORM<C, S>::static_fields().encoders;
}

//#pragma mark - ======== SELECT ========

template<class C, class S> template<class T>
StatementSelect<C, S>& StatementSelect<C, S>::column(const Column<C, T>& column) {
    column_names_.push_back(column.column_name());
    column_decoders_.push_back(column.decoder());
    column_definitions_.push_back(&column.definition());
    bind_list_.insert(bind_list_.end(), column.bindList().begin(), column.bindList().end());
    return *this;
}
    
template<class C, class S> template<class T1, class... TS>
StatementSelect<C, S>& StatementSelect<C, S>::column(const Column<C, T1>& c1, const Column<C, TS>&... cs) {
    column(c1);
    return column(cs...);
}

template<class C, class S>
StatementSelect<C, S>& StatementSelect<C, S>::defaultColumns() {
    auto& definitions = this->definitions();
    auto& decoders = this->decoders();
    for (size_t i = 0; i < decoders.size(); ++i) {
        if (!definitions[i].isDanglingColumn()) {
            column_names_.push_back(definitions[i].column_name());
            column_decoders_.push_back(decoders[i]);
            column_definitions_.push_back(&definitions[i]);
        }
    }
    return *this;
}

template<class C, class S>
void StatementSelect<C, S>::fillColumnsIfEmpty() {
    if (column_names_.empty() || column_decoders_.empty()) {
        defaultColumns();
    }
}

template <class T, class C>
static auto _call_on_decode_helper(C& o, T*, int) -> decltype(T::_on_decode(o)) { T::_on_decode(o); }
template <class T, class C>
static void _call_on_decode_helper(C& o, T*, long) { /* do nothing */ }
template <class T, class C>
static void _call_on_decode(C& o) { _call_on_decode_helper(o, (T*)nullptr, 0); }

template<class C, class S>
std::unique_ptr<C> StatementSelect<C, S>::one() {
    std::unique_ptr<C> result;
    fillColumnsIfEmpty();
    execute([&](StatementBase& s){
        result.reset(new C);
        for (size_t i = 0; i < column_decoders_.size(); ++i) {
            column_decoders_[i](s, i, *result, column_definitions_[i]);
        }
        _call_on_decode<ORM<C, S>>(*result);
        return false;
    });
    return result;
}

template<class C, class S>
bool StatementSelect<C, S>::one(C& result) {
    bool got = false;
    fillColumnsIfEmpty();
    execute([&](StatementBase& s){
        for (size_t i = 0; i < column_decoders_.size(); ++i) {
            column_decoders_[i](s, i, result, column_definitions_[i]);
        }
        got = true;
        _call_on_decode<ORM<C, S>>(result);
        return false;
    });
    return got;
}

template<class C, class S>
std::vector<std::unique_ptr<C>> StatementSelect<C, S>::all() {
    std::vector<std::unique_ptr<C>> results;
    fillColumnsIfEmpty();
    execute([&](StatementBase& s){
        results.push_back(std::unique_ptr<C>());
        results.back().reset(new C);
        for (size_t i = 0; i < column_decoders_.size(); ++i) {
            column_decoders_[i](s, i, *results.back(), column_definitions_[i]);
        }
        _call_on_decode<ORM<C, S>>(*results.back());
        return true;
    });
    return results;
}

template<class C, class S>
std::vector<C> StatementSelect<C, S>::allraw() {
    std::vector<C> results;
    fillColumnsIfEmpty();
    execute([&](StatementBase& s){
        results.push_back(C());
        for (size_t i = 0; i < column_decoders_.size(); ++i) {
            column_decoders_[i](s, i, results.back(), column_definitions_[i]);
        }
        _call_on_decode<ORM<C, S>>(results.back());
        return true;
    });
    return results;
}

template<class C, class S>
void StatementSelect<C, S>::all(std::vector<C>& results) {
    fillColumnsIfEmpty();
    execute([&](StatementBase& s){
        results.push_back(C());
        for (size_t i = 0; i < column_decoders_.size(); ++i) {
            column_decoders_[i](s, i, results.back(), column_definitions_[i]);
        }
        _call_on_decode<ORM<C, S>>(results.back());
        return true;
    });
}

template<class C, class S>
void StatementSelect<C, S>::all(std::vector<std::unique_ptr<C>>& results) {
    fillColumnsIfEmpty();
    execute([&](StatementBase& s){
        results.push_back(std::unique_ptr<C>(new C));
        for (size_t i = 0; i < column_decoders_.size(); ++i) {
            column_decoders_[i](s, i, *results.back(), column_definitions_[i]);
        }
        _call_on_decode<ORM<C, S>>(*results.back());
        return true;
    });
}

template<class C, class S>
void StatementSelect<C, S>::each(std::function<bool(const C&)> handler) {
    fillColumnsIfEmpty();
    execute([&](StatementBase& s){
        C obj;
        for (size_t i = 0; i < column_decoders_.size(); ++i) {
            column_decoders_[i](s, i, obj, column_definitions_[i]);
        }
        _call_on_decode<ORM<C, S>>(obj);
        return handler(obj);
    });
}
    
template<class C, class S> template<class R>
std::vector<R> StatementSelect<C, S>::map(std::function<R(const C&)> handler) {
    std::vector<R> results;
    each([&](const C &o){
        results.emplace_back(handler(o));
        return true;
    });
    return results;
}

template<class C, class S>
StatementSelect<C, S>::operator std::unique_ptr<C>() {
    return one();
}

template<class C, class S>
StatementSelect<C, S>::operator std::vector<std::unique_ptr<C>>() {
    return all();
}
    
template<class C, class S>
StatementSelect<C, S>::operator std::vector<C>() {
    return allraw();
}

#if WWDB_ASYNC
template<class C, class S>
Promise<std::vector<C>> StatementSelect<C, S>::async_all() {
    Promise<std::vector<C>> p;
    database().runTask([p, thiz = std::move(*this)](const DataBase::ReplyRunner& replyRunner) mutable {
        auto results = std::make_shared<std::vector<C>>();
        thiz.all(*results);
        replyRunner([p, results](){
            p.resolve(std::move(*results));
        });
    });
    return p;
}

template<class C, class S>
Promise<std::shared_ptr<C>> StatementSelect<C, S>::async_one() {
    Promise<std::shared_ptr<C>> p;
    database().runTask([p, thiz = std::move(*this)](const DataBase::ReplyRunner& replyRunner) mutable {
        std::shared_ptr<C> result(thiz.one().release());
        replyRunner([p, r = std::move(result)](){
            p.resolve(std::move(r));
        });
    });
    return p;
}

template<class C, class S>
Promise<size_t> StatementSelect<C, S>::async_count() {
    Promise<size_t> p;
    database().runTask([p, thiz = std::move(*this)](const DataBase::ReplyRunner& replyRunner) mutable {
        auto result = thiz.count();
        replyRunner([p](){
            p.resolve(result);
        });
    });
    return p;
}
#endif

template<class C, class S>
StatementSelect<C, S>& StatementSelect<C, S>::distinct() {
    StatementSelectBase::distinct();
    return *this;
}

template<class C, class S>
StatementSelect<C, S>& StatementSelect<C, S>::where(const Predicate& predicate) {
    StatementSelectBase::where(predicate);
    return *this;
}

template<class C, class S>
StatementSelect<C, S>& StatementSelect<C, S>::orderBy(const ColumnBase& column, OrderTerm desc) {
    StatementSelectBase::orderBy(column, desc);
    return *this;
}

template<class C, class S>
StatementSelect<C, S>& StatementSelect<C, S>::orderBy(const ColumnOrderTerm& column) {
    StatementSelectBase::orderBy(column);
    return *this;
}

template<class C, class S>
StatementSelect<C, S>& StatementSelect<C, S>::orderBy(const ColumnOrderTerm& column, const ColumnOrderTerm& cs...) {
    StatementSelectBase::orderBy(column);
    return orderBy(cs);
}

template<class C, class S>
StatementSelect<C, S>& StatementSelect<C, S>::limit(const int& limit) {
    StatementSelectBase::limit(limit);
    return *this;
}

template<class C, class S>
StatementSelect<C, S>& StatementSelect<C, S>::offset(const int& offset) {
    StatementSelectBase::offset(offset);
    return *this;
}
    
template<class C, class S>
StatementSelect<C, S>& StatementSelect<C, S>::groupBy(const ColumnBase& column) {
    StatementSelectBase::groupBy(column);
    return *this;
}
    
template<class C, class S>
StatementSelect<C, S>& StatementSelect<C, S>::having(const Predicate& predicate) {
    StatementSelectBase::having(predicate);
    return *this;
}

// ======== INSERT ========

template<class C, class S>
StatementInsert<C, S>::StatementInsert(TableBase& table, const C& obj) : StatementInsertBase(table) {
    object(obj);
}

template<class C, class S>
StatementInsert<C, S>::StatementInsert(TableBase& table, std::decay_t<C>&& obj) : StatementInsertBase(table) {
    object(std::move(obj));
}

template<class C, class S>
StatementInsert<C, S>::StatementInsert(TableBase& table, const std::vector<C>& objs) : StatementInsertBase(table) {
    objects(objs);
}

template<class C, class S>
StatementInsert<C, S>::StatementInsert(TableBase& table, std::vector<C>&& objs) : StatementInsertBase(table) {
    objects(std::move(objs));
}

template<class C, class S>
StatementInsert<C, S>::StatementInsert(TableBase& table, const std::vector<std::unique_ptr<C>>& objs) : StatementInsertBase(table) {
    objectRefs(objs);
}

template<class C, class S>
StatementInsert<C, S>::StatementInsert(TableBase& table, std::vector<std::unique_ptr<C>>&& objs) : StatementInsertBase(table) {
    objectRefs(std::move(objs));
}

template<class C, class S>
StatementInsert<C, S>::~StatementInsert() {
    if (shouldExecuteInDestructor()) execute();
}

template<class C, class S>
StatementInsert<C, S>& StatementInsert<C, S>::batch(bool batch) {
    StatementInsertBase::batch(batch);
    return *this;
}

template<class C, class S>
StatementInsert<C, S>& StatementInsert<C, S>::reindex(bool reindex) {
    StatementInsertBase::reindex(reindex);
    return *this;
}

template<class C, class S>
StatementInsert<C, S>& StatementInsert<C, S>::conflict(ConflictTerm conflictTerm) {
    StatementInsertBase::conflict(conflictTerm);
    return *this;
}

template<class C, class S>
StatementInsert<C, S>& StatementInsert<C, S>::includesAutoIncrement(bool includesAutoIncrement) {
    StatementInsertBase::includesAutoIncrement(includesAutoIncrement);
    return *this;
}

template<class C, class S>
StatementInsert<C, S>& StatementInsert<C, S>::object(const C& obj) {
    prepareColumns();
#if WWDB_ASYNC
    if (database().shouldPostTaskRunner()) {
        obj_feeders_.emplace_back(std::make_shared<ObjectFeeder<C>>(obj));
    } else {
        obj_feeders_.emplace_back(std::make_shared<ObjectFeeder<C>>(&obj));
    }
#else
	obj_feeders_.emplace_back(std::make_shared<ObjectFeeder<C>>(&obj));
#endif
    return *this;
}

template<class C, class S>
StatementInsert<C, S>& StatementInsert<C, S>::object(std::decay_t<C>&& obj) {
    prepareColumns();
    obj_feeders_.emplace_back(std::make_shared<ObjectFeeder<C>>(std::move(obj)));
    return *this;
}

template<class C, class S>
template<typename Container>
StatementInsert<C, S>& StatementInsert<C, S>::objects(const Container& container) {
    prepareColumns();
#if WWDB_ASYNC
    if (database().shouldPostTaskRunner()) {
        obj_feeders_.emplace_back(std::make_shared<ObjectFeederContainer<C, Container>>(container));
    } else {
        obj_feeders_.emplace_back(std::make_shared<ObjectFeederContainer<C, Container>>(&container));
    }
#else
	obj_feeders_.emplace_back(std::make_shared<ObjectFeederContainer<C, Container>>(&container));
#endif
    return *this;
}

template<class C, class S>
template<typename Container>
StatementInsert<C, S>& StatementInsert<C, S>::objects(Container&& container) {
    prepareColumns();
    obj_feeders_.emplace_back(std::make_shared<ObjectFeederContainer<C, Container>>(std::move(container)));
    return *this;
}

template<class C, class S>
template<typename Container>
StatementInsert<C, S>& StatementInsert<C, S>::objectRefs(const Container& container) {
    prepareColumns();
#if WWDB_ASYNC
    if (database().shouldPostTaskRunner()) {
        obj_feeders_.emplace_back(std::make_shared<ObjectFeederRefContainer<C, Container>>(container));
    } else {
        obj_feeders_.emplace_back(std::make_shared<ObjectFeederRefContainer<C, Container>>(&container));
    }
#else
	obj_feeders_.emplace_back(std::make_shared<ObjectFeederRefContainer<C, Container>>(&container));
#endif
    return *this;
}

template<class C, class S>
template<typename Container>
StatementInsert<C, S>& StatementInsert<C, S>::objectRefs(Container&& container) {
    prepareColumns();
    obj_feeders_.emplace_back(std::make_shared<ObjectFeederRefContainer<C, Container>>(std::move(container)));
    return *this;
}

template<class C, class S>
void StatementInsert<C, S>::prepareColumns() {
    auto& columnNames = this->columnNames();
    auto& definitions = this->definitions();
    if (column_names_.empty()) {
        for (size_t i = 0; i < columnNames.size(); ++i) {
            column_names_.push_back(columnNames[i]);
            if (definitions[i].isAutoIncrement()) {
                column_autoincrement_index_.insert(i);
            }
        }
    }
}

template<class C, class S>
bool StatementInsert<C, S>::execute() {
#if WWDB_ASYNC
    if (database().shouldPostTaskRunner()) {
        database().runTask([thiz = std::move(*this)](const DataBase::ReplyRunner&) mutable {
            thiz.StatementInsertBase::execute();
        });
        executed_.reset();
        return true;
    }
#endif
    return StatementInsertBase::execute();
}

template<class C, class S>
size_t StatementInsert<C, S>::bindStatement(StatementBase& s) const {
    size_t offset = bind_offset_;
    for (auto& feeder : obj_feeders_) {
        const C* obj = (*feeder)();
        if (obj) {
            auto& encoders = this->encoders();
            auto& definitions = this->definitions();
            int columnIndex = 0;
            for (size_t i = 0; i < encoders.size(); ++i) {
                if (shouldInsertColumn(i)) {
                    encoders[i](*obj, false, &definitions[i])(s, columnIndex + (int)offset);
                    ++columnIndex;
                }
            }
            return columnIndex;
        }
    }
    return 0;
}

template<class C, class S>
bool StatementInsert<C, S>::moveNext() {
    while (!obj_feeders_.empty()) {
        auto& feeder = obj_feeders_.front();
        if (feeder->moveNext()) {
            return true;
        } else {
            obj_feeders_.pop_front();
            if (!obj_feeders_.empty() && obj_feeders_.front()->count()) {
                return true;
            }
        }
    }
    return false;
}

template<class C, class S>
size_t StatementInsert<C, S>::bindCount() const {
    size_t size = 0;
    for (auto& feeder : obj_feeders_) {
        size += feeder->count();
    }
    return size;
}

// ======== UPDATE ========

template<class C, class S>
StatementUpdate<C, S>& StatementUpdate<C, S>::conflict(ConflictTerm conflictTerm) {
    StatementUpdateBase::conflict(conflictTerm);
    return *this;
}

template<class C, class S>
StatementUpdate<C, S>& StatementUpdate<C, S>::where(const Predicate& predicate) {
    StatementUpdateBase::where(predicate);
    return *this;
}

template<class C, class S>
StatementUpdate<C, S>& StatementUpdate<C, S>::set(const SetExpr& setexpr) {
    StatementUpdateBase::set(setexpr);
    return *this;
}

template<class C, class S>
StatementUpdate<C, S>& StatementUpdate<C, S>::set(const SetExpr& setexpr, const SetExpr& setexprs...) {
    StatementUpdateBase::set(setexpr);
    return set(setexprs);
}
    
template<class C, class S>
StatementUpdate<C, S>& StatementUpdate<C, S>::set(const C& obj) {
    auto& definitions = this->definitions();
    auto& encoders = this->encoders();
    for (int i = 0; i < encoders.size(); ++i) {
        if (!definitions[i].isAutoIncrement()) {
            set(definitions[i], encoders[i](obj));
        }
    }
    return *this;
}

// ======== DELETE ========

template<class C, class S>
StatementDelete<C, S>& StatementDelete<C, S>::where(const Predicate& predicate) {
    StatementDeleteBase::where(predicate);
    return *this;
}

// ======== TABLE ========

template<class C, class S>
Table<C, S>::Table(DataBase& db) : TableBase(db, Cols::static_fields().class_name, Cols::static_fields().properties) {
    Cols::ensure_initialized();
    column_definitions_ = &Cols::static_fields().definitions;
    table_indexes_ = &Cols::static_fields().indexes;
}

template<class C, class S>
Table<C, S>::Table(Table&& other) : TableBase(std::forward<TableBase>(other)) {
    column_definitions_ = std::move(other.column_definitions_);
    table_indexes_ = std::move(other.table_indexes_);
}
    
template<class C, class S>
Table<C, S>::~Table() {
    ;
}

template<class C, class S>
void Table<C, S>::prepare() {
    if (!prepared_) {
        prepared_ = true;
        if (!doNotCreateOrAlter() && tableName() != "sqlite_master") {
            auto handlers = db_.alterHandlers().template get<Table<C, S>>();
            if (handlers && !handlers->empty()) {
                createOrAlter([=](const std::string& column_name){
                    auto iter = handlers->find(column_name);
                    if (iter != handlers->end()) {
                        return iter->second();
                    }
                    return true;
                });
            } else {
                createOrAlter();
            }
            createFTSTable();
        }
    }
}

template<class C, class S>
wwdb::DataBase* Table<C, S>::statementDB() {
    return &db_;
}

template<class C, class S>
Table<C, S>& Table<C, S>::table() {
    return *this;
}

}

// ======== MACRO ========

#define __WWDB_MACRO_EXPAND(x) x
#define __WWDB_MACRO_FOR_EACH_1(what, x, ...) what(x)
#define __WWDB_MACRO_FOR_EACH_2(what, x, ...)\
    what(x)\
    __WWDB_MACRO_EXPAND(__WWDB_MACRO_FOR_EACH_1(what,  __VA_ARGS__))
#define __WWDB_MACRO_FOR_EACH_3(what, x, ...)\
    what(x)\
    __WWDB_MACRO_EXPAND(__WWDB_MACRO_FOR_EACH_2(what, __VA_ARGS__))
#define __WWDB_MACRO_FOR_EACH_4(what, x, ...)\
    what(x)\
    __WWDB_MACRO_EXPAND(__WWDB_MACRO_FOR_EACH_3(what,  __VA_ARGS__))
#define __WWDB_MACRO_FOR_EACH_5(what, x, ...)\
    what(x)\
    __WWDB_MACRO_EXPAND(__WWDB_MACRO_FOR_EACH_4(what,  __VA_ARGS__))
#define __WWDB_MACRO_FOR_EACH_6(what, x, ...)\
    what(x)\
    __WWDB_MACRO_EXPAND(__WWDB_MACRO_FOR_EACH_5(what,  __VA_ARGS__))
#define __WWDB_MACRO_FOR_EACH_7(what, x, ...)\
    what(x)\
    __WWDB_MACRO_EXPAND(__WWDB_MACRO_FOR_EACH_6(what,  __VA_ARGS__))
#define __WWDB_MACRO_FOR_EACH_8(what, x, ...)\
    what(x)\
    __WWDB_MACRO_EXPAND(__WWDB_MACRO_FOR_EACH_7(what,  __VA_ARGS__))
#define __WWDB_MACRO_FOR_EACH_9(what, x, ...)\
    what(x)\
    __WWDB_MACRO_EXPAND(__WWDB_MACRO_FOR_EACH_8(what,  __VA_ARGS__))
#define __WWDB_MACRO_FOR_EACH_10(what, x, ...)\
    what(x)\
    __WWDB_MACRO_EXPAND(__WWDB_MACRO_FOR_EACH_9(what,  __VA_ARGS__))
#define __WWDB_MACRO_FOR_EACH_11(what, x, ...)\
    what(x)\
    __WWDB_MACRO_EXPAND(__WWDB_MACRO_FOR_EACH_10(what,  __VA_ARGS__))
#define __WWDB_MACRO_FOR_EACH_12(what, x, ...)\
    what(x)\
    __WWDB_MACRO_EXPAND(__WWDB_MACRO_FOR_EACH_11(what,  __VA_ARGS__))
#define __WWDB_MACRO_FOR_EACH_NARG(...) __WWDB_MACRO_FOR_EACH_NARG_(__VA_ARGS__, __WWDB_MACRO_FOR_EACH_RSEQ_N())
#define __WWDB_MACRO_FOR_EACH_NARG_(...) __WWDB_MACRO_EXPAND(__WWDB_MACRO_FOR_EACH_ARG_N(__VA_ARGS__))
#define __WWDB_MACRO_FOR_EACH_ARG_N(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, N, ...) N
#define __WWDB_MACRO_FOR_EACH_RSEQ_N() 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
#define __WWDB_MACRO_CONCATENATE(x,y) x##y
#define __WWDB_MACRO_FOR_EACH_(N, what, ...) __WWDB_MACRO_EXPAND(__WWDB_MACRO_CONCATENATE(__WWDB_MACRO_FOR_EACH_, N)(what, __VA_ARGS__))
#define __WWDB_MACRO_FOR_EACH(what, ...) __WWDB_MACRO_FOR_EACH_(__WWDB_MACRO_FOR_EACH_NARG(__VA_ARGS__), what, __VA_ARGS__)

#if defined(_MSC_VER)
    #define __WWDB_UNUSED_ATTRIBUTE
#else
    #define __WWDB_UNUSED_ATTRIBUTE __attribute__((unused))
#endif

#define __WWDB_STATIC_GETTER(type, name, ...) \
    static type& name() { \
        static type name##_(__VA_ARGS__); \
        return name##_; \
    } \

#define __WWDB_TABLE_PROPERTY() \
    __WWDB_UNUSED_ATTRIBUTE const auto SIMPLE = TableProperty::FTSTokenize::Simple; \
    __WWDB_UNUSED_ATTRIBUTE const auto PORTER = TableProperty::FTSTokenize::Porter; \
    __WWDB_UNUSED_ATTRIBUTE const auto ICU = TableProperty::FTSTokenize::ICU; \
    __WWDB_UNUSED_ATTRIBUTE const auto FTS3 = [](const TableProperty::FTSTokenize& tokenize){ return wwdb::TableProperty(TableProperty::PropertyType::FTS3TableName, "", tokenize); }; \
    __WWDB_UNUSED_ATTRIBUTE const auto WITH_FTS3 = [](const std::string& vTableName, const TableProperty::FTSTokenize& tokenize){ return wwdb::TableProperty(TableProperty::PropertyType::FTS3TableName, vTableName, tokenize); }; \
    __WWDB_UNUSED_ATTRIBUTE const auto FTS4 = [](const TableProperty::FTSTokenize& tokenize){ return wwdb::TableProperty(TableProperty::PropertyType::FTS4TableName, "", tokenize); }; \
    __WWDB_UNUSED_ATTRIBUTE const auto WITH_FTS4 = [](const std::string& vTableName, const TableProperty::FTSTokenize& tokenize){ return wwdb::TableProperty(TableProperty::PropertyType::FTS4TableName, vTableName, tokenize); }; \
    __WWDB_UNUSED_ATTRIBUTE const auto FTS = FTS3; \
    __WWDB_UNUSED_ATTRIBUTE const auto WITH_FTS = WITH_FTS3;

#define __WWDB_SCOPED_TABLE(className, scopeClass, ...) \
    namespace wwdb { \
    template<> class ORM<className, scopeClass> : public ORMBase<className, scopeClass> { \
    public: \
    typedef className _cls_; \
    static void ensure_initialized() { static __WWDB_UNUSED_ATTRIBUTE ORM* instance = new ORM(); } \
    __WWDB_STATIC_GETTER(StaticFields, static_fields, #className, [](){__WWDB_TABLE_PROPERTY() return std::vector<TableProperty>{ __VA_ARGS__ };}()); \

#define __WWDB_TABLE(className, ...) __WWDB_SCOPED_TABLE(className, wwdb::scope::MainScope<0>, __VA_ARGS__)

#define __WWDB_INDEXED_TABLE(className, index, ...) __WWDB_SCOPED_TABLE(className, wwdb::scope::MainScope<index>, __VA_ARGS__)

#define __WWDB_END };}

#define __WWDB_COLUMN_CONSTRAINT(valueType) \
    __WWDB_UNUSED_ATTRIBUTE constexpr auto BLOB = wwdb::ColumnConstraint::ConstraintType::Blob; \
    __WWDB_UNUSED_ATTRIBUTE constexpr auto PRIMARY = wwdb::ColumnConstraint::ConstraintType::Primary; \
    __WWDB_UNUSED_ATTRIBUTE constexpr auto UNIQUE = wwdb::ColumnConstraint::ConstraintType::Unique; \
    __WWDB_UNUSED_ATTRIBUTE constexpr auto NOT_NULL = wwdb::ColumnConstraint::ConstraintType::NotNull; \
    __WWDB_UNUSED_ATTRIBUTE constexpr auto AUTO_INCREMENT = wwdb::ColumnConstraint::ConstraintType::AutoIncrement; \
    __WWDB_UNUSED_ATTRIBUTE const auto DEFAULT = [](const valueType& v){ return wwdb::ColumnConstraint(ColumnConstraint::ConstraintType::DefaultValue, fillArgument(v)); }; \
    __WWDB_UNUSED_ATTRIBUTE constexpr auto FTS_DOCID = wwdb::ColumnConstraint::ConstraintType::FullTextSearchDocId; \
    __WWDB_UNUSED_ATTRIBUTE constexpr auto FTS_COL = wwdb::ColumnConstraint::ConstraintType::FullTextSearchColumn; \
    __WWDB_UNUSED_ATTRIBUTE const auto FTS_COL_NAME = [](const std::string& vColName){ return wwdb::ColumnConstraint(ColumnConstraint::ConstraintType::FullTextSearchColumn, vColName); }; \

#define __WWDB_COLUMN_INTERNAL(propName, propGetter, propSetter, ...) \
    private: \
    static wwdb::Column<_cls_, std::decay<decltype(((_cls_*)nullptr)->propGetter)>::type>& _##propName() { \
        using _valuetype_ = std::decay<decltype(((_cls_*)nullptr)->propGetter)>::type; \
        static Column<_cls_, _valuetype_>* column_ = nullptr; \
        if (column_ == nullptr) { \
            __WWDB_COLUMN_CONSTRAINT(_valuetype_) \
            column_ = new Column<_cls_, _valuetype_>(#propName, \
                { __VA_ARGS__ }, \
                [](wwdb::StatementBase& s, int col, _cls_& obj, const ColumnDefinition* c){ \
                    _valuetype_ v = retrieveArgument(s, col, (_valuetype_*)nullptr, c); \
                    propSetter; \
                }, \
                [](const _cls_& obj, bool copy, const ColumnDefinition* c){ \
                    return bindArgument(obj.propGetter, copy, c); \
                } \
            ); \
            static_fields().initField(*column_, __COUNTER__); \
        } \
        return *column_; \
    } \
    public: \
    wwdb::Column<_cls_, std::decay<decltype(((_cls_*)nullptr)->propGetter)>::type>& propName = _##propName(); \

#define __WWDB_COLUMN(propName, ...) __WWDB_COLUMN_INTERNAL(propName, propName, obj.propName = std::move(v), __VA_ARGS__)

#define __WWDB_COLUMN_DYN(columnName, extractFunc, ...) \
    private: \
    static wwdb::Column<_cls_, decltype(extractFunc(*(_cls_*)nullptr))>& _##columnName() { \
        using _valuetype_ = decltype(extractFunc(*(_cls_*)nullptr)); \
        static Column<_cls_, _valuetype_>* column_ = nullptr; \
        if (column_ == nullptr) { \
            __WWDB_COLUMN_CONSTRAINT(_valuetype_) \
            column_ = new Column<_cls_, _valuetype_>(#columnName, \
                { wwdb::ColumnConstraint::ConstraintType::DynamicValue, wwdb::ColumnConstraint::ConstraintType::DynamicValue, __VA_ARGS__ }, \
                [](wwdb::StatementBase& s, int col, _cls_& obj, const ColumnDefinition* c){ \
                    __WWDB_UNUSED_ATTRIBUTE bool this_column_will_never_read; \
                }, \
                [](const _cls_& obj, bool copy, const ColumnDefinition* c){ \
                    return bindArgument(extractFunc(obj), copy, c); \
                } \
            ); \
            static_fields().initField(*column_, __COUNTER__); \
        } \
        return *column_; \
    } \
    public: \
    wwdb::Column<_cls_, decltype(extractFunc(*(_cls_*)nullptr))>& columnName = _##columnName(); \

#define __WWDB_ON_SELECT(decodeFunc) \
    public: \
    static void _on_decode(_cls_& o) { \
        decodeFunc(o); \
    }

#define __WWDB_INDEX_ITER(propName) _##propName().definition(),

#define __WWDB_INDEX(indexName, unique, ...) \
    private: \
    static wwdb::TableIndex& _index_##indexName() { \
        static wwdb::TableIndex* index_ = nullptr; \
        if (index_ == nullptr) { \
            index_ = new wwdb::TableIndex(#indexName, unique, { \
                __WWDB_MACRO_FOR_EACH(__WWDB_INDEX_ITER, __VA_ARGS__) \
                wwdb::ColumnDefinition::DoNotUse() \
            }); \
            static_fields().indexes.push_back(*index_); \
        } \
        return *index_; \
    } \
    private: \
    wwdb::TableIndex& __##indexName = _index_##indexName();

#define __WWDB_PROPERTY(...) __WWDB_MACRO_FOR_EACH(__WWDB_COLUMN, __VA_ARGS__)

#define __WWDB_SIMPLE_TABLE(className, ...) \
    __WWDB_TABLE(className) \
    __WWDB_PROPERTY(__VA_ARGS__) \
    __WWDB_END

#define __WWDB_SIMPLE_VTABLE(className, ...) \
    __WWDB_TABLE(className, wwdb::TableProperty::PropertyType::DoNotCreateOrAlter) \
    __WWDB_PROPERTY(__VA_ARGS__) \
    __WWDB_END

#define __WWDB_MAP(cols, statement) \
    map<decltype(((std::decay<decltype(cols)>::type::_cls_*)nullptr)->statement)>([&](const std::decay<decltype(cols)>::type::_cls_& o){ return o.statement; })

#endif /* wwdb_impl_hpp */
