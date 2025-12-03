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
#include <tuple> // Pour les méthodes employées

// =====================================================================
// CONSTRUCTEUR / DESTRUCTEUR / CONNEXION
// =====================================================================

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

        std::string connectionString = "tcp://" + server + ":3306";
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

        if (connection->isClosed()) {
            throw std::runtime_error("Connection was closed immediately after opening");
        }

        std::cout << "Database connection established successfully." << std::endl;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error during connection: " << e.what() << std::endl;
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

// =====================================================================
// AUTHENTIFICATION
// =====================================================================

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
            // NOTE: intToRole est une fonction présumée dans le contexte du projet
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
        User* user = findUserByEmail(email);
        if (!user) {
            std::cout << "No user found with email: " << email << std::endl;
            return nullptr;
        }

        // Vérification du mot de passe haché (implémentation dans Security::verifyPassword)
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

// =====================================================================
// MÉTHODES PROJET
// =====================================================================

std::vector<ProjectData> DatabaseManager::getAllProjects() {
    std::vector<ProjectData> projects;

    try {
        // NOTE: Ajout de 'p.idDepartement' pour la consistance avec les autres méthodes
        const std::string sql =
            "SELECT p.idProject, p.idClient, p.idDepartement, p.nomProject, "
            "p.tempsProject, p.coutService, p.etatProject, c.nomClient "
            "FROM Project p "
            "LEFT JOIN Client c ON p.idClient = c.idClient "
            "ORDER BY p.idProject DESC";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            ProjectData project;
            project.idProject = res->getInt("idProject");
            project.idClient = res->getInt("idClient");
            project.idDepartement = res->getInt("idDepartement");
            project.nomProject = res->getString("nomProject");
            project.tempsProject = res->getDouble("tempsProject");
            project.coutService = res->getDouble("coutService");
            project.etatProject = res->getString("etatProject");
            project.nomClient = res->getString("nomClient");
            // project.estTemplate = res->getBoolean("estTemplate"); // Colonne absente de la requête SQL d'origine

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
        const std::string sql =
            "SELECT DISTINCT p.idProject, p.idClient, p.idDepartement, p.nomProject, "
            "p.tempsProject, p.coutService, p.etatProject, c.nomClient "
            "FROM Project p "
            "LEFT JOIN Client c ON p.idClient = c.idClient "
            "INNER JOIN Tache t ON p.idProject = t.idProject "
            "WHERE t.idEmploye = ? "
            "ORDER BY p.idProject DESC";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, userId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            ProjectData project;
            project.idProject = res->getInt("idProject");
            project.idClient = res->getInt("idClient");
            project.idDepartement = res->getInt("idDepartement");
            project.nomProject = res->getString("nomProject");
            project.tempsProject = res->getDouble("tempsProject");
            project.coutService = res->getDouble("coutService");
            project.etatProject = res->getString("etatProject");
            project.nomClient = res->getString("nomClient");

            projects.push_back(project);
        }
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
            "p.tempsProject, p.coutService, p.etatProject, c.nomClient "
            "FROM Project p "
            "LEFT JOIN Client c ON p.idClient = c.idClient "
            "WHERE p.idDepartement = ? "
            "ORDER BY p.idProject DESC";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, departmentId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            ProjectData project;
            project.idProject = res->getInt("idProject");
            project.idClient = res->getInt("idClient");
            project.idDepartement = res->getInt("idDepartement");
            project.nomProject = res->getString("nomProject");
            project.tempsProject = res->getDouble("tempsProject");
            project.coutService = res->getDouble("coutService");
            project.etatProject = res->getString("etatProject");
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

/**
 * @brief Crée un nouveau projet et retourne son ID généré.
 */
int DatabaseManager::createProject(const ProjectData& project) {
    try {
        const std::string sql =
            "INSERT INTO Project (idClient, idDepartement, nomProject, coutService) "
            "VALUES (?, ?, ?, ?)";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));

        // Liens des paramètres
        stmt->setInt(1, project.idClient);
        stmt->setInt(2, project.idDepartement);
        stmt->setString(3, project.nomProject);
        stmt->setDouble(4, project.coutService);

        int affectedRows = stmt->executeUpdate();

        if (affectedRows > 0) {
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

/**
 * @brief Met à jour les informations d'un projet existant.
 */
bool DatabaseManager::updateProject(const ProjectData& project) {
    try {
        const std::string sql =
            "UPDATE Project SET idClient = ?, idDepartement = ?, nomProject = ?, tempsProject = ?, coutService = ?, etatProject = ? "
            "WHERE idProject = ?";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));

        // Liens des paramètres
        stmt->setInt(1, project.idClient);
        stmt->setInt(2, project.idDepartement);
        stmt->setString(3, project.nomProject);
        // Utilisation de setDouble pour les champs numériques (gestion de NULL à améliorer si nécessaire)
        stmt->setDouble(4, project.tempsProject); // Ou setNull(4, 0) si le champ doit être NULL
        stmt->setDouble(5, project.coutService);
        stmt->setString(6, project.etatProject);
        stmt->setInt(7, project.idProject);

        int affectedRows = stmt->executeUpdate();
        return affectedRows > 0;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in updateProject: " << e.what() << std::endl;
        throw std::runtime_error("Failed to update project in database");
    }
}


/**
 * @brief Supprime un projet en se basant sur son ID.
 * * **Simplifié grâce au 'ON DELETE CASCADE'** du SGBD.
 * * @param projectId L'ID du projet à supprimer.
 * @return true si le projet a été supprimé, false sinon.
 */
bool DatabaseManager::deleteProject(int projectId) {
    try {
        std::cout << "=== Deleting Project (Cascade) ===" << std::endl;
        std::cout << "Project ID: " << projectId << std::endl;

        const std::string sql = "DELETE FROM Project WHERE idProject = ?";
        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, projectId);

        int affectedRows = stmt->executeUpdate();
        return affectedRows > 0;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in deleteProject (Cascade): " << e.what() << std::endl;
        throw std::runtime_error("Failed to delete project from database");
    }
}


ProjectData DatabaseManager::getProjectById(int projectId) {
    ProjectData project;

    try {
        const std::string sql =
            "SELECT idProject, COALESCE(idClient, 0) as idClient, COALESCE(idDepartement, 0) as idDepartement, "
            "COALESCE(nomProject, '') as nomProject, COALESCE(coutService, 0) as coutService, "
            "COALESCE(tempsProject, 0) as tempsProject, COALESCE(etatProject, '') as etatProject "
            "FROM Project WHERE idProject = ?";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, projectId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        if (res->next()) {
            project.idProject = res->getInt("idProject");
            project.idClient = res->getInt("idClient");
            project.idDepartement = res->getInt("idDepartement");
            project.nomProject = res->getString("nomProject");
            project.coutService = res->getDouble("coutService");
            project.tempsProject = res->getDouble("tempsProject");
            project.etatProject = res->getString("etatProject");
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

// =====================================================================
// MÉTHODES CLIENTS
// =====================================================================

std::vector<std::pair<int, std::string>> DatabaseManager::getAllClients() {
    std::vector<std::pair<int, std::string>> clients;

    try {
        const std::string sql = "SELECT idClient, nomClient FROM Client ORDER BY nomClient";
        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            clients.emplace_back(res->getInt("idClient"), res->getString("nomClient"));
        }
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getAllClients: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load clients from database");
    }

    return clients;
}

// =====================================================================
// MÉTHODES TÂCHES
// =====================================================================

/**
 * @brief Récupère uniquement les tâches racines (idParentTache IS NULL/0) d'un projet.
 */
std::vector<TaskData> DatabaseManager::getTasksByProject(int projectId) {
    std::vector<TaskData> tasks;

    try {
        const std::string sql =
            "SELECT idTache, idProject, idEmploye, nomTache, descTache, dateDebut, dateFin, "
            "COALESCE(heuresEstimees, 0) as heuresEstimees, COALESCE(heuresUtilisees, 0) as heuresUtilisees, etatTache "
            "FROM Tache "
            "WHERE idProject = ? AND (idParentTache IS NULL OR idParentTache = 0) " // Filtre TÂCHES RACINES
            "ORDER BY idTache ASC";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, projectId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            TaskData task;
            task.idTache = res->getInt("idTache");
            task.idProject = res->getInt("idProject");
            task.idEmploye = res->getInt("idEmploye");
            task.nomTache = res->getString("nomTache");
            task.descTache = res->getString("descTache");
            task.dateDebut = res->getString("dateDebut");
            task.dateFin = res->getString("dateFin");
            task.heuresEstimees = res->getDouble("heuresEstimees");
            task.heuresUtilisees = res->getDouble("heuresUtilisees");
            task.etat = res->getString("etatTache");
            tasks.push_back(task);
        }
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getTasksByProject: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load project tasks from database");
    }

    return tasks;
}

std::vector<TaskData> DatabaseManager::getTasksByUser(int userId) {
    std::vector<TaskData> tasks;

    try {
        const std::string sql =
            "SELECT t.idTache, t.idProject, t.idEmploye, t.idParentTache, "
            "t.nomTache, t.descTache, t.dateDebut, t.dateFin, t.heuresEstimees, t.heuresUtilisees, t.etatTache "
            "FROM Tache t "
            "WHERE t.idEmploye = ? "
            "ORDER BY t.dateDebut ASC";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, userId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            TaskData task;
            task.idTache = res->getInt("idTache");
            task.idProject = res->getInt("idProject");
            task.idEmploye = res->getInt("idEmploye");
            task.idParentTache = res->isNull("idParentTache") ? 0 : res->getInt("idParentTache");
            task.nomTache = res->getString("nomTache");
            task.descTache = res->getString("descTache");
            task.dateDebut = res->getString("dateDebut");
            task.dateFin = res->getString("dateFin");
            task.heuresEstimees = res->getDouble("heuresEstimees");
            task.heuresUtilisees = res->getDouble("heuresUtilisees");
            task.etat = res->getString("etatTache");

            tasks.push_back(task);
        }
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getTasksByUser: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load user tasks from database");
    }

    return tasks;
}

/**
 * @brief Crée une nouvelle tâche (racine ou enfant) et retourne son ID.
 */
int DatabaseManager::createTask(const TaskData& task) {
    try {
        const std::string sql =
            "INSERT INTO Tache (idProject, idEmploye, idParentTache, nomTache, "
            "descTache, dateDebut, dateFin, heuresEstimees, heuresUtilisees, etatTache) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, ?)";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, task.idProject);

        if (task.idEmploye > 0)
            stmt->setInt(2, task.idEmploye);
        else
            stmt->setNull(2, sql::DataType::INTEGER); // idEmploye peut être NULL

        if (task.idParentTache > 0)
            stmt->setInt(3, task.idParentTache);
        else
            stmt->setNull(3, sql::DataType::INTEGER); // idParentTache peut être NULL

        stmt->setString(4, task.nomTache);
        stmt->setString(5, task.descTache);
        stmt->setString(6, task.dateDebut);
        stmt->setString(7, task.dateFin);
        stmt->setDouble(8, task.heuresEstimees);
        stmt->setString(9, task.etat);

        int affectedRows = stmt->executeUpdate();

        if (affectedRows > 0) {
            std::unique_ptr<sql::Statement> idStmt(connection->createStatement());
            std::unique_ptr<sql::ResultSet> res(idStmt->executeQuery("SELECT LAST_INSERT_ID()"));
            if (res->next()) {
                return res->getInt(1);
            }
        }

        return -1;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in createTask: " << e.what() << std::endl;
        throw std::runtime_error(std::string("Failed to create task: ") + e.what());
    }
}

/**
 * @brief Met à jour les informations d'une tâche existante.
 */
bool DatabaseManager::updateTask(const TaskData& task) {
    try {
        const std::string sql =
            "UPDATE Tache SET nomTache = ?, descTache = ?, idEmploye = ?, "
            "heuresEstimees = ?, heuresUtilisees = ?, dateDebut = ?, dateFin = ?, etatTache = ? "
            "WHERE idTache = ?";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setString(1, task.nomTache);
        stmt->setString(2, task.descTache);

        if (task.idEmploye > 0)
            stmt->setInt(3, task.idEmploye);
        else
            stmt->setNull(3, sql::DataType::INTEGER); // idEmploye peut être NULL

        stmt->setDouble(4, task.heuresEstimees);
        stmt->setDouble(5, task.heuresUtilisees);
        stmt->setString(6, task.dateDebut);
        stmt->setString(7, task.dateFin);
        stmt->setString(8, task.etat);
        stmt->setInt(9, task.idTache);

        int affectedRows = stmt->executeUpdate();
        return affectedRows > 0;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in updateTask: " << e.what() << std::endl;
        throw std::runtime_error("Failed to update task in database");
    }
}


/**
 * @brief Supprime une tâche, et toutes ses sous-tâches, en se basant sur son ID.
 * * **Simplifié grâce au 'ON DELETE CASCADE'** du SGBD.
 * * @param taskId L'ID de la tâche à supprimer.
 * @return true si la tâche a été supprimée, false sinon.
 */
bool DatabaseManager::deleteTask(int taskId) {
    try {
        std::cout << "=== Deleting Task (Cascade) ===" << std::endl;
        std::cout << "Task ID: " << taskId << std::endl;

        const std::string sql = "DELETE FROM Tache WHERE idTache = ?";
        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, taskId);

        int affectedRows = stmt->executeUpdate();
        return affectedRows > 0;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in deleteTask (Cascade): " << e.what() << std::endl;
        throw std::runtime_error("Failed to delete task from database");
    }
}


TaskData DatabaseManager::getTaskById(int taskId) {
    TaskData task;

    try {
        const std::string sql =
            "SELECT idTache, idProject, nomTache, etatTache, "
            "COALESCE(idEmploye, 0) as idEmploye, "
            "COALESCE(idParentTache, 0) as idParentTache, "
            "COALESCE(descTache, '') as descTache, "
            "COALESCE(dateDebut, '') as dateDebut, "
            "COALESCE(dateFin, '') as dateFin, "
            "COALESCE(heuresEstimees, 0) as heuresEstimees, "
            "COALESCE(heuresUtilisees, 0) as heuresUtilisees "
            "FROM Tache WHERE idTache = ?";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, taskId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        if (res->next()) {
            task.idTache = res->getInt("idTache");
            task.idProject = res->getInt("idProject");
            task.idEmploye = res->getInt("idEmploye");
            task.idParentTache = res->getInt("idParentTache");
            task.nomTache = res->getString("nomTache");
            task.descTache = res->getString("descTache");
            task.dateDebut = res->getString("dateDebut");
            task.dateFin = res->getString("dateFin");
            task.heuresEstimees = res->getDouble("heuresEstimees");
            task.heuresUtilisees = res->getDouble("heuresUtilisees");
            task.etat = res->getString("etatTache");
        }
        else {
            throw std::runtime_error("Task not found with ID: " + std::to_string(taskId));
        }
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getTaskById: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load task from database");
    }

    return task;
}

/**
 * @brief Assigne une tâche existante à un employé.
 */
bool DatabaseManager::assignTaskToEmployee(int taskId, int employeeId) {
    try {
        const std::string sql = "UPDATE Tache SET idEmploye = ? WHERE idTache = ?";
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


// =====================================================================
// MÉTHODES SOUS-TÂCHES
// =====================================================================

/**
 * @brief Récupère toutes les sous-tâches directes d'une tâche parente.
 */
std::vector<TaskData> DatabaseManager::getSubTasksByTask(int parentTaskId) {
    std::vector<TaskData> subTasks;

    try {
        const std::string sql =
            "SELECT t.idTache, t.idProject, t.nomTache, t.etatTache, "
            "COALESCE(t.idEmploye, 0) as idEmploye, t.idParentTache, "
            "COALESCE(t.descTache, '') as descTache, COALESCE(t.dateDebut, '') as dateDebut, "
            "COALESCE(t.dateFin, '') as dateFin, COALESCE(t.heuresEstimees, 0) as heuresEstimees, "
            "COALESCE(t.heuresUtilisees, 0) as heuresUtilisees, "
            "COALESCE(CONCAT(e.prenomEmploye, ' ', e.nomEmploye), 'Non assigné') as assigneeName "
            "FROM Tache t "
            "LEFT JOIN Employe e ON t.idEmploye = e.idEmploye "
            "WHERE t.idParentTache = ? "
            "ORDER BY t.idTache ASC";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, parentTaskId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            TaskData task;
            task.idTache = res->getInt("idTache");
            task.idProject = res->getInt("idProject");
            task.idEmploye = res->getInt("idEmploye");
            task.idParentTache = res->getInt("idParentTache");
            task.nomTache = res->getString("nomTache");
            task.descTache = res->getString("descTache");
            task.dateDebut = res->getString("dateDebut");
            task.dateFin = res->getString("dateFin");
            task.heuresEstimees = res->getDouble("heuresEstimees");
            task.heuresUtilisees = res->getDouble("heuresUtilisees");
            task.etat = res->getString("etatTache");
            task.assigneeName = res->getString("assigneeName");

            subTasks.push_back(task);
        }
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getSubTasksByTask: " << e.what() << std::endl;
    }

    return subTasks;
}


/**
 * @brief Crée une nouvelle sous-tâche pour une tâche parente spécifiée.
 */
int DatabaseManager::createSubTask(int parentTaskId, const TaskData& subTask) {
    try {
        // 1. Trouver l'idProject de la tâche parente
        const std::string checkSql = "SELECT idProject FROM Tache WHERE idTache = ?";
        std::unique_ptr<sql::PreparedStatement> checkStmt(connection->prepareStatement(checkSql));
        checkStmt->setInt(1, parentTaskId);
        std::unique_ptr<sql::ResultSet> checkRes(checkStmt->executeQuery());

        if (!checkRes->next()) {
            throw std::runtime_error("Parent task does not exist");
        }
        int projectId = checkRes->getInt("idProject");

        // 2. Insérer la sous-tâche avec idProject et idParentTache
        const std::string sql =
            "INSERT INTO Tache (idProject, idEmploye, idParentTache, nomTache, "
            "descTache, dateDebut, dateFin, heuresEstimees, heuresUtilisees, etatTache) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, ?)";

        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, projectId); // Utilise le projet du parent

        if (subTask.idEmploye > 0)
            stmt->setInt(2, subTask.idEmploye);
        else
            stmt->setNull(2, sql::DataType::INTEGER); // idEmploye peut être NULL

        stmt->setInt(3, parentTaskId); // Définition de l'ID Parent

        stmt->setString(4, subTask.nomTache);
        stmt->setString(5, subTask.descTache);
        stmt->setString(6, subTask.dateDebut);
        stmt->setString(7, subTask.dateFin);
        stmt->setDouble(8, subTask.heuresEstimees);
        stmt->setString(9, subTask.etat);

        int affectedRows = stmt->executeUpdate();

        if (affectedRows > 0) {
            std::unique_ptr<sql::Statement> idStmt(connection->createStatement());
            std::unique_ptr<sql::ResultSet> res(idStmt->executeQuery("SELECT LAST_INSERT_ID()"));
            if (res->next()) {
                return res->getInt(1);
            }
        }

        return -1;
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in createSubTask: " << e.what() << std::endl;
        throw std::runtime_error(std::string("Failed to create subtask: ") + e.what());
    }
}

/**
 * @brief Supprime une sous-tâche (identique à deleteTask).
 * * **Simplifié grâce au 'ON DELETE CASCADE'** du SGBD.
 */
bool DatabaseManager::deleteSubTask(int taskId) {
    // La suppression d'une sous-tâche est identique à la suppression de tâche racine
    // car le SGBD gère la suppression des sous-enfants.
    return deleteTask(taskId);
}

// =====================================================================
// MÉTHODES EMPLOYÉS
// =====================================================================

/**
 * @brief Récupère tous les employés (ID, prénom, nom) de la base de données.
 * @return std::vector<std::tuple<int, std::string, std::string>> : Liste de (idEmploye, prenomEmploye, nomEmploye).
 */
std::vector<std::tuple<int, std::string, std::string>> DatabaseManager::getAllEmployees() {
    std::vector<std::tuple<int, std::string, std::string>> employees;

    try {
        const std::string sql = "SELECT idEmploye, prenomEmploye, nomEmploye FROM Employe ORDER BY nomEmploye, prenomEmploye";
        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            employees.emplace_back(
                res->getInt("idEmploye"),
                res->getString("prenomEmploye"),
                res->getString("nomEmploye")
            );
        }
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getAllEmployees: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load employees from database");
    }

    return employees;
}

/**
 * @brief Récupère tous les employés (ID, prénom, nom) appartenant à un département donné.
 * @param departmentId : L'ID du département à filtrer.
 * @return std::vector<std::tuple<int, std::string, std::string>> : Liste de (idEmploye, prenomEmploye, nomEmploye).
 */
std::vector<std::tuple<int, std::string, std::string>> DatabaseManager::getEmployeesByDepartment(int departmentId) {
    std::vector<std::tuple<int, std::string, std::string>> employees;

    try {
        const std::string sql =
            "SELECT idEmploye, prenomEmploye, nomEmploye FROM Employe WHERE idDepartement = ? "
            "ORDER BY nomEmploye, prenomEmploye";
        std::unique_ptr<sql::PreparedStatement> stmt(connection->prepareStatement(sql));
        stmt->setInt(1, departmentId);
        std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

        while (res->next()) {
            employees.emplace_back(
                res->getInt("idEmploye"),
                res->getString("prenomEmploye"),
                res->getString("nomEmploye")
            );
        }
    }
    catch (const sql::SQLException& e) {
        std::cerr << "SQL Error in getEmployeesByDepartment: " << e.what() << std::endl;
        throw std::runtime_error("Failed to load department employees from database");
    }

    return employees;
}