#include "ProjectController.h"
#include "DatabaseManager.h"
#include "PermissionManager.h"
#include "User.h"
#include <QDebug>
#include <QDateTime>

ProjectController::ProjectController(DatabaseManager* dbManager, User* currentUser, QObject* parent)
    : QObject(parent)
    , m_dbManager(dbManager)
    , m_currentUser(currentUser)
    , m_loading(false)
{
    if (!m_dbManager) {
        qCritical() << "ProjectController: DatabaseManager is null!";
    }
}

ProjectController::~ProjectController()
{
    // Don't delete m_dbManager or m_currentUser - they're owned by main.cpp
}

void ProjectController::setCurrentUser(User* user)
{
    m_currentUser = user;

    if (m_currentUser) {
        qDebug() << "=== ProjectController: User set ===";
        qDebug() << "User ID:" << m_currentUser->getId();
        qDebug() << "User Email:" << QString::fromStdString(m_currentUser->getEmail());
        qDebug() << "User Dept:" << m_currentUser->getDepartementId();
        qDebug() << "User Role (int):" << static_cast<int>(m_currentUser->getRole());
        qDebug() << "User Role (string):" << QString::fromStdString(roleToString(m_currentUser->getRole()));

        // Emit signal to notify QML that user has changed
        emit currentUserChanged();
    }
    else {
        qDebug() << "ProjectController: User set to NULL";
    }
}

void ProjectController::setLoading(bool loading)
{
    if (m_loading != loading) {
        m_loading = loading;
        emit loadingChanged();
    }
}

QVariantMap ProjectController::projectDataToVariantMap(const ProjectData& project) const
{
    QVariantMap map;
    map["idProject"] = project.idProject;
    map["idClient"] = project.idClient;
    map["idDepartement"] = project.idDepartement;
    map["nomProject"] = QString::fromStdString(project.nomProject);
    map["dataProject"] = QString::fromStdString(project.dataProject);
    map["tempRepository"] = QString::fromStdString(project.tempRepository);
    map["coutService"] = project.coutService;
    map["nomClient"] = QString::fromStdString(project.nomClient);
    return map;
}

void ProjectController::loadProjects()
{
    if (!m_currentUser) {
        qWarning() << "No current user set";
        return;
    }

    qDebug() << "Loading projects for user role:" << PermissionManager::getUserRoleString(m_currentUser);
    setLoading(true);

    try {
        std::vector<ProjectData> projectsData;

        if (PermissionManager::canViewAllProjects(m_currentUser)) {
            // Admin: load all projects
            projectsData = m_dbManager->getAllProjects();
        }
        else if (PermissionManager::canViewDepartmentProjects(m_currentUser)) {
            // Gestionnaire: load department projects
            projectsData = m_dbManager->getProjectsByDepartment(m_currentUser->getDepartementId());
        }
        else {
            // Employe: load only assigned projects
            projectsData = m_dbManager->getProjectsByUser(m_currentUser->getId());
        }

        m_projects.clear();
        for (const ProjectData& project : projectsData) {
            m_projects.append(projectDataToVariantMap(project));
        }

        emit projectsChanged();
        qDebug() << "Loaded" << m_projects.size() << "projects";
    }
    catch (const std::exception& e) {
        qCritical() << "Error loading projects:" << e.what();
        emit errorOccurred(QString("Erreur: %1").arg(e.what()));
    }

    setLoading(false);
}

void ProjectController::loadProjectsByUser()
{
    if (!m_currentUser) {
        qWarning() << "ProjectController: No current user set";
        emit errorOccurred("Aucun utilisateur connecte");
        return;
    }

    qDebug() << "ProjectController: Loading projects for user" << m_currentUser->getId();
    setLoading(true);

    try {
        std::vector<ProjectData> projectsData = m_dbManager->getProjectsByUser(m_currentUser->getId());

        m_projects.clear();
        for (const auto& project : projectsData) {
            m_projects.append(projectDataToVariantMap(project));
        }

        emit projectsChanged();
        qDebug() << "ProjectController: Loaded" << m_projects.size() << "projects for user";
    }
    catch (const std::exception& e) {
        qCritical() << "ProjectController: Error loading user projects:" << e.what();
        QString errorMsg = QString("Erreur lors du chargement des projets: %1").arg(e.what());
        emit errorOccurred(errorMsg);
    }

    setLoading(false);
}

void ProjectController::loadProjectsByDepartment()
{
    if (!m_currentUser) {
        qWarning() << "ProjectController: No current user set";
        emit errorOccurred("Aucun utilisateur connecte");
        return;
    }

    qDebug() << "ProjectController: Loading projects for department" << m_currentUser->getDepartementId();
    setLoading(true);

    try {
        std::vector<ProjectData> projectsData = m_dbManager->getProjectsByDepartment(m_currentUser->getDepartementId());

        m_projects.clear();
        for (const auto& project : projectsData) {
            m_projects.append(projectDataToVariantMap(project));
        }

        emit projectsChanged();
        qDebug() << "ProjectController: Loaded" << m_projects.size() << "projects for department";
    }
    catch (const std::exception& e) {
        qCritical() << "ProjectController: Error loading department projects:" << e.what();
        QString errorMsg = QString("Erreur lors du chargement des projets: %1").arg(e.what());
        emit errorOccurred(errorMsg);
    }

    setLoading(false);
}

bool ProjectController::createProject(const QString& projectName,
    int clientId,
    const QString& repository,
    double cost,
    const QString& projectDate)
{
    if (!m_currentUser) {
        qWarning() << "ProjectController: No current user set";
        emit projectCreationFailed("Aucun utilisateur connecte");
        return false;
    }

    if (!PermissionManager::canCreateProject(m_currentUser)) {
        emit projectCreationFailed("Vous n'avez pas la permission de cr�er des projets");
        return false;
    }

    if (projectName.isEmpty()) {
        emit projectCreationFailed("Le nom du projet est requis");
        return false;
    }

    qDebug() << "ProjectController: Creating project:" << projectName;

    try {
        ProjectData newProject;
        newProject.nomProject = projectName.toStdString();
        newProject.idClient = clientId;
        newProject.idDepartement = m_currentUser->getDepartementId();
        newProject.tempRepository = repository.toStdString();
        newProject.coutService = cost;

        // Use provided date or current date
        if (projectDate.isEmpty()) {
            newProject.dataProject = QDateTime::currentDateTime().toString("yyyy-MM-dd").toStdString();
        }
        else {
            newProject.dataProject = projectDate.toStdString();
        }

        int projectId = m_dbManager->createProject(newProject);

        if (projectId > 0) {
            qDebug() << "ProjectController: Project created successfully with ID:" << projectId;
            emit projectCreated(projectId);

            // Reload projects to update the list
            loadProjectsByDepartment();
            return true;
        }
        else {
            emit projectCreationFailed("Echec de la creation du projet");
            return false;
        }
    }
    catch (const std::exception& e) {
        qCritical() << "ProjectController: Error creating project:" << e.what();
        QString errorMsg = QString("Erreur: %1").arg(e.what());
        emit projectCreationFailed(errorMsg);
        return false;
    }
}

bool ProjectController::updateProject(int projectId,
    const QString& projectName,
    const QString& repository,
    double cost)
{
    if (!canEditProject(projectId)) {
        emit projectUpdateFailed("Vous n'avez pas la permission de modifier ce projet");
        return false;
    }

    if (projectName.isEmpty()) {
        emit projectUpdateFailed("Le nom du projet est requis");
        return false;
    }

    qDebug() << "ProjectController: Updating project:" << projectId;

    try {
        ProjectData updatedProject;
        updatedProject.idProject = projectId;
        updatedProject.nomProject = projectName.toStdString();
        updatedProject.tempRepository = repository.toStdString();
        updatedProject.coutService = cost;

        bool success = m_dbManager->updateProject(updatedProject);

        if (success) {
            qDebug() << "ProjectController: Project updated successfully";
            emit projectUpdated(projectId);

            // Reload projects to update the list
            loadProjectsByDepartment();
            return true;
        }
        else {
            emit projectUpdateFailed("Echec de la mise a jour du projet");
            return false;
        }
    }
    catch (const std::exception& e) {
        qCritical() << "ProjectController: Error updating project:" << e.what();
        QString errorMsg = QString("Erreur: %1").arg(e.what());
        emit projectUpdateFailed(errorMsg);
        return false;
    }
}

bool ProjectController::deleteProject(int projectId)
{
    if (!canDeleteProject(projectId)) {
        emit projectDeletionFailed("Vous n'avez pas la permission de supprimer ce projet");
        return false;
    }

    qDebug() << "ProjectController: Deleting project:" << projectId;

    try {
        bool success = m_dbManager->deleteProject(projectId);

        if (success) {
            qDebug() << "ProjectController: Project deleted successfully";
            emit projectDeleted(projectId);

            // Reload projects to update the list
            loadProjectsByDepartment();
            return true;
        }
        else {
            emit projectDeletionFailed("Echec de la suppression du projet");
            return false;
        }
    }
    catch (const std::exception& e) {
        qCritical() << "ProjectController: Error deleting project:" << e.what();
        QString errorMsg = QString("Erreur: %1").arg(e.what());
        emit projectDeletionFailed(errorMsg);
        return false;
    }
}

QVariantList ProjectController::getClients()
{
    qDebug() << "ProjectController: Loading clients";
    QVariantList clientList;

    try {
        std::vector<std::pair<int, std::string>> clients = m_dbManager->getAllClients();

        clientList.clear(); // Clear the list first

        // Add a default empty option
        //QVariantMap defaultClient;
        //defaultClient["idClient"] = 0;
        //defaultClient["nomClient"] = "S�lectionnez un client";
        //clientList.append(defaultClient);

        for (const auto& client : clients) {
            QVariantMap clientMap;
            clientMap["idClient"] = client.first;
            clientMap["nomClient"] = QString::fromStdString(client.second);
            clientList.append(clientMap);
        }

        qDebug() << "ProjectController: Loaded" << clientList.size() << "clients";
        emit clientsLoaded(); // Emit signal when clients are loaded
    }
    catch (const std::exception& e) {
        qCritical() << "ProjectController: Error loading clients:" << e.what();
        QString errorMsg = QString("Erreur lors du chargement des clients: %1").arg(e.what());
        emit errorOccurred(errorMsg);
    }

    return clientList;
}

void ProjectController::loadClients()
{
    qDebug() << "ProjectController: Explicitly loading clients";
    // This will trigger the getClients() method and emit signals
    getClients();
}

QVariantMap ProjectController::getProjectDetails(int projectId)
{
    qDebug() << "ProjectController::getProjectDetails called for projectId:" << projectId;

    try {
        ProjectData project = m_dbManager->getProjectById(projectId);

        qDebug() << "Project retrieved from database:";
        qDebug() << "  idProject:" << project.idProject;
        qDebug() << "  nomProject:" << QString::fromStdString(project.nomProject);
        qDebug() << "  idClient:" << project.idClient;
        qDebug() << "  tempRepository:" << QString::fromStdString(project.tempRepository);
        qDebug() << "  coutService:" << project.coutService;

        QVariantMap projectMap = projectDataToVariantMap(project);

        qDebug() << "Converted to QVariantMap:";
        qDebug() << "  Keys:" << projectMap.keys();
        for (auto key : projectMap.keys()) {
            qDebug() << "    " << key << ":" << projectMap[key];
        }

        return projectMap;
    }
    catch (const std::exception& e) {
        qCritical() << "ProjectController: Error getting project details:" << e.what();
        QString errorMsg = QString("Erreur lors du chargement du projet: %1").arg(e.what());
        emit errorOccurred(errorMsg);
        return QVariantMap();
    }
}
bool ProjectController::canCreateProject() const {
    return PermissionManager::canCreateProject(m_currentUser);
}

bool ProjectController::canEditProject(int projectId) const {
    if (!m_currentUser) return false;

    try {
        ProjectData project = m_dbManager->getProjectById(projectId);
        return PermissionManager::canEditProject(m_currentUser, project.idDepartement);
    }
    catch (const std::exception& e) {
        qWarning() << "Error checking edit permission:" << e.what();
        return false;
    }
}

bool ProjectController::canDeleteProject(int projectId) const {
    if (!m_currentUser) return false;

    try {
        ProjectData project = m_dbManager->getProjectById(projectId);
        return PermissionManager::canDeleteProject(m_currentUser, project.idDepartement);
    }
    catch (const std::exception& e) {
        qWarning() << "Error checking delete permission:" << e.what();
        return false;
    }
}

bool ProjectController::canViewAllProjects() const {
    return PermissionManager::canViewAllProjects(m_currentUser);
}

QString ProjectController::getUserRole() const {
    return PermissionManager::getUserRoleString(m_currentUser);
}


QVariantList ProjectController::getTemplateProjects()
{
    qDebug() << "ProjectController: Loading template projects";
    QVariantList templateList;

    try {
        std::vector<ProjectData> projects;

        // Get projects based on user role
        if (PermissionManager::canViewAllProjects(m_currentUser)) {
            projects = m_dbManager->getAllProjects();
        }
        else if (PermissionManager::canViewDepartmentProjects(m_currentUser)) {
            projects = m_dbManager->getProjectsByDepartment(m_currentUser->getDepartementId());
        }
        else {
            projects = m_dbManager->getProjectsByUser(m_currentUser->getId());
        }

        for (const auto& project : projects) {
            QVariantMap projectMap;
            projectMap["idProject"] = project.idProject;
            projectMap["nomProject"] = QString::fromStdString(project.nomProject);
            projectMap["displayName"] = QString::fromStdString(project.nomProject) +
                " (" + QString::fromStdString(project.nomClient) + ")";
            templateList.append(projectMap);
        }

        qDebug() << "ProjectController: Loaded" << templateList.size() << "template projects";
    }
    catch (const std::exception& e) {
        qCritical() << "ProjectController: Error loading template projects:" << e.what();
        emit errorOccurred(QString("Erreur: %1").arg(e.what()));
    }

    return templateList;
}

QVariantList ProjectController::getAllProjectsForTemplate()
{
    return getTemplateProjects();
}

// Copy tasks from source project to target project
bool ProjectController::copyTaskWithChildren(int sourceTaskId, int targetProjectId, int newParentId, std::map<int, int>& taskIdMap)
{
    try {
        // Get the source task
        TaskData sourceTask = m_dbManager->getTaskById(sourceTaskId);

        TaskData newTask = sourceTask;
        newTask.idProject = targetProjectId;
        newTask.idTache = 0;
        newTask.idParentTache = newParentId;
        newTask.etat = "A faire";

        int newTaskId;
        if (newParentId > 0) {
            newTaskId = m_dbManager->createSubTask(newParentId, newTask);
        }
        else {
            newTaskId = m_dbManager->createTask(newTask);
        }

        if (newTaskId <= 0) {
            qWarning() << "Failed to create task:" << QString::fromStdString(sourceTask.nomTache);
            return false;
        }

        taskIdMap[sourceTaskId] = newTaskId;
        qDebug() << "✓ Created task:" << QString::fromStdString(sourceTask.nomTache) << "New ID:" << newTaskId;

        // Recursively copy all children
        std::vector<TaskData> childTasks = m_dbManager->getSubTasksByTask(sourceTaskId);
        for (const auto& childTask : childTasks) {
            copyTaskWithChildren(childTask.idTache, targetProjectId, newTaskId, taskIdMap);
        }

        return true;
    }
    catch (const std::exception& e) {
        qCritical() << "Error copying task with children:" << e.what();
        return false;
    }
}

bool ProjectController::copyProjectTasks(int sourceProjectId, int targetProjectId)
{
    qDebug() << "=== ProjectController::copyProjectTasks START ===";
    qDebug() << "Source Project ID:" << sourceProjectId;
    qDebug() << "Target Project ID:" << targetProjectId;

    if (!m_dbManager) {
        qCritical() << "DatabaseManager is null!";
        return false;
    }

    try {
        // Get ALL tasks from source project (including subtasks)
        std::vector<TaskData> allSourceTasks = getAllProjectTasksRecursive(sourceProjectId);
        qDebug() << "Found" << allSourceTasks.size() << "total tasks (including subtasks) to copy";

        if (allSourceTasks.empty()) {
            qDebug() << "No tasks found in source project - this is OK";
            return true;
        }

        // Separate top-level tasks from subtasks for processing
        std::vector<TaskData> topLevelTasks;
        std::map<int, std::vector<TaskData>> subtasksByParent;

        for (const auto& task : allSourceTasks) {
            if (task.idParentTache == 0) {
                topLevelTasks.push_back(task);
            }
            else {
                subtasksByParent[task.idParentTache].push_back(task);
            }
        }

        qDebug() << "Top-level tasks:" << topLevelTasks.size();
        qDebug() << "Subtasks grouped by" << subtasksByParent.size() << "different parents";

        std::map<int, int> taskIdMap;
        int copiedCount = 0;

        // Function to recursively copy a task and all its children
        std::function<bool(const TaskData&, int)> copyTaskRecursive;
        copyTaskRecursive = [&](const TaskData& sourceTask, int newParentId) -> bool {
            // Copy the task
            TaskData newTask = sourceTask;
            newTask.idProject = targetProjectId;
            newTask.idTache = 0;
            newTask.idParentTache = newParentId;
            newTask.etat = "A faire";

            qDebug() << "Copying task:" << QString::fromStdString(newTask.nomTache)
                << "Parent (old->new):" << sourceTask.idParentTache << "->" << newParentId;

            int newTaskId;
            if (newParentId > 0) {
                newTaskId = m_dbManager->createSubTask(newParentId, newTask);
            }
            else {
                newTaskId = m_dbManager->createTask(newTask);
            }

            if (newTaskId <= 0) {
                qWarning() << "✗ Failed to copy task:" << QString::fromStdString(newTask.nomTache);
                return false;
            }

            taskIdMap[sourceTask.idTache] = newTaskId;
            copiedCount++;
            qDebug() << "✓ Successfully copied task. New ID:" << newTaskId;

            // Recursively copy all children of this task
            auto childIt = subtasksByParent.find(sourceTask.idTache);
            if (childIt != subtasksByParent.end()) {
                for (const auto& childTask : childIt->second) {
                    if (!copyTaskRecursive(childTask, newTaskId)) {
                        qWarning() << "Failed to copy child task:" << QString::fromStdString(childTask.nomTache);
                    }
                }
            }

            return true;
        };

        // Copy all top-level tasks (which will recursively copy their children)
        for (const auto& topLevelTask : topLevelTasks) {
            copyTaskRecursive(topLevelTask, 0);
        }

        // Final report
        qDebug() << "=== COPYING COMPLETE ===";
        qDebug() << "Total source tasks:" << allSourceTasks.size();
        qDebug() << "Successfully copied:" << copiedCount;
        qDebug() << "Tasks not copied:" << (allSourceTasks.size() - copiedCount);

        return copiedCount > 0;

    }
    catch (const std::exception& e) {
        qCritical() << "Exception in copyProjectTasks:" << e.what();
        return false;
    }
}

std::vector<TaskData> ProjectController::getAllProjectTasksRecursive(int projectId) {
    std::vector<TaskData> allTasks;

    try {
        // Get top-level tasks
        std::vector<TaskData> topLevelTasks = m_dbManager->getTasksByProject(projectId);

        // Recursively get subtasks for each task
        std::function<void(const std::vector<TaskData>&)> collectTasks;
        collectTasks = [&](const std::vector<TaskData>& tasks) {
            for (const auto& task : tasks) {
                allTasks.push_back(task);

                // Get subtasks for this task
                std::vector<TaskData> childTasks = m_dbManager->getSubTasksByTask(task.idTache);
                if (!childTasks.empty()) {
                    collectTasks(childTasks);
                }
            }
        };

        collectTasks(topLevelTasks);

    }
    catch (const std::exception& e) {
        qCritical() << "Error getting all project tasks recursively:" << e.what();
    }

    return allTasks;
}

// Create project from template or existing project
/*
bool ProjectController::createProjectFromTemplate(const QString& projectName,
    int clientId,
    const QString& repository,
    double cost,
    const QString& projectDate)
{
    if (!m_currentUser) {
        qWarning() << "ProjectController: No current user set";
        emit projectCreationFailed("Aucun utilisateur connecte");
        return false;
    }

    if (!PermissionManager::canCreateProject(m_currentUser)) {
        emit projectCreationFailed("Vous n'avez pas la permission de créer des projets");
        return false;
    }

    if (projectName.isEmpty()) {
        emit projectCreationFailed("Le nom du projet est requis");
        return false;
    }

    qDebug() << "ProjectController: Creating project from template:" << projectName;

    try {
        // Create the project first
        ProjectData newProject;
        newProject.nomProject = projectName.toStdString();
        newProject.idClient = clientId;
        newProject.idDepartement = m_currentUser->getDepartementId();
        newProject.tempRepository = repository.toStdString();
        newProject.coutService = cost;

        // Use provided date or current date
        if (projectDate.isEmpty()) {
            newProject.dataProject = QDateTime::currentDateTime().toString("yyyy-MM-dd").toStdString();
        }
        else {
            newProject.dataProject = projectDate.toStdString();
        }

        int projectId = m_dbManager->createProject(newProject);

        if (projectId > 0) {
            qDebug() << "ProjectController: Project created successfully with ID:" << projectId;

            // Create the 4 predetermined tasks
            createTemplateTasks(projectId);

            emit projectCreated(projectId);
            loadProjectsByDepartment();
            return true;
        }
        else {
            emit projectCreationFailed("Echec de la creation du projet");
            return false;
        }
        return result;
    }
    catch (const std::exception& e) {
        qCritical() << "ProjectController: Error creating project from template:" << e.what();
        QString errorMsg = QString("Erreur: %1").arg(e.what());
        emit projectCreationFailed(errorMsg);
        return false;
    }
}
*/
void ProjectController::createTemplateTasks(int projectId)
{
    try {
        QString today = QDate::currentDate().toString("yyyy-MM-dd");
        QString twoWeeksLater = QDate::currentDate().addDays(14).toString("yyyy-MM-dd");

        // Task 1: Planification
        TaskData task1;
        task1.idProject = projectId;
        task1.nomTache = "Planification et analyse des besoins";
        task1.descTache = "Définir les objectifs, analyser les besoins et établir le plan de projet";
        task1.idEmploye = 0; // Unassigned initially
        task1.idParentTache = 0;
        task1.dateDebut = today.toStdString();
        task1.dateFin = QDate::currentDate().addDays(2).toString("yyyy-MM-dd").toStdString();
        task1.heuresEstimees = 8; // 8 hours
        task1.heuresUtilisees = 0;
        task1.etat = "A faire";

        int task1Id = m_dbManager->createTask(task1);
        qDebug() << "Created template task 1 with ID:" << task1Id;

        // Task 2: Conception
        TaskData task2;
        task2.idProject = projectId;
        task2.nomTache = "Conception et architecture";
        task2.descTache = "Concevoir l'architecture technique et les spécifications détaillées";
        task2.idEmploye = 0;
        task2.idParentTache = 0;
        task2.dateDebut = QDate::currentDate().addDays(3).toString("yyyy-MM-dd").toStdString();
        task2.dateFin = QDate::currentDate().addDays(5).toString("yyyy-MM-dd").toStdString();
        task2.heuresEstimees = 16;
        task2.heuresUtilisees = 0;
        task2.etat = "A faire";

        int task2Id = m_dbManager->createTask(task2);
        qDebug() << "Created template task 2 with ID:" << task2Id;

        // Task 3: Développement
        TaskData task3;
        task3.idProject = projectId;
        task3.nomTache = "Développement et implémentation";
        task3.descTache = "Développer les fonctionnalités principales et implémenter la solution";
        task3.idEmploye = 0;
        task3.idParentTache = 0;
        task3.dateDebut = QDate::currentDate().addDays(6).toString("yyyy-MM-dd").toStdString();
        task3.dateFin = QDate::currentDate().addDays(10).toString("yyyy-MM-dd").toStdString();
        task3.heuresEstimees = 40;
        task3.heuresUtilisees = 0;
        task3.etat = "A faire";

        int task3Id = m_dbManager->createTask(task3);
        qDebug() << "Created template task 3 with ID:" << task3Id;

        // Task 4: Tests et livraison
        TaskData task4;
        task4.idProject = projectId;
        task4.nomTache = "Tests et livraison finale";
        task4.descTache = "Effectuer les tests de validation et préparer la livraison";
        task4.idEmploye = 0;
        task4.idParentTache = 0;
        task4.dateDebut = QDate::currentDate().addDays(11).toString("yyyy-MM-dd").toStdString();
        task4.dateFin = twoWeeksLater.toStdString();
        task4.heuresEstimees = 16;
        task4.heuresUtilisees = 0;
        task4.etat = "A faire";

        int task4Id = m_dbManager->createTask(task4);
        qDebug() << "Created template task 4 with ID:" << task4Id;

        qDebug() << "All template tasks created successfully for project:" << projectId;

    }
    catch (const std::exception& e) {
        qCritical() << "Error creating template tasks:" << e.what();
        // Don't throw here - the project was created successfully
    }
}

// In ProjectController.cpp - Add this method
bool ProjectController::createProjectFromPredeterminedTemplate(const QString& projectName,
    int clientId,
    const QString& repository,
    double cost)
{
    if (!m_currentUser) {
        qWarning() << "ProjectController: No current user set";
        emit projectCreationFailed("Aucun utilisateur connecte");
        return false;
    }

    if (!PermissionManager::canCreateProject(m_currentUser)) {
        emit projectCreationFailed("Vous n'avez pas la permission de créer des projets");
        return false;
    }

    if (projectName.isEmpty()) {
        emit projectCreationFailed("Le nom du projet est requis");
        return false;
    }

    qDebug() << "ProjectController: Creating project from predetermined template:" << projectName;

    try {
        // Create the project first
        ProjectData newProject;
        newProject.nomProject = projectName.toStdString();
        newProject.idClient = clientId;
        newProject.idDepartement = m_currentUser->getDepartementId();
        newProject.tempRepository = repository.toStdString();
        newProject.coutService = cost;
        newProject.dataProject = QDateTime::currentDateTime().toString("yyyy-MM-dd").toStdString();

        int projectId = m_dbManager->createProject(newProject);

        if (projectId > 0) {
            qDebug() << "ProjectController: Project created successfully with ID:" << projectId;

            // Create the 4 predetermined tasks
            createPredeterminedTemplateTasks(projectId);

            emit projectCreated(projectId);
            loadProjectsByDepartment();
            return true;
        }
        else {
            emit projectCreationFailed("Echec de la creation du projet");
            return false;
        }
    }
    catch (const std::exception& e) {
        qCritical() << "ProjectController: Error creating project from predetermined template:" << e.what();
        QString errorMsg = QString("Erreur: %1").arg(e.what());
        emit projectCreationFailed(errorMsg);
        return false;
    }
}

// Add this private method to create the predetermined template tasks
void ProjectController::createPredeterminedTemplateTasks(int projectId)
{
    try {
        QString today = QDate::currentDate().toString("yyyy-MM-dd");
        QString twoWeeksLater = QDate::currentDate().addDays(14).toString("yyyy-MM-dd");

        // Task 1: Planification
        TaskData task1;
        task1.idProject = projectId;
        task1.nomTache = "Planification et analyse des besoins";
        task1.descTache = "D�finir les objectifs, analyser les besoins et �tablir le plan de projet";
        task1.idEmploye = 0; // Unassigned initially
        task1.idParentTache = 0;
        task1.dateDebut = today.toStdString();
        task1.dateFin = QDate::currentDate().addDays(2).toString("yyyy-MM-dd").toStdString();
        task1.heuresEstimees = 8; // 8 hours
        task1.heuresUtilisees = 0;
        task1.etat = "A faire";

        int task1Id = m_dbManager->createTask(task1);
        qDebug() << "Created template task 1 with ID:" << task1Id;

        // Task 2: Conception
        TaskData task2;
        task2.idProject = projectId;
        task2.nomTache = "Conception et architecture";
        task2.descTache = "Concevoir l'architecture technique et les sp�cifications d�taill�es";
        task2.idEmploye = 0;
        task2.idParentTache = 0;
        task2.dateDebut = QDate::currentDate().addDays(3).toString("yyyy-MM-dd").toStdString();
        task2.dateFin = QDate::currentDate().addDays(5).toString("yyyy-MM-dd").toStdString();
        task2.heuresEstimees = 16;
        task2.heuresUtilisees = 0;
        task2.etat = "A faire";

        int task2Id = m_dbManager->createTask(task2);
        qDebug() << "Created template task 2 with ID:" << task2Id;

        // Task 3: D�veloppement
        TaskData task3;
        task3.idProject = projectId;
        task3.nomTache = "D�veloppement et impl�mentation";
        task3.descTache = "D�velopper les fonctionnalit�s principales et impl�menter la solution";
        task3.idEmploye = 0;
        task3.idParentTache = 0;
        task3.dateDebut = QDate::currentDate().addDays(6).toString("yyyy-MM-dd").toStdString();
        task3.dateFin = QDate::currentDate().addDays(10).toString("yyyy-MM-dd").toStdString();
        task3.heuresEstimees = 40;
        task3.heuresUtilisees = 0;
        task3.etat = "A faire";

        int task3Id = m_dbManager->createTask(task3);
        qDebug() << "Created template task 3 with ID:" << task3Id;

        // Task 4: Tests et livraison
        TaskData task4;
        task4.idProject = projectId;
        task4.nomTache = "Tests et livraison finale";
        task4.descTache = "Effectuer les tests de validation et pr�parer la livraison";
        task4.idEmploye = 0;
        task4.idParentTache = 0;
        task4.dateDebut = QDate::currentDate().addDays(11).toString("yyyy-MM-dd").toStdString();
        task4.dateFin = twoWeeksLater.toStdString();
        task4.heuresEstimees = 16;
        task4.heuresUtilisees = 0;
        task4.etat = "A faire";

        int task4Id = m_dbManager->createTask(task4);
        qDebug() << "Created template task 4 with ID:" << task4Id;

        qDebug() << "All predetermined template tasks created successfully for project:" << projectId;

    }
    catch (const std::exception& e) {
        qCritical() << "Error creating predetermined template tasks:" << e.what();
        // Don't throw here - the project was created successfully
    }
}