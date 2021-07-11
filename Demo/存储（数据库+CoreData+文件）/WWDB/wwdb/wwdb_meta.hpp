#ifndef wwdb_meta_hpp
#define wwdb_meta_hpp

#include "wwdb_core.hpp"

namespace wwdb {
    struct sqlite_master {
        std::string type;
        std::string name;
        std::string tbl_name;
        int rootpage;
        std::string sql;
    };
    struct table_info {
        int cid;
        std::string name;
        std::string type;
        bool notnull;
        std::string dflt_value;
        int pk;
    };
    struct query_plan {
        int selectid;
        int order;
        int from;
        std::string detail;
    };
}

WWDB_SIMPLE_TABLE(sqlite_master, type, name, tbl_name, rootpage, sql)
__WWDB_SIMPLE_VTABLE(table_info, cid, name, type, notnull, dflt_value, pk)
__WWDB_SIMPLE_VTABLE(query_plan, selectid, order, from, detail)

#endif /* wwdb_meta.hpp */
