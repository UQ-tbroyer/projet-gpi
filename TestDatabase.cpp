#include "TestDatabase.h"
#include <fstream>
#include <sstream>
#include <mysql_driver.h>
#include <mysql_connection.h>

/*void TestDatabase::reset(sql::Connection* conn) {
    std::ifstream file("sql/schema.sql");
    std::stringstream buffer;
    buffer << file.rdbuf();

    std::unique_ptr<sql::Statement> stmt(conn->createStatement());
    stmt->execute(buffer.str());
}

void TestDatabase::loadTestData(sql::Connection* conn) {
    std::ifstream file("sql/test_data.sql");
    std::stringstream buffer;
    buffer << file.rdbuf();

    std::unique_ptr<sql::Statement> stmt(conn->createStatement());
    stmt->execute(buffer.str());*/

