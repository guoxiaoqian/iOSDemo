#ifndef wwdb_config_hpp
#define wwdb_config_hpp

// Configuration file for WWDB

// The sqlite3 header file
#include <sqlite3.h>

// The extra flag to "bitwise or" on opening database
#define WWDB_OPEN_EXTRA_FLAG SQLITE_OPEN_FULLMUTEX

// Has sqlite3_key feature?
#define WWDB_HAS_SQLITE_KEY_FUNC 0

// The stream object for printing log (default to std::cout)
#include <iostream>
#define WWDB_LOG_INFO (std::cout)
#define WWDB_LOG_WARN (std::cout)
#define WWDB_LOG_ERROR (std::cout)

// Get high-resolution system time (in microseconds)
#include <chrono>
#define WWDB_TIME_NOW_US (std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::system_clock::now().time_since_epoch()).count())
#define WWDB_TIME_STEADY_US (std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::steady_clock::now().time_since_epoch()).count())

// Enable internal KVTable support, with value as KVTable's table name
#define WWDB_ENABLE_KVTABLE "KEYVALUE"

// Specify the maximum number placeholder for each "IN" expression. inline if exceeded.
#define WWDB_MAX_IN_PLACEHOLDER 100

// Specify the maximum number of objects for each "INSERT" operation.
#define WWDB_BATCH_INSERT_PIECE 200

// Due to sqlite not providing native uint64 type supporting, WWDB will actually use int64 instead. It's okay in most case, except some comparison operators.
// Enable this option to make WWDB generate SQL using custom functions instead of comparison operators when comparing uint64s, which can act correctly with a little performance loss.
#define WWDB_UINT64_CUSTOM_FUNCTIONS 1

#define WWDB_ASYNC 0
// namespace wwdb {
//     template <typename... V> using Promise = any_promise_library::Promise<V...>;
// }

#endif /* wwdb_config_hpp */
