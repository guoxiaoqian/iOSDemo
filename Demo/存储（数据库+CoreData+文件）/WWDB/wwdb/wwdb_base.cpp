#include "wwdb_base.hpp"

using namespace wwdb;

any::any(any&& other) : value_(other.value_), type_(other.type_), deleter_(other.deleter_) {
    other.value_ = nullptr;
    other.type_ = nullptr;
    other.deleter_ = std::function<void()>();
}

any::~any() {
    if (deleter_) deleter_();
}

any& any::operator=(any&& other) {
    if (deleter_) deleter_();
    value_ = other.value_;
    type_ = other.type_;
    deleter_ = other.deleter_;
    other.value_ = nullptr;
    other.type_ = nullptr;
    other.deleter_ = std::function<void()>();
    return *this;
}

std::string wwdb::to_upper(const std::string& v) {
    std::string ret = v;
    for (auto& c : ret) c = toupper(c);
    return ret;
}

std::string wwdb::to_lower(const std::string& v) {
    std::string ret = v;
    for (auto& c : ret) c = tolower(c);
    return ret;
}
