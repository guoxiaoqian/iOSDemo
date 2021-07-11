#ifndef wwdb_protobuf_hpp
#define wwdb_protobuf_hpp

#include "wwdb_core.hpp"

// ======== MACRO ========

#define WWDB_COLUMN_PB(propName, ...) __WWDB_COLUMN_INTERNAL(propName, propName(), obj.set_##propName(v), wwdb::ColumnConstraint::ConstraintType::DynamicValue, __VA_ARGS__)
#define WWDB_COLUMN_PB_SELF(propName, ...) __WWDB_COLUMN_INTERNAL(propName, SerializeAsString(), obj.ParseFromString(v), BLOB, wwdb::ColumnConstraint::ConstraintType::DynamicValue, __VA_ARGS__)
#define WWDB_COLUMN_PB_BLOB(propName, ...) __WWDB_COLUMN_INTERNAL(propName, propName().SerializeAsString(), obj.mutable_##propName()->ParseFromString(v), BLOB, wwdb::ColumnConstraint::ConstraintType::DynamicValue, __VA_ARGS__)
#define WWDB_COLUMN_PB_EMBED(propName, superPropName, ...) __WWDB_COLUMN_INTERNAL(propName, superPropName().propName(), obj.mutable_##superPropName()->set_##propName(v), wwdb::ColumnConstraint::ConstraintType::DynamicValue, __VA_ARGS__)
#define WWDB_COLUMN_PB_EXT(propName, extensionID, ...) __WWDB_COLUMN_INTERNAL(last_read, GetExtension(extensionID), wwdb::ColumnConstraint::ConstraintType::DynamicValue, obj.SetExtension(extensionID, v))

#endif /* wwdb_protobuf_hpp */
