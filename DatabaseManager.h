#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <string>
#include <vector>
#include <utility>
#include "ProjectData.h"
#include "TaskData.h"

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

    // Project methods
    std::vector<ProjectData> getAllProjects();
    std::vector<ProjectData> getProjectsByUser(int userId);
    std::vector<ProjectData> getProjectsByDepartment(int departmentId);
    int createProject(const ProjectData& project);
    bool updateProject(const ProjectData& project);
    bool deleteProject(int projectId);
    ProjectData getProjectById(int projectId);
    std::vector<TaskData> getSubTasksByTask(int parentTaskId);
    // Client methods
    std::vector<std::pair<int, std::string>> getAllClients();

    // Task methods (supports hierarchical structure)
    std::vector<TaskData> getTasksByProject(int projectId);  // Returns only root tasks
    std::vector<TaskData> getTasksByUser(int userId);
    int createTask(const TaskData& task);  // Can create root or child task
    bool updateTask(const TaskData& task);
    bool deleteTask(int taskId);
    TaskData getTaskById(int taskId);
    bool assignTaskToEmployee(int taskId, int employeeId);

    // Recursive SubTask methods (subtasks are tasks with parent references)
  
    int createSubTask(int parentTaskId, const TaskData& subTask);
    bool deleteSubTask(int taskId);  // Recursively deletes task and all children

    // Employee methods
    std::vector<std::tuple<int, std::string, std::string>> getAllEmployees();
    std::vector<std::tuple<int, std::string, std::string>> getEmployeesByDepartment(int departmentId);

    //sauvegarde d'heures
    bool assignHoursToProject(int projectId, int employeeId, double hours);
    bool updateTaskHours(int taskId, double hours);


    bool saveEmployeeTaskHours(int employeeId, int taskId, double hours);
    double getEmployeeTaskHours(int employeeId, int taskId);
};

#endif
