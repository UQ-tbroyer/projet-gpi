#include "DatabaseManager.h"
#include "Security.h"
#include "User.h"
#include <memory>
#include <mysql_driver.h>
#include <mysql_connection.h>
#include <cppconn/prepared_statement.h>
#include <cppconn/resultset.h>
#include <cppconn/exception.h>
#include <iostream>

DatabaseManager::DatabaseManager(const std::string& server, const std::string& user,
    const std::string& pwd, const std::string& db)
    : connection(nullptr), server(server), username(user), password(pwd), database(db) {
    initializeConnection();
}

DatabaseManager::~DatabaseManager() {
    if (connection && !connection->isClosed()) {
        connection->close();
        delete connection;
    }
}

void DatabaseManager::initializeConnection() {
    try {
        std::cout << "Getting MySQL driver instance..." << std::endl;
        sql::mysql::MySQL_Driver* driver = sql::mysql::get_mysql_driver_instance();

        if (!driver) {
            throw std::runtime_error("Failed to get MySQL driver instance");
        }

        std::cout << "Driver obtained successfully" << std::endl;

        // Try simple connection first
        std::string connectionString = "tcp://" + server + ":3306";

        std::cout << "Attempting to connect to: " << connectionString << std::endl;
        std::cout << "User: " << username << std::endl;
        std::cout << "Database: " << database << std::endl;

        // Create connection properties
        sql::ConnectOptionsMap connection_properties;
        connection_properties["hostName"] = server;
        connection_properties["port"] = 3306;
        connection_properties["userName"] = username;
        connection_properties["password"] = password;
        connection_properties["schema"] = database;
        connection_properties["OPT_RECONNECT"] = true;

        std::cout << "Connecting..." << std::endl;
        connection = driver->connect(connection_properties);

        if (!connection) {
            throw std::runtime_error("Failed to create connection object");
        }

        std::cout << "Connection created, testing..." << std::endl;

        // Test the connection
        if (connection->isClosed()) {
            throw std::runtime_error("Connection was closed immediately after opening");
        }

        std::cout << "Database connection established successfully." << std::endl;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error during connection: " << e.what() << std::endl;
        std::cerr << "MySQL error code: " << e.getErrorCode() << std::endl;
        std::cerr << "SQL state: " << e.getSQLState() << std::endl;
        throw;
    }
    catch (const std::bad_alloc& e) {
        std::cerr << "Memory allocation error: " << e.what() << std::endl;
        std::cerr << "This usually means:" << std::endl;
        std::cerr << "  1. Missing libmysql.dll in executable path" << std::endl;
        std::cerr << "  2. 32-bit/64-bit mismatch" << std::endl;
        std::cerr << "  3. Wrong MySQL Connector version" << std::endl;
        throw;
    }
    catch (const std::exception& e) {
        std::cerr << "Standard exception during connection: " << e.what() << std::endl;
        throw;
    }
}

bool DatabaseManager::testConnection() {
    try {
        std::unique_ptr<sql::Statement> stmt(connection->createStatement());
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery("SELECT 1"));
        return true;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "Connection test failed: " << e.what() << std::endl;
        return false;
    }
}

User* DatabaseManager::findUserByEmail(const std::string& email) {
    try {
        if (!Security::isValidEmail(email)) {
            std::cerr << "Invalid email format: " << email << std::endl;
            return nullptr;
        }

        const std::string sql =
            "SELECT idEmploye, idDepartement, idRole, nomEmploye, prenomEmploye, adresseMail, motDePasse "
            "FROM Employe WHERE adresseMail = ?";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setString(1, email);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        if (res->next()) {
            return new User(
                intToRole(res->getInt("idRole")),
                res->getInt("idEmploye"),
                res->getInt("idDepartement"),
                res->getString("nomEmploye"),
                res->getString("prenomEmploye"),
                res->getString("adresseMail"),
                res->getString("motDePasse")
            );
        }

        return nullptr;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in findUserByEmail: " << e.what() << std::endl;
        return nullptr;
    }
}

User* DatabaseManager::authenticateUser(const std::string& email, const std::string& password) {
    try {
        // First, find the user by email
        User* user = findUserByEmail(email);
        if (!user) {
            std::cout << "No user found with email: " << email << std::endl;
            return nullptr;
        }

        // Check if password matches email (your specific requirement)
        if (password == email) {
            std::cout << "Authentication successful: Password matches email." << std::endl;
            return user;
        }

        // Optional: Also check against stored hash for normal authentication
        if (Security::verifyPassword(password, user->getPasswordHash())) {
            std::cout << "Authentication successful: Password hash verified." << std::endl;
            return user;
        }

        std::cout << "Authentication failed: Password does not match." << std::endl;
        delete user;
        return nullptr;
    }
    catch (const std::exception& e) {
        std::cerr << "Error during authentication: " << e.what() << std::endl;
        return nullptr;
    }
}