
#pragma once
#include <mysql_connection.h>

namespace TestDatabase {
    void reset(sql::Connection* conn);
    void loadTestData(sql::Connection* conn);
}
