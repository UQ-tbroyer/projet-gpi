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
        emit projectCreationFailed("Vous n'avez pas la permission de créer des projets");
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
        //defaultClient["nomClient"] = "Sélectionnez un client";
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
        // Get all tasks from source project
        std::vector<TaskData> sourceTasks = m_dbManager->getTasksByProject(sourceProjectId);
        qDebug() << "Found" << sourceTasks.size() << "tasks to copy";

        if (sourceTasks.empty()) {
            qDebug() << "No tasks found in source project - this is OK";
            return true;
        }

        // Debug: Log all source tasks
        for (const auto& task : sourceTasks) {
            qDebug() << "Source Task:" << QString::fromStdString(task.nomTache)
                << "ID:" << task.idTache
                << "Parent:" << task.idParentTache
                << "Assigned to:" << task.idEmploye
                << "Status:" << QString::fromStdString(task.etat);
        }

        std::map<int, int> taskIdMap;
        int copiedCount = 0;

        // Keep copying until all tasks are processed or we stop making progress
        bool progressMade;
        int maxIterations = 20; // Increased for deep hierarchies
        int iteration = 0;

        do {
            progressMade = false;
            iteration++;
            qDebug() << "--- Copy iteration" << iteration << "---";

            for (const auto& sourceTask : sourceTasks) {
                // Skip if already copied
                if (taskIdMap.count(sourceTask.idTache)) {
                    continue;
                }

                int newParentId = 0;

                // Determine parent ID
                if (sourceTask.idParentTache > 0) {
                    auto parentIt = taskIdMap.find(sourceTask.idParentTache);
                    if (parentIt == taskIdMap.end()) {
                        // Parent not copied yet, skip for now
                        continue;
                    }
                    newParentId = parentIt->second;
                }

                // Copy the task
                TaskData newTask = sourceTask;
                newTask.idProject = targetProjectId;
                newTask.idTache = 0; // Reset for new task
                newTask.idParentTache = newParentId;
                newTask.etat = "A faire"; // Reset status

                qDebug() << "Copying task:" << QString::fromStdString(newTask.nomTache)
                    << "Parent (old->new):" << sourceTask.idParentTache << "->" << newParentId
                    << "Assigned to:" << newTask.idEmploye;

                int newTaskId;
                if (newParentId > 0) {
                    newTaskId = m_dbManager->createSubTask(newParentId, newTask);
                }
                else {
                    newTaskId = m_dbManager->createTask(newTask);
                }

                if (newTaskId > 0) {
                    taskIdMap[sourceTask.idTache] = newTaskId;
                    copiedCount++;
                    progressMade = true;
                    qDebug() << "✓ Successfully copied task. New ID:" << newTaskId;
                }
                else {
                    qWarning() << "✗ Failed to copy task:" << QString::fromStdString(newTask.nomTache);
                    // Continue with other tasks
                }
            }

            qDebug() << "Iteration" << iteration << "complete. Total copied:" << copiedCount;

        } while (progressMade && iteration < maxIterations && copiedCount < sourceTasks.size());

        // Final report
        qDebug() << "=== COPYING COMPLETE ===";
        qDebug() << "Source tasks:" << sourceTasks.size();
        qDebug() << "Copied tasks:" << copiedCount;
        qDebug() << "Tasks not copied:" << (sourceTasks.size() - copiedCount);

        // Log any tasks that couldn't be copied
        for (const auto& task : sourceTasks) {
            if (!taskIdMap.count(task.idTache)) {
                qWarning() << "Failed to copy:" << QString::fromStdString(task.nomTache)
                    << "ID:" << task.idTache << "Parent:" << task.idParentTache;
            }
        }

        return copiedCount > 0; // Success if we copied at least one task

    }
    catch (const std::exception& e) {
        qCritical() << "Exception in copyProjectTasks:" << e.what();
        return false;
    }
}

// Create project from template or existing project
bool ProjectController::createProjectFromTemplate(const QString& projectName,
    int clientId,
    const QString& repository,
    double cost,
    const QString& projectDate,
    int sourceProjectId,
    bool copyTasks)
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
    qDebug() << "Source project ID:" << sourceProjectId;
    qDebug() << "Copy tasks:" << copyTasks;

    try {
        // Create the new project
        ProjectData newProject;
        newProject.nomProject = projectName.toStdString();
        newProject.idClient = clientId;
        newProject.idDepartement = m_currentUser->getDepartementId();
        newProject.tempRepository = repository.toStdString();
        newProject.coutService = cost;

        if (projectDate.isEmpty()) {
            newProject.dataProject = QDateTime::currentDateTime().toString("yyyy-MM-dd").toStdString();
        }
        else {
            newProject.dataProject = projectDate.toStdString();
        }

        // If sourceProjectId is provided, copy additional info from source project
        if (sourceProjectId > 0) {
            try {
                ProjectData sourceProject = m_dbManager->getProjectById(sourceProjectId);

                // Copy repository if not provided
                if (repository.isEmpty()) {
                    newProject.tempRepository = sourceProject.tempRepository;
                }

                // Copy cost if not provided (or is 0)
                if (cost <= 0.0) {
                    newProject.coutService = sourceProject.coutService;
                }
            }
            catch (const std::exception& e) {
                qWarning() << "Could not load source project details:" << e.what();
                // Continue anyway - not critical
            }
        }

        int projectId = m_dbManager->createProject(newProject);

        if (projectId > 0) {
            qDebug() << "ProjectController: Project created successfully with ID:" << projectId;

            // Copy tasks if requested and source project exists
            if (copyTasks && sourceProjectId > 0) {
                qDebug() << "=== Starting task copy process ===";
                bool tasksCopied = copyProjectTasks(sourceProjectId, projectId);

                if (tasksCopied) {
                    qDebug() << "✓ Tasks copied successfully";
                }
                else {
                    qWarning() << "✗ Failed to copy some or all tasks, but project was created";
                    emit errorOccurred("Projet créé mais certaines tâches n'ont pas pu être copiées");
                    // Don't return false here - the project was created successfully
                }
            }
            else {
                qDebug() << "Skipping task copy - copyTasks:" << copyTasks << "sourceProjectId:" << sourceProjectId;
            }

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
        qCritical() << "ProjectController: Error creating project from template:" << e.what();
        QString errorMsg = QString("Erreur: %1").arg(e.what());
        emit projectCreationFailed(errorMsg);
        return false;
    }
}