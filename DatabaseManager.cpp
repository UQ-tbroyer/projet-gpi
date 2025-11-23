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
#include <sstream>
#include <iomanip>
#include <stdexcept>
#include <QDebug>      
#include <QString>  

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

        if (!res->next()) {
            throw std::runtime_error("Test query returned no results");
        }

        int result = res->getInt(1);
        if (result != 1) {
            throw std::runtime_error("Test query returned unexpected result");
        }

        qDebug() << "Database test connection successful";
        return true;
    }
    catch (const sql::SQLException& e) {
        qCritical() << "Database test connection FAILED:" << e.what();
        qCritical() << "MySQL Error code:" << e.getErrorCode();
        qCritical() << "SQL State:" << e.getSQLState();

        // Relancer l'exception pour que le catch principal la capture
        throw; // <- AJOUT IMPORTANT
    }
    catch (const std::exception& e) {
        qCritical() << "Database test connection FAILED:" << e.what();
        throw; // <- AJOUT IMPORTANT
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
    std::cout << "=== AUTHENTICATION DEBUG ===" << std::endl;
    std::cout << "Input email: '" << email << "'" << std::endl;
    std::cout << "Input password: '" << password << "'" << std::endl;

    try {
        // First, find the user by email
        User* user = findUserByEmail(email);
        if (!user) {
            std::cout << "❌ No user found with email: " << email << std::endl;
            return nullptr;
        }

        std::cout << "✅ User found in database:" << std::endl;
        std::cout << "   Stored email: '" << user->getEmail() << "'" << std::endl;
        std::cout << "   Stored password: '" << user->getPasswordHash() << "'" << std::endl;
        std::cout << "   Password length: " << user->getPasswordHash().length() << std::endl;

        // Check if password matches email (your specific requirement)
        std::cout << "Testing: password == email?" << std::endl;
        std::cout << "   Input password: '" << password << "'" << std::endl;
        std::cout << "   User email: '" << user->getEmail() << "'" << std::endl;
        std::cout << "   Result: " << (password == user->getEmail() ? "MATCH" : "NO MATCH") << std::endl;

        if (password == user->getEmail()) {
            std::cout << "✅ Authentication successful: Password matches email." << std::endl;
            return user;
        }

        // Check if password matches stored password (plain text)
        std::cout << "Testing: password == stored password?" << std::endl;
        std::cout << "   Input password: '" << password << "'" << std::endl;
        std::cout << "   Stored password: '" << user->getPasswordHash() << "'" << std::endl;
        std::cout << "   Result: " << (password == user->getPasswordHash() ? "MATCH" : "NO MATCH") << std::endl;

        if (password == user->getPasswordHash()) {
            std::cout << "✅ Authentication successful: Plain text password match." << std::endl;
            return user;
        }

        // Optional: Also check against stored hash for normal authentication
        std::cout << "Testing hashed password verification..." << std::endl;
        if (Security::verifyPassword(password, user->getPasswordHash())) {
            std::cout << "✅ Authentication successful: Password hash verified." << std::endl;
            return user;
        }

        std::cout << "❌ All authentication methods failed" << std::endl;
        delete user;
        return nullptr;
    }
    catch (const std::exception& e) {
        std::cerr << "💥 Error during authentication: " << e.what() << std::endl;
        return nullptr;
    }
}


std::vector<ProjectData> DatabaseManager::getAllProjects() {
    std::vector<ProjectData> projects;

    try {
        const std::string sql =
            "SELECT p.idProject, p.idClient, p.idDepartement, p.nomProject, "
            "p.dataProject, p.tempRepository, p.coutService, c.nomClient "
            "FROM Project p "
            "LEFT JOIN Client c ON p.idClient = c.idClient "
            "ORDER BY p.dataProject DESC";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            ProjectData project;
            project.idProject = res->getInt("idProject");
            project.idClient = res->getInt("idClient");
            project.idDepartement = res->getInt("idDepartement");
            project.nomProject = res->getString("nomProject");
            project.dataProject = res->getString("dataProject");
            project.tempRepository = res->getString("tempRepository");
            project.coutService = res->getDouble("coutService");
            project.nomClient = res->getString("nomClient");

            projects.push_back(project);
        }
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getAllProjects: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load projects from database");
    }

    return projects;
}

std::vector<ProjectData> DatabaseManager::getProjectsByUser(int userId) {
    std::vector<ProjectData> projects;

    try {
        // Only get projects where user is DIRECTLY assigned to tasks
        const std::string sql =
            "SELECT DISTINCT p.idProject, p.idClient, p.idDepartement, p.nomProject, "
            "p.dataProject, p.tempRepository, p.coutService, c.nomClient "
            "FROM Project p "
            "LEFT JOIN Client c ON p.idClient = c.idClient "
            "INNER JOIN Tache t ON p.idProject = t.idProject "
            "WHERE t.memProcessigner = ? "
            "ORDER BY p.dataProject DESC";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, userId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            ProjectData project;
            project.idProject = res->getInt("idProject");
            project.idClient = res->getInt("idClient");
            project.idDepartement = res->getInt("idDepartement");
            project.nomProject = res->getString("nomProject");
            project.dataProject = res->getString("dataProject");
            project.tempRepository = res->getString("tempRepository");
            project.coutService = res->getDouble("coutService");
            project.nomClient = res->getString("nomClient");

            projects.push_back(project);
        }

        std::cout << "Found " << projects.size() << " projects for user " << userId << std::endl;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getProjectsByUser: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load user projects from database");
    }

    return projects;
}

std::vector<ProjectData> DatabaseManager::getProjectsByDepartment(int departmentId) {
    std::vector<ProjectData> projects;

    try {
        const std::string sql =
            "SELECT p.idProject, p.idClient, p.idDepartement, p.nomProject, "
            "p.dataProject, p.tempRepository, p.coutService, c.nomClient "
            "FROM Project p "
            "LEFT JOIN Client c ON p.idClient = c.idClient "
            "WHERE p.idDepartement = ? "
            "ORDER BY p.dataProject DESC";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, departmentId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            ProjectData project;
            project.idProject = res->getInt("idProject");
            project.idClient = res->getInt("idClient");
            project.idDepartement = res->getInt("idDepartement");
            project.nomProject = res->getString("nomProject");
            project.dataProject = res->getString("dataProject");
            project.tempRepository = res->getString("tempRepository");
            project.coutService = res->getDouble("coutService");
            project.nomClient = res->getString("nomClient");

            projects.push_back(project);
        }
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getProjectsByDepartment: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load department projects from database");
    }

    return projects;
}

int DatabaseManager::createProject(const ProjectData& project) {
    try {
        const std::string sql =
            "INSERT INTO Project (idClient, idDepartement, nomProject, dataProject, tempRepository, coutService) "
            "VALUES (?, ?, ?, ?, ?, ?)";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, project.idClient);
        stmt->setInt(2, project.idDepartement);
        stmt->setString(3, project.nomProject);
        stmt->setString(4, project.dataProject);
        stmt->setString(5, project.tempRepository);
        stmt->setDouble(6, project.coutService);

        int affectedRows = stmt->executeUpdate();

        if (affectedRows > 0) {
            // Get the last insert ID
            std::unique_ptr<sql::Statement> idStmt(connection->createStatement());
            std::unique_ptr<sql::ResultSet> res(idStmt->executeQuery("SELECT LAST_INSERT_ID()"));
            if (res->next()) {
                return res->getInt(1);
            }
        }

        return -1;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in createProject: " << e.what() << std::endl;
        throw std::runtime_error("Failed to create project in database");
    }
}

bool DatabaseManager::updateProject(const ProjectData& project) {
    try {
        const std::string sql =
            "UPDATE Project SET idClient = ?, nomProject = ?, tempRepository = ?, coutService = ? "
            "WHERE idProject = ?";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, project.idClient);
        stmt->setString(2, project.nomProject);
        stmt->setString(3, project.tempRepository);
        stmt->setDouble(4, project.coutService);
        stmt->setInt(5, project.idProject);

        int affectedRows = stmt->executeUpdate();
        return affectedRows > 0;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in updateProject: " << e.what() << std::endl;
        throw std::runtime_error("Failed to update project in database");
    }
}

bool DatabaseManager::deleteProject(int projectId) {
    try {
        const std::string sql = "DELETE FROM Project WHERE idProject = ?";
        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, projectId);

        int affectedRows = stmt->executeUpdate();
        return affectedRows > 0;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in deleteProject: " << e.what() << std::endl;
        throw std::runtime_error("Failed to delete project from database");
    }
}

ProjectData DatabaseManager::getProjectById(int projectId) {
    ProjectData project;

    try {
        const std::string sql =
            "SELECT p.idProject, p.idClient, p.idDepartement, p.nomProject, "
            "p.dataProject, p.tempRepository, p.coutService, c.nomClient "
            "FROM Project p "
            "LEFT JOIN Client c ON p.idClient = c.idClient "
            "WHERE p.idProject = ?";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, projectId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        if (res->next()) {
            project.idProject = res->getInt("idProject");
            project.idClient = res->getInt("idClient");
            project.idDepartement = res->getInt("idDepartement");
            project.nomProject = res->getString("nomProject");
            project.dataProject = res->getString("dataProject");
            project.tempRepository = res->getString("tempRepository");
            project.coutService = res->getDouble("coutService");
            project.nomClient = res->getString("nomClient");
        }
        else {
            throw std::runtime_error("Project not found with ID: " + std::to_string(projectId));
        }
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getProjectById: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load project from database");
    }

    return project;
}

std::vector<std::pair<int, std::string>> DatabaseManager::getAllClients() {
    std::vector<std::pair<int, std::string>> clients;

    try {
        const std::string sql = "SELECT idClient, nomClient FROM Client ORDER BY nomClient";
        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        std::cout << "Fetching clients from database..." << std::endl; // ADD THIS

        while (res->next()) {
            auto client = std::make_pair(res->getInt("idClient"), res->getString("nomClient"));
            std::cout << "Found client: " << client.first << " - " << client.second << std::endl; // ADD THIS
            clients.emplace_back(client);
        }

        std::cout << "Total clients fetched: " << clients.size() << std::endl; // ADD THIS
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getAllClients: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load clients from database");
    }

    return clients;
}

// Task methods implementation
std::vector<TaskData> DatabaseManager::getTasksByUser(int userId) {
    std::vector<TaskData> tasks;

    try {
        const std::string sql =
            "SELECT t.idTache, t.idProject, t.memProcessigner, t.idParentTache, "
            "t.nomTache, t.descTache, t.dateDebut, t.dateFin, t.tempsTache, t.etat, "
            "CONCAT(e.prenomEmploye, ' ', e.nomEmploye) as assigneeName "
            "FROM Tache t "
            "LEFT JOIN Employe e ON t.memProcessigner = e.idEmploye "
            "WHERE t.memProcessigner = ? "
            "ORDER BY t.dateDebut ASC";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, userId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            TaskData task;
            task.idTache = res->getInt("idTache");
            task.idProject = res->getInt("idProject");
            task.memProcessigner = res->getInt("memProcessigner");
            task.idParentTache = res->isNull("idParentTache") ? 0 : res->getInt("idParentTache");
            task.nomTache = res->getString("nomTache");
            task.descTache = res->getString("descTache");
            task.dateDebut = res->getString("dateDebut");
            task.dateFin = res->getString("dateFin");
            task.tempsTache = res->getInt("tempsTache");
            task.etat = res->getString("etat");
            task.assigneeName = res->getString("assigneeName");

            tasks.push_back(task);
        }

        std::cout << "Found " << tasks.size() << " tasks for user " << userId << std::endl;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getTasksByUser: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load user tasks from database");
    }

    return tasks;
}

int DatabaseManager::createTask(const TaskData& task) {
    try {
        std::cout << "=== Creating Task ===" << std::endl;
        std::cout << "idProject: " << task.idProject << std::endl;
        std::cout << "memProcessigner: " << task.memProcessigner << std::endl;
        std::cout << "idParentTache: " << task.idParentTache << std::endl;
        std::cout << "nomTache: " << task.nomTache << std::endl;
        std::cout << "descTache: " << task.descTache << std::endl;
        std::cout << "dateFin: " << task.dateFin << std::endl;
        std::cout << "tempsTache: " << task.tempsTache << std::endl;

        const std::string sql =
            "INSERT INTO Tache (idProject, memProcessigner, idParentTache, nomTache, "
            "descTache, dateDebut, dateFin, tempsTache, etat) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, task.idProject);

        if (task.memProcessigner > 0)
            stmt->setInt(2, task.memProcessigner);
        else
            stmt->setNull(2, 0);

        if (task.idParentTache > 0)
            stmt->setInt(3, task.idParentTache);
        else
            stmt->setNull(3, 0);

        stmt->setString(4, task.nomTache);
        stmt->setString(5, task.descTache);
        stmt->setString(6, task.dateDebut);
        stmt->setString(7, task.dateFin);
        stmt->setInt(8, task.tempsTache);
        stmt->setString(9, task.etat);

        std::cout << "Executing SQL insert..." << std::endl;
        int affectedRows = stmt->executeUpdate();
        std::cout << "Affected rows: " << affectedRows << std::endl;

        if (affectedRows > 0) {
            std::unique_ptr<sql::Statement> idStmt(connection->createStatement());
            std::unique_ptr<sql::ResultSet> res(idStmt->executeQuery("SELECT LAST_INSERT_ID()"));
            if (res->next()) {
                int newId = res->getInt(1);
                std::cout << "Task created with ID: " << newId << std::endl;
                return newId;
            }
        }

        return -1;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "=== SQL Error in createTask ===" << std::endl;
        std::cerr << "Error message: " << e.what() << std::endl;
        std::cerr << "Error code: " << e.getErrorCode() << std::endl;
        std::cerr << "SQL state: " << e.getSQLState() << std::endl;

        // Try to give more specific error info
        std::string errorMsg = e.what();
        if (errorMsg.find("foreign key") != std::string::npos) {
            std::cerr << "FOREIGN KEY CONSTRAINT failed - check if idProject or memProcessigner reference valid records" << std::endl;
        }
        if (errorMsg.find("Duplicate entry") != std::string::npos) {
            std::cerr << "DUPLICATE ENTRY - primary key already exists" << std::endl;
        }

        throw std::runtime_error(std::string("Failed to create task: ") + e.what());
    }
}

bool DatabaseManager::updateTask(const TaskData& task) {
    try {
        std::cout << "=== Updating Task ===" << std::endl;
        std::cout << "idTache: " << task.idTache << std::endl;
        std::cout << "nomTache: " << task.nomTache << std::endl;
        std::cout << "descTache: " << task.descTache << std::endl;
        std::cout << "memProcessigner: " << task.memProcessigner << std::endl;
        std::cout << "tempsTache: " << task.tempsTache << std::endl;
        std::cout << "dateDebut: " << task.dateDebut << std::endl;
        std::cout << "dateFin: " << task.dateFin << std::endl;
        std::cout << "etat: " << task.etat << std::endl;

        const std::string sql =
            "UPDATE Tache SET nomTache = ?, descTache = ?, memProcessigner = ?, "
            "tempsTache = ?, dateDebut = ?, dateFin = ?, etat = ? "
            "WHERE idTache = ?";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setString(1, task.nomTache);
        stmt->setString(2, task.descTache);

        // Handle NULL for memProcessigner
        if (task.memProcessigner > 0)
            stmt->setInt(3, task.memProcessigner);
        else
            stmt->setNull(3, 0);

        stmt->setInt(4, task.tempsTache);
        stmt->setString(5, task.dateDebut);
        stmt->setString(6, task.dateFin);
        stmt->setString(7, task.etat);
        stmt->setInt(8, task.idTache);

        std::cout << "Executing UPDATE..." << std::endl;
        int affectedRows = stmt->executeUpdate();
        std::cout << "Affected rows: " << affectedRows << std::endl;

        return affectedRows > 0;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "=== SQL Error in updateTask ===" << std::endl;
        std::cerr << "Error message: " << e.what() << std::endl;
        std::cerr << "Error code: " << e.getErrorCode() << std::endl;
        throw std::runtime_error("Failed to update task in database");
    }
}

bool DatabaseManager::deleteTask(int taskId) {
    try {
        const std::string sql = "DELETE FROM Tache WHERE idTache = ?";
        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, taskId);

        int affectedRows = stmt->executeUpdate();
        return affectedRows > 0;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in deleteTask: " << e.what() << std::endl;
        throw std::runtime_error("Failed to delete task from database");
    }
}

TaskData DatabaseManager::getTaskById(int taskId) {
    TaskData task;

    try {
        std::cout << "=== Getting Task by ID: " << taskId << " ===" << std::endl;

        const std::string sql =
            "SELECT t.idTache, t.idProject, t.memProcessigner, t.idParentTache, "
            "t.nomTache, t.descTache, t.dateDebut, t.dateFin, t.tempsTache, t.etat, "
            "CONCAT(e.prenomEmploye, ' ', e.nomEmploye) as assigneeName "
            "FROM Tache t "
            "LEFT JOIN Employe e ON t.memProcessigner = e.idEmploye "
            "WHERE t.idTache = ?";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, taskId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        if (res->next()) {
            task.idTache = res->getInt("idTache");
            task.idProject = res->getInt("idProject");
            task.memProcessigner = res->getInt("memProcessigner");
            task.idParentTache = res->isNull("idParentTache") ? 0 : res->getInt("idParentTache");
            task.nomTache = res->getString("nomTache");
            task.descTache = res->getString("descTache");
            task.dateDebut = res->getString("dateDebut");
            task.dateFin = res->getString("dateFin");
            task.tempsTache = res->getInt("tempsTache");
            task.etat = res->getString("etat");
            task.assigneeName = res->getString("assigneeName");

            std::cout << "Task found: " << task.nomTache << std::endl;
            std::cout << "  ID: " << task.idTache << std::endl;
            std::cout << "  etat: " << task.etat << std::endl;
            std::cout << "  dateDebut: " << task.dateDebut << std::endl;
            std::cout << "  dateFin: " << task.dateFin << std::endl;
            std::cout << "  tempsTache: " << task.tempsTache << std::endl;
            std::cout << "  memProcessigner: " << task.memProcessigner << std::endl;
        }
        else {
            std::cerr << "Task not found with ID: " << taskId << std::endl;
            throw std::runtime_error("Task not found with ID: " + std::to_string(taskId));
        }
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getTaskById: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load task from database");
    }

    return task;
}

bool DatabaseManager::assignTaskToEmployee(int taskId, int employeeId) {
    try {
        const std::string sql = "UPDATE Tache SET memProcessigner = ? WHERE idTache = ?";
        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, employeeId);
        stmt->setInt(2, taskId);

        int affectedRows = stmt->executeUpdate();
        return affectedRows > 0;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in assignTaskToEmployee: " << e.what() << std::endl;
        throw std::runtime_error("Failed to assign task to employee");
    }
}

// SubTask methods implementation
std::vector<TaskData> DatabaseManager::getSubTasksByTask(int parentTaskId) {
    std::vector<TaskData> subTasks;

    try {
        std::cout << "=== Getting SubTasks for parent task: " << parentTaskId << " ===" << std::endl;

        const std::string sql =
            "SELECT t.idTache, t.idProject, t.memProcessigner, t.idParentTache, "
            "t.nomTache, t.descTache, t.dateDebut, t.dateFin, t.tempsTache, t.etat, "
            "CONCAT(e.prenomEmploye, ' ', e.nomEmploye) as assigneeName "
            "FROM Tache t "
            "LEFT JOIN Employe e ON t.memProcessigner = e.idEmploye "
            "WHERE t.idParentTache = ? "
            "ORDER BY t.dateDebut ASC";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, parentTaskId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            TaskData task;
            task.idTache = res->getInt("idTache");
            task.idProject = res->getInt("idProject");
            task.memProcessigner = res->getInt("memProcessigner");
            task.idParentTache = res->getInt("idParentTache");
            task.nomTache = res->getString("nomTache");
            task.descTache = res->getString("descTache");
            task.dateDebut = res->getString("dateDebut");
            task.dateFin = res->getString("dateFin");
            task.tempsTache = res->getInt("tempsTache");
            task.etat = res->getString("etat");
            task.assigneeName = res->getString("assigneeName");

            std::cout << "Found subtask: " << task.nomTache << " (ID: " << task.idTache
                << ", etat: " << task.etat << ", dateDebut: " << task.dateDebut << ")" << std::endl;

            subTasks.push_back(task);
        }

        std::cout << "Total subtasks found: " << subTasks.size() << std::endl;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getSubTasksByTask: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load subtasks from database");
    }

    return subTasks;
}

int DatabaseManager::createSubTask(int parentTaskId, const TaskData& subTask) {
    try {
        std::cout << "=== Creating SubTask ===" << std::endl;
        std::cout << "parentTaskId: " << parentTaskId << std::endl;
        std::cout << "nomTache: " << subTask.nomTache << std::endl;
        std::cout << "descTache: " << subTask.descTache << std::endl;
        std::cout << "memProcessigner: " << subTask.memProcessigner << std::endl;
        std::cout << "dateDebut: " << subTask.dateDebut << std::endl;
        std::cout << "dateFin: " << subTask.dateFin << std::endl;
        std::cout << "tempsTache: " << subTask.tempsTache << std::endl;
        std::cout << "etat: " << subTask.etat << std::endl;

        // First verify that parent task exists and get its project
        const std::string checkSql = "SELECT idProject FROM Tache WHERE idTache = ?";
        std::unique_ptr<sql::PreparedStatement> checkStmt(connection->prepareStatement(checkSql));
        checkStmt->setInt(1, parentTaskId);
        std::unique_ptr<sql::ResultSet> checkRes(checkStmt->executeQuery());

        if (!checkRes->next()) {
            throw std::runtime_error("Parent task does not exist");
        }

        int projectId = checkRes->getInt("idProject");
        std::cout << "Parent task found, projectId: " << projectId << std::endl;

        // Create subtask with parent reference - NOW INCLUDING ALL FIELDS
        const std::string sql =
            "INSERT INTO Tache (idProject, memProcessigner, idParentTache, nomTache, "
            "descTache, dateDebut, dateFin, tempsTache, etat) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, projectId);  // Use parent's project

        // Handle NULL for memProcessigner
        if (subTask.memProcessigner > 0)
            stmt->setInt(2, subTask.memProcessigner);
        else
            stmt->setNull(2, 0);

        stmt->setInt(3, parentTaskId);  // Set parent reference
        stmt->setString(4, subTask.nomTache);
        stmt->setString(5, subTask.descTache);
        stmt->setString(6, subTask.dateDebut);   // NOW INCLUDED
        stmt->setString(7, subTask.dateFin);     // NOW INCLUDED
        stmt->setInt(8, subTask.tempsTache);
        stmt->setString(9, subTask.etat);        // NOW INCLUDED

        std::cout << "Executing SQL insert for subtask..." << std::endl;
        int affectedRows = stmt->executeUpdate();
        std::cout << "Affected rows: " << affectedRows << std::endl;

        if (affectedRows > 0) {
            std::unique_ptr<sql::Statement> idStmt(connection->createStatement());
            std::unique_ptr<sql::ResultSet> res(idStmt->executeQuery("SELECT LAST_INSERT_ID()"));
            if (res->next()) {
                int newId = res->getInt(1);
                std::cout << "SubTask created with ID: " << newId << std::endl;
                return newId;
            }
        }

        return -1;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "=== SQL Error in createSubTask ===" << std::endl;
        std::cerr << "Error message: " << e.what() << std::endl;
        std::cerr << "Error code: " << e.getErrorCode() << std::endl;
        std::cerr << "SQL state: " << e.getSQLState() << std::endl;
        throw std::runtime_error(std::string("Failed to create subtask: ") + e.what());
    }
}

bool DatabaseManager::deleteSubTask(int taskId) {
    try {
        // Recursively delete all child tasks first
        std::vector<TaskData> children = getSubTasksByTask(taskId);
        for (const auto& child : children) {
            deleteSubTask(child.idTache);  // Recursive call
        }

        // Now delete this task
        const std::string sql = "DELETE FROM Tache WHERE idTache = ?";
        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, taskId);

        int affectedRows = stmt->executeUpdate();
        return affectedRows > 0;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in deleteSubTask: " << e.what() << std::endl;
        throw std::runtime_error("Failed to delete subtask from database");
    }
}

// Employee methods implementation
std::vector<std::tuple<int, std::string, std::string>> DatabaseManager::getAllEmployees() {
    std::vector<std::tuple<int, std::string, std::string>> employees;

    try {
        const std::string sql = "SELECT idEmploye, nomEmploye, prenomEmploye FROM Employe ORDER BY nomEmploye, prenomEmploye";
        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            employees.emplace_back(
                res->getInt("idEmploye"),
                res->getString("nomEmploye"),
                res->getString("prenomEmploye")
            );
        }
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getAllEmployees: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load employees from database");
    }

    return employees;
}

std::vector<std::tuple<int, std::string, std::string>> DatabaseManager::getEmployeesByDepartment(int departmentId) {
    std::vector<std::tuple<int, std::string, std::string>> employees;

    try {
        const std::string sql =
            "SELECT idEmploye, nomEmploye, prenomEmploye FROM Employe "
            "WHERE idDepartement = ? ORDER BY nomEmploye, prenomEmploye";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, departmentId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            employees.emplace_back(
                res->getInt("idEmploye"),
                res->getString("nomEmploye"),
                res->getString("prenomEmploye")
            );
        }
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getEmployeesByDepartment: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load department employees from database");
    }

    return employees;
}

std::vector<TaskData> DatabaseManager::getTasksByProject(int projectId) {
    std::vector<TaskData> tasks;

    try {
        const std::string sql =
            "SELECT t.idTache, t.idProject, t.memProcessigner, t.idParentTache, "
            "t.nomTache, t.descTache, t.dateDebut, t.dateFin, t.tempsTache, t.etat, "
            "CONCAT(e.prenomEmploye, ' ', e.nomEmploye) as assigneeName "
            "FROM Tache t "
            "LEFT JOIN Employe e ON t.memProcessigner = e.idEmploye "
            "WHERE t.idProject = ? AND (t.idParentTache IS NULL OR t.idParentTache = 0) "
            "ORDER BY t.dateDebut ASC";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, projectId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            TaskData task;
            task.idTache = res->getInt("idTache");
            task.idProject = res->getInt("idProject");
            task.memProcessigner = res->getInt("memProcessigner");
            task.idParentTache = res->isNull("idParentTache") ? 0 : res->getInt("idParentTache");
            task.nomTache = res->getString("nomTache");
            task.descTache = res->getString("descTache");
            task.dateDebut = res->getString("dateDebut");
            task.dateFin = res->getString("dateFin");
            task.tempsTache = res->getInt("tempsTache");
            task.etat = res->getString("etat");
            task.assigneeName = res->getString("assigneeName");

            tasks.push_back(task);
        }
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getTasksByProject: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load tasks from database");
    }

    return tasks;
}
