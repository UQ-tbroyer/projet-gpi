#ifndef TASKREPOSITORY_H
#define TASKREPOSITORY_H

#include <memory>
#include <cppconn/connection.h>
#include <cppconn/prepared_statement.h>
#include <cppconn/resultset.h>

#include "TaskData.h"

class TaskRepository {
public:
    TaskRepository(sql::Connection* connection);

    TaskData getTaskById(int id);

private:
    sql::Connection* conn;

    TaskData mapResultToTask(std::unique_ptr<sql::ResultSet>& res);
};

#endif // TASKREPOSITORY_H
