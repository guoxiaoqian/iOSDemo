#ifndef wwdb_base_hpp
#define wwdb_base_hpp

#include <string>
#include <vector>
#include <set>
#include <map>
#include <algorithm>
#include <functional>
#include <memory>
#include <sstream>
#include <type_traits>

namespace wwdb {
    
class any {
public:
    template<class T> explicit any(T&& value);
    any(any&& other);
    ~any();
    template<class T> T* as();
    any(const any& other) = delete;
    any& operator=(const any&) = delete;
    any& operator=(any&&);
    template<class T> static void* type_key();
private:
    template<class T> static void type_key_func();
    void* value_;
    void* type_;
    std::function<void()> deleter_;
};

template<class T>
struct type_key_var {
    static char var;
};

template<class V>
class typed_key_map {
public:
    template <class K> V* get();
    template <class K> void set();
    template <class K> V* set(V&& v);
    template <class K> V* use();
    template <class K, class P> V* use(P&& p);
    bool empty();
private:
    std::map<void*, V> underlying_map_;
};
    
class typed_kv_map : protected typed_key_map<any> {
public:
    template <class K, class V> V* get();
    template <class K> void set();
    template <class K, class V> V* set(V&& v);
    template <class K, class V> V* use();
    template <class K, class V, class P> V* use(P&& p);
};

class typed_cache : protected typed_kv_map {
public:
    template <class T> T* get();
    template <class T> void set();
    template <class T> T* set(T&& v);
    template <class T> T* use();
    template <class T, class P> T* use(P&& p);
};
    
template<class T>
class entity_ptr {
public:
    entity_ptr();
    explicit entity_ptr(const T& ref);
    explicit entity_ptr(const T* ptr);
    entity_ptr(const entity_ptr& other);
    entity_ptr(entity_ptr&& other);
    void operator=(const entity_ptr& other);
    void operator=(entity_ptr&& other);
    void operator=(const T& ref);
    void operator=(const T* ptr);
    T& operator*();
    const T& operator*() const;
    T* operator->();
    const T* operator->() const;
    T* get();
    const T* get() const;
    explicit operator bool() const;
private:
    std::unique_ptr<T> pointer_;
};

template<typename T, typename _ = void>
struct is_container : std::false_type {};

template<typename... Ts>
struct is_container_helper {};

template<typename T>
struct is_container<T, std::conditional<
    false,
    is_container_helper<
        typename T::value_type,
        typename T::size_type,
        typename T::allocator_type,
        typename T::iterator,
        typename T::const_iterator,
        decltype(std::declval<T>().size()),
        decltype(std::declval<T>().begin()),
        decltype(std::declval<T>().end()),
        decltype(std::declval<T>().cbegin()),
        decltype(std::declval<T>().cend())
    >, void>
> : public std::true_type {};

// ======== IMPLEMENTATION ========

template<class T> any::any(T&& value) : value_((void*)new std::decay_t<T>(std::forward<T>(value))), type_(type_key<T>()) {
    void* v = value_;
    deleter_ = [=](){
        delete (std::decay_t<T>*)v;
    };
}
    
template<class T> T* any::as() {
    if (type_key<T>() == type_) {
        return (T*)value_;
    } else {
        return nullptr;
    }
}

template<class T>
void* any::type_key() {
    return (void*)&type_key_var<typename std::decay_t<T>>::var;
}

template<class T>
char type_key_var<T>::var = 0;

template<class V> template<class K>
V* typed_key_map<V>::get() {
    auto iter = underlying_map_.find(any::type_key<K>());
    if (iter != underlying_map_.end()) {
        return reinterpret_cast<V*>(&iter->second);
    } else {
        return nullptr;
    }
}

template<class V> template<class K>
void typed_key_map<V>::set() {
    underlying_map_.erase(any::type_key<K>());
}

template<class V> template<class K>
V* typed_key_map<V>::set(V&& v) {
    auto iter = underlying_map_.find(any::type_key<K>());
    if (iter == underlying_map_.end()) {
        auto result = underlying_map_.emplace(any::type_key<K>(), std::forward<V>(v));
        return reinterpret_cast<V*>(&result.first->second);
    } else {
        iter->second = std::forward<V>(v);
        return &iter->second;
    }
}

template<class V>
bool typed_key_map<V>::empty() {
    return underlying_map_.empty();
}
    
template<class V> template<class K>
V* typed_key_map<V>::use() {
    auto ptr = get<K>();
    return ptr ? ptr : set<K>(V());
}
    
template<class V> template <class K, class P>
V* typed_key_map<V>::use(P&& p) {
    auto ptr = get<K>();
    return ptr ? ptr : set<K>(V(std::forward<P>(p)));
}

template <class K, class V> V* typed_kv_map::get() {
    any* ret = typed_key_map<any>::get<K>();
    if (ret) {
        return ret->as<V>();
    } else {
        return nullptr;
    }
}

template <class K> void typed_kv_map::set() {
    typed_key_map<any>::set<K>();
}

template <class K, class V> V* typed_kv_map::set(V&& v) {
    return typed_key_map<any>::set<K>(any(std::forward<V>(v)))->template as<V>();
}

template <class K, class V> V* typed_kv_map::use() {
    auto ptr = get<K, V>();
    return ptr ? ptr : set<K, V>(V());
}

template <class K, class V, class P> V* typed_kv_map::use(P&& p) {
    auto ptr = get<K, V>();
    return ptr ? ptr : set<K, V>(V(std::forward<P>(p)));
}

template <class T> T* typed_cache::get() {
    return typed_kv_map::get<T, T>();
}

template <class T> void typed_cache::set() {
    typed_kv_map::set<T>();
}

template <class T> T* typed_cache::set(T&& v) {
    return typed_kv_map::set<T, T>(std::forward<T>(v));
}
    
template <class T> T* typed_cache::use() {
    auto ptr = get<T>();
    return ptr ? ptr : set<T>(T());
}

template <class T, class P> T* typed_cache::use(P&& p) {
    auto ptr = get<T>();
    return ptr ? ptr : set<T>(T(std::forward<P>(p)));
}
    
template <class T> entity_ptr<T>::entity_ptr() {
    ;
}
    
template <class T> entity_ptr<T>::entity_ptr(const T& ref) : pointer_(new T(ref)) {
    ;
}
    
template <class T> entity_ptr<T>::entity_ptr(const T* ptr) : pointer_(new T(*ptr)) {
    ;
}
    
template <class T> entity_ptr<T>::entity_ptr(const entity_ptr& other) {
    pointer_.reset(other.pointer_ ? new T(*other.pointer_) : nullptr);
}

template <class T> entity_ptr<T>::entity_ptr(entity_ptr&& other) {
    pointer_ = std::move(other.pointer_);
}

template <class T> void entity_ptr<T>::operator=(const entity_ptr& other) {
    pointer_.reset(other.pointer_ ? new T(*other.pointer_) : nullptr);
}

template <class T> void entity_ptr<T>::operator=(entity_ptr&& other) {
    pointer_ = std::move(other.pointer_);
}

template <class T> void entity_ptr<T>::operator=(const T& ref) {
    pointer_.reset(new T(ref));
}

template <class T> void entity_ptr<T>::operator=(const T* ptr) {
    pointer_.reset(new T(*ptr));
}

template <class T> T& entity_ptr<T>::operator*() {
    return *pointer_;
}
    
template <class T> const T& entity_ptr<T>::operator*() const {
    return *pointer_;
}

template <class T> T* entity_ptr<T>::operator->() {
    return pointer_.operator->();
}

template <class T> const T* entity_ptr<T>::operator->() const {
    return pointer_.operator->();
}
    
template <class T> T* entity_ptr<T>::get() {
    return pointer_.get();
}

template <class T> const T* entity_ptr<T>::get() const {
    return pointer_.get();
}

template <class T> entity_ptr<T>::operator bool() const {
    return (bool)pointer_;
}

template <class T> std::string to_string(const T& v) {
    std::ostringstream oss;
    oss << v;
    return oss.str();
}
    
std::string to_upper(const std::string& v);
std::string to_lower(const std::string& v);
    
}

#endif /* wwdb_base_hpp */
