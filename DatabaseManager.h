#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <string>

// Forward declarations only - no <memory> in header!
namespace sql {
    class Connection;
    class Driver;
    class PreparedStatement;
    class ResultSet;
}

class User;

class DatabaseManager {
private:
    sql::Connection* connection;
    std::string server;
    std::string username;
    std::string password;
    std::string database;

    void initializeConnection();

public:
    DatabaseManager(const std::string& server, const std::string& user,
        const std::string& pwd, const std::string& db);
    ~DatabaseManager();

    // Disable copying
    DatabaseManager(const DatabaseManager&) = delete;
    DatabaseManager& operator=(const DatabaseManager&) = delete;

    bool testConnection();
    User* authenticateUser(const std::string& email, const std::string& password);
    User* findUserByEmail(const std::string& email);
};

#endif