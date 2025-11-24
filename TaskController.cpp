#include "TaskController.h"
#include "PermissionManager.h"
#include <QDebug>
#include <QDateTime>
#include <QTimer>
#include <QThread>
#include <QtConcurrent/QtConcurrent>
#include <iostream>


TaskController::TaskController(DatabaseManager* dbManager, User* currentUser, QObject* parent)
    : QObject(parent)
    , m_dbManager(dbManager)
    , m_currentUser(currentUser)
    , m_currentProjectId(0)
    , m_loading(false)
{
    if (!m_dbManager) {
        qCritical() << "TaskController: DatabaseManager is null!";
    }

    m_refreshTimer = new QTimer(this);
    m_refreshTimer->setSingleShot(true);
    m_refreshTimer->setInterval(200); // 200ms throttle
    connect(m_refreshTimer, &QTimer::timeout, this, &TaskController::onRefreshTimerTimeout);
}

TaskController::~TaskController() {}

void TaskController::loadTasksForProjectThrottled(int projectId) {
    m_pendingRefreshProjectId = projectId;
    if (!m_refreshTimer->isActive()) {
        m_refreshTimer->start();
    }
}

void TaskController::setCurrentUser(User* user)
{
    m_currentUser = user;
}

void TaskController::setCurrentProjectId(int projectId)
{
    if (m_currentProjectId != projectId) {
        m_currentProjectId = projectId;
        emit currentProjectIdChanged();
        if (projectId > 0) {
            loadTasksForProject(projectId);
        }
    }
}

void TaskController::setLoading(bool loading)
{
    if (m_loading != loading) {
        m_loading = loading;
        emit loadingChanged();
    }
}

QString TaskController::formatTimeForDisplay(int timeMinutes) const
{
    int hours = timeMinutes / 60;
    int minutes = timeMinutes % 60;
    return QString("%1:%2:00").arg(hours, 2, 10, QChar('0')).arg(minutes, 2, 10, QChar('0'));
}

QVariantMap TaskController::taskDataToVariantMap(const TaskData& task) const
{
    QVariantMap map;
    map["idTache"] = task.idTache;
    map["idProject"] = task.idProject;
    map["memProcessigner"] = task.idEmploye;
    map["idParentTache"] = task.idParentTache;

    // sous-tâche
    map["isSubTask"] = (task.idParentTache > 0);

    // strings
    map["nomTache"] = QString::fromStdString(task.nomTache);
    map["descTache"] = QString::fromStdString(task.descTache);
    map["dateDebut"] = QString::fromStdString(task.dateDebut);
    map["dateFin"] = QString::fromStdString(task.dateFin);
    map["etat"] = QString::fromStdString(task.etat);
    map["assigneeName"] = QString::fromStdString(task.assigneeName);  // ADD THIS LINE

    // temps
    map["tempsTache"] = task.heuresEstimees;

    return map;
}

void TaskController::loadTasksForProject(int projectId)
{
    qDebug() << "TaskController: Loading tasks for project" << projectId;

    try {
        std::vector<TaskData> tasksData = m_dbManager->getTasksByProject(projectId);
        qDebug() << "TaskController: to variant";
        m_tasks.clear();
        for (const auto& task : tasksData) {
            m_tasks.append(taskDataToVariantMap(task));
        }

        // Emit signal AFTER the data is loaded
        emit tasksChanged();
        qDebug() << "TaskController: Loaded" << m_tasks.size() << "tasks for project" << projectId;
    }
    catch (const std::exception& e) {
        QString errorMsg = "Erreur lors du chargement des taches: ";
        errorMsg += QString::fromUtf8(e.what());
        emit errorOccurred(errorMsg);
    }
}

void TaskController::loadTasksForCurrentProject()
{
    if (m_currentProjectId > 0){
        loadTasksForProject(m_currentProjectId);
    }
    else {
        emit errorOccurred("Aucun projet selectionne");
    }
}

// --- Création d'une tâche ---
bool TaskController::createTask(int projectId,
    const QString& taskName,
    const QString& description,
    int idParentTache,
    int assignedToId,
    const int estimatedTime,
    const QString& dateDebut,
    const QString& dateFin,
    const QString& etat)
{
    if (!canCreateTask(projectId)) {
        emit taskCreationFailed("Vous n'avez pas la permission de créer des tâches");
        return false;
    }

    if (!m_currentUser) {
        emit taskCreationFailed("Aucun utilisateur connecte");
        return false;
    }
    if (taskName.isEmpty()) {
        emit taskCreationFailed("Le nom de la tâche est requis");
        return false;
    }
    if (projectId <= 0) {
        emit taskCreationFailed("Projet invalide");
        return false;
    }

    try {
        TaskData newTask;

        newTask.idProject = projectId;
        newTask.nomTache = taskName.toStdString();
        newTask.descTache = description.toStdString();
        newTask.idEmploye = assignedToId;
        newTask.idParentTache = idParentTache;

        QString today = QDate::currentDate().toString("yyyy-MM-dd");
        newTask.dateDebut = dateDebut.isEmpty() ? today.toStdString() : dateDebut.toStdString();
        newTask.dateFin = dateFin.toStdString();

        newTask.heuresEstimees = estimatedTime;
        newTask.etat = etat.toStdString();
        newTask.assigneeName = "";  // ADD THIS LINE - will be populated by database query

        int taskId = m_dbManager->createTask(newTask);
        if (taskId > 0) {
            emit taskCreated(taskId);
            loadTasksForProject(projectId);
            return true;
        }
        emit taskCreationFailed("Échec de la création de la tâche");
        return false;
    }
    catch (const std::exception& e) {
        emit taskCreationFailed(QString("Erreur: ") + e.what());
        return false;
    }
}

// --- Mise à jour d'une tâche ---
bool TaskController::updateTask(int taskId,
    const QString& taskName,
    const QString& description,
    int assignedToId,
    const QString& estimatedTime,
    const QString& dateDebut,
    const QString& dateFin,
    const QString& etat)
{
    if (PermissionManager::isEmploye(m_currentUser)) {
        if (!canChangeStatus(taskId)) {
            emit taskUpdateFailed("Vous ne pouvez modifier que vos propres tâches");
            return false;
        }
        // Employee can only change status, load existing task and update only status
        try {
            TaskData existingTask = m_dbManager->getTaskById(taskId);
            existingTask.etat = etat.toStdString();

            bool success = m_dbManager->updateTask(existingTask);
            if (success) {
                emit taskUpdated(taskId);
                return true;
            }
        }
        catch (const std::exception& e) {
            emit taskUpdateFailed(QString("Erreur: ") + e.what());
            return false;
        }
    }

    // For admins and gestionnaires, allow full edit
    if (!canEditTask(taskId)) {
        emit taskUpdateFailed("Vous n'avez pas la permission de modifier cette tâche");
        return false;
    }

    if (taskName.isEmpty()) {
        emit taskUpdateFailed("Le nom de la tâche est requis");
        return false;
    }

    try {
        TaskData updatedTask;
        updatedTask.idTache = taskId;
        updatedTask.nomTache = taskName.toStdString();
        updatedTask.descTache = description.toStdString();
        updatedTask.idEmploye = assignedToId;
        updatedTask.heuresEstimees = estimatedTime.isEmpty() ? 0 : estimatedTime.toInt();
        updatedTask.dateDebut = dateDebut.toStdString();
        updatedTask.dateFin = dateFin.toStdString();
        updatedTask.etat = etat.toStdString();
        updatedTask.assigneeName = "";

        bool success = m_dbManager->updateTask(updatedTask);

        if (success) {
            qDebug() << "TaskController: Task updated successfully, taskId:" << taskId;

            // Emit signals to notify other windows
            emit taskUpdated(taskId);

            // Check if this is a subtask and notify parent
            try {
                TaskData taskDetails = m_dbManager->getTaskById(taskId);
                if (taskDetails.idParentTache > 0) {
                    emit subTasksChanged(taskDetails.idParentTache);
                }
            }
            catch (const std::exception& e) {
                qWarning() << "Error checking task hierarchy:" << e.what();
            }

            return true;
        }
        else {
            emit taskUpdateFailed("Échec de la mise à jour de la tâche");
            return false;
        }
    }
    catch (const std::exception& e) {
        emit taskUpdateFailed(QString("Erreur: ") + e.what());
        return false;
    }
}

bool TaskController::updateTaskStatus(int taskId, const QString& etat)
{
    qDebug() << "TaskController: Updating task status, taskId:" << taskId << "new status:" << etat;

    if (!m_currentUser) {
        emit taskUpdateFailed("Aucun utilisateur connecté");
        return false;
    }

    // Check permissions first
    if (PermissionManager::isEmploye(m_currentUser)) {
        if (!canChangeStatus(taskId)) {
            emit taskUpdateFailed("Vous ne pouvez modifier que vos propres tâches");
            return false;
        }
    }
    else if (!canEditTask(taskId)) {
        emit taskUpdateFailed("Vous n'avez pas la permission de modifier cette tâche");
        return false;
    }

    try {
        // Get existing task data
        TaskData existingTask = m_dbManager->getTaskById(taskId);
        qDebug() << "Current task status:" << QString::fromStdString(existingTask.etat);

        // Update only the status
        existingTask.etat = etat.toStdString();

        qDebug() << "Attempting to update task in database...";
        bool success = m_dbManager->updateTask(existingTask);

        if (success) {
            qDebug() << "Task status updated successfully in database";

            // Emit signals for UI refresh
            emit taskUpdated(taskId);

            // Check if this is a subtask and notify parent
            if (existingTask.idParentTache > 0) {
                emit subTasksChanged(existingTask.idParentTache);
                qDebug() << "Emitted subTasksChanged for parent:" << existingTask.idParentTache;
            }

            // Refresh current project tasks
            if (m_currentProjectId > 0) {
                QTimer::singleShot(100, [this]() {
                    loadTasksForProject(m_currentProjectId);
                    });
            }

            return true;
        }
        else {
            qWarning() << "Database update returned false";
            emit taskUpdateFailed("Échec de la mise à jour du statut dans la base de données");
            return false;
        }
    }
    catch (const std::exception& e) {
        qCritical() << "Exception in updateTaskStatus:" << e.what();
        emit taskUpdateFailed(QString("Erreur: ") + e.what());
        return false;
    }
}


// --- Suppression ---
bool TaskController::deleteTask(int taskId)
{
    if (!canDeleteTask(taskId)) {
        emit taskDeletionFailed("Vous n'avez pas la permission de supprimer cette tâche");
        return false;
    }

    try {
        bool success = m_dbManager->deleteTask(taskId);
        if (success) {
            emit taskDeleted(taskId);
            if (m_currentProjectId > 0)
                loadTasksForProject(m_currentProjectId);
            return true;
        }
        else {
            emit taskDeletionFailed("Échec de la suppression de la tâche");
            return false;
        }
    }
    catch (const std::exception& e) {
        QString errorMsg = "Erreur: ";
        errorMsg += QString::fromUtf8(e.what());
        emit taskDeletionFailed(errorMsg);
        return false;
    }
}

// --- Assignation ---
bool TaskController::assignTask(int taskId, int employeeId)
{
    try {
        bool success = m_dbManager->assignTaskToEmployee(taskId, employeeId);
        if (success) {
            emit taskAssigned(taskId, employeeId);
            if (m_currentProjectId > 0)
                loadTasksForProject(m_currentProjectId);
            return true;
        }
        else {
            emit taskAssignmentFailed("Échec de l'affectation de la tâche");
            return false;
        }
    }
    catch (const std::exception& e) {
        QString errorMsg = "Erreur: ";
        errorMsg += QString::fromUtf8(e.what());
        emit taskAssignmentFailed(errorMsg);
        return false;
    }
}

// --- Récupération détails ---
QVariantMap TaskController::getTaskDetails(int taskId)
{
    qDebug() << "TaskController::getTaskDetails called for taskId:" << taskId;

    try {
        TaskData task = m_dbManager->getTaskById(taskId);

        qDebug() << "Task retrieved from database:";
        qDebug() << "  idTache:" << task.idTache;
        qDebug() << "  nomTache:" << QString::fromStdString(task.nomTache);
        qDebug() << "  descTache:" << QString::fromStdString(task.descTache);
        qDebug() << "  etat:" << QString::fromStdString(task.etat);
        qDebug() << "  memProcessigner:" << task.idEmploye;
        qDebug() << "  tempsTache:" << task.heuresEstimees;
        qDebug() << "  dateDebut:" << QString::fromStdString(task.dateDebut);
        qDebug() << "  dateFin:" << QString::fromStdString(task.dateFin);
        qDebug() << "  assigneeName:" << QString::fromStdString(task.assigneeName);

        QVariantMap taskMap = taskDataToVariantMap(task);

        qDebug() << "Converted to QVariantMap:";
        qDebug() << "  Keys:" << taskMap.keys();
        for (auto key : taskMap.keys()) {
            qDebug() << "    " << key << ":" << taskMap[key];
        }

        return taskMap;
    }
    catch (const std::exception& e) {
        QString errorMsg = "Erreur lors du chargement de la tâche: ";
        errorMsg += QString::fromUtf8(e.what());
        qCritical() << errorMsg;
        emit errorOccurred(errorMsg);
        return QVariantMap();
    }
}

QVariantList TaskController::getSubTasks(int taskId)
{
    qDebug() << "=== TaskController::getSubTasks called for taskId:" << taskId << "===";
    QVariantList subTaskList;
    try {
        std::vector<TaskData> subTasksData = m_dbManager->getSubTasksByTask(taskId);
        qDebug() << "Retrieved" << subTasksData.size() << "subtasks from database";

        for (const auto& subTask : subTasksData) {
            QVariantMap taskMap = taskDataToVariantMap(subTask);
            qDebug() << "  SubTask:" << taskMap["nomTache"].toString()
                << "| etat:" << taskMap["etat"].toString()
                << "| dateDebut:" << taskMap["dateDebut"].toString();
            subTaskList.append(taskMap);
        }

        qDebug() << "Returning" << subTaskList.size() << "subtasks to QML";
    }
    catch (const std::exception& e) {
        QString errorMsg = "Erreur lors du chargement des sous-tâches: ";
        errorMsg += QString::fromUtf8(e.what());
        qCritical() << errorMsg;
        emit errorOccurred(errorMsg);
    }
    return subTaskList;
}



bool TaskController::deleteSubTask(int taskId)
{
    try {
        bool success = m_dbManager->deleteSubTask(taskId);
        if (success) {
            emit taskDeleted(taskId);
            if (m_currentProjectId > 0)
                loadTasksForProject(m_currentProjectId);
            return true;
        }
        else {
            emit taskDeletionFailed("Échec de la suppression de la sous-tâche");
            return false;
        }
    }
    catch (const std::exception& e) {
        QString errorMsg = "Erreur: ";
        errorMsg += QString::fromUtf8(e.what());
        emit taskDeletionFailed(errorMsg);
        return false;
    }
}

QVariantMap TaskController::getTaskHierarchy(int taskId)
{
    try {
        TaskData task = m_dbManager->getTaskById(taskId);
        QVariantMap taskMap = taskDataToVariantMap(task);
        QVariantList subTasks;
        std::vector<TaskData> subTasksData = m_dbManager->getSubTasksByTask(taskId);
        for (const auto& subTask : subTasksData)
            subTasks.append(getTaskHierarchy(subTask.idTache));
        taskMap["subTasks"] = subTasks;
        return taskMap;
    }
    catch (const std::exception& e) {
        QString errorMsg = "Erreur lors du chargement de la hiérarchie: ";
        errorMsg += QString::fromUtf8(e.what());
        emit errorOccurred(errorMsg);
        return QVariantMap();
    }
}

QVariantList TaskController::getAvailableEmployees()
{
    QVariantList employeeList;
    try {
        std::vector<std::tuple<int, std::string, std::string>> employees = m_dbManager->getAllEmployees();
        for (const auto& e : employees) {
            QVariantMap emp;
            emp["idEmploye"] = std::get<0>(e);
            emp["nom"] = QString::fromStdString(std::get<1>(e));
            emp["prenom"] = QString::fromStdString(std::get<2>(e));
            emp["fullName"] = QString::fromStdString(std::get<2>(e) + " " + std::get<1>(e));
            employeeList.append(emp);
        }
    }
    catch (const std::exception& e) {
        QString errorMsg = "Erreur lors du chargement des employés: ";
        errorMsg += QString::fromUtf8(e.what());
        emit errorOccurred(errorMsg);
    }
    return employeeList;
}

QVariantList TaskController::getDepartmentEmployees()
{
    if (!m_currentUser) return QVariantList();
    QVariantList employeeList;
    try {
        std::vector<std::tuple<int, std::string, std::string>> employees =
            m_dbManager->getEmployeesByDepartment(m_currentUser->getDepartementId());
        for (const auto& e : employees) {
            QVariantMap emp;
            emp["idEmploye"] = std::get<0>(e);
            emp["nom"] = QString::fromStdString(std::get<1>(e));
            emp["prenom"] = QString::fromStdString(std::get<2>(e));
            emp["fullName"] = QString::fromStdString(std::get<2>(e) + " " + std::get<1>(e));
            employeeList.append(emp);
        }
    }
    catch (const std::exception& e) {
        QString errorMsg = "Erreur lors du chargement des employés du département: ";
        errorMsg += QString::fromUtf8(e.what());
        emit errorOccurred(errorMsg);
    }
    return employeeList;
}

QVariantList TaskController::getTasksForProject(int projectId) {
    loadTasksForProject(projectId); 
    return m_tasks;
}

QVariantList TaskController::getTasksForProjectByStatus(int projectId, const QString& status)
{
    QVariantList filteredTasks;

    // On récupère toutes les tâches du projet
    QVariantList allTasks = getTasksForProject(projectId);

    for (const QVariant& taskVar : allTasks) {
        QVariantMap taskMap = taskVar.toMap();
        if (taskMap.contains("etat") && taskMap["etat"].toString() == status) {
            filteredTasks.append(taskVar);
        }
    }

    return filteredTasks;
}
// Add/Update these methods in your TaskController.cpp file

// Get subtasks filtered by status
QVariantList TaskController::getSubTasksByStatus(int parentTaskId, const QString& status)
{
    QVariantList filteredSubTasks;

    try {
        std::vector<TaskData> allSubTasks = m_dbManager->getSubTasksByTask(parentTaskId);

        for (const auto& subTask : allSubTasks) {
            if (QString::fromStdString(subTask.etat) == status) {
                filteredSubTasks.append(taskDataToVariantMap(subTask));
            }
        }
    }
    catch (const std::exception& e) {
        QString errorMsg = "Erreur lors du chargement des sous-tâches: ";
        errorMsg += QString::fromUtf8(e.what());
        emit errorOccurred(errorMsg);
    }

    return filteredSubTasks;
}

// Updated createSubTask with same parameters as createTask
bool TaskController::createSubTask(int parentTaskId,
    const QString& subTaskName,
    const QString& description,
    int assignedToId,
    const int estimatedTime,
    const QString& dateDebut,
    const QString& dateFin,
    const QString& etat)
{
    if (!m_currentUser) {
        emit taskCreationFailed("Aucun utilisateur connecte");
        return false;
    }
    if (subTaskName.isEmpty()) {
        emit taskCreationFailed("Le nom de la sous-tâche est requis");
        return false;
    }
    if (parentTaskId <= 0) {
        emit taskCreationFailed("Tâche parent invalide");
        return false;
    }

    try {
        TaskData newSubTask;
        newSubTask.nomTache = subTaskName.toStdString();
        newSubTask.descTache = description.toStdString();
        newSubTask.idEmploye = assignedToId;

        QString today = QDate::currentDate().toString("yyyy-MM-dd");
        newSubTask.dateDebut = dateDebut.isEmpty() ? today.toStdString() : dateDebut.toStdString();
        newSubTask.dateFin = dateFin.isEmpty() ? today.toStdString() : dateFin.toStdString();

        newSubTask.heuresEstimees = estimatedTime;
        newSubTask.etat = etat.isEmpty() ? "A faire" : etat.toStdString();
        newSubTask.assigneeName = "";  // ADD THIS LINE

        int subTaskId = m_dbManager->createSubTask(parentTaskId, newSubTask);
        if (subTaskId > 0) {
            emit taskCreated(subTaskId);
            // Emit a specific signal for subtask refresh
            emit subTasksChanged(parentTaskId);
            if (m_currentProjectId > 0)
                loadTasksForProject(m_currentProjectId);
            return true;
        }
        emit taskCreationFailed("Échec de la création de la sous-tâche");
        return false;
    }
    catch (const std::exception& e) {
        emit taskCreationFailed(QString("Erreur: ") + e.what());
        return false;
    }
}

bool TaskController::canCreateTask(int projectId) const {
    std::cout << "=== DEBUG canCreateTask ===" << std::endl;
    std::cout << "projectId: " << projectId << std::endl;

    if (!m_currentUser) {
        std::cout << "ERROR: No current user!" << std::endl;
        return false;
    }

    std::cout << "Current user ID: " << m_currentUser->getId() << std::endl;
    std::cout << "Current user role: " << static_cast<int>(m_currentUser->getRole()) << std::endl;
    std::cout << "Current user department: " << m_currentUser->getDepartementId() << std::endl;

    try {
        ProjectData project = m_dbManager->getProjectById(projectId);
        std::cout << "Project found - idProject: " << project.idProject << std::endl;
        std::cout << "Project department: " << project.idDepartement << std::endl;

        bool canCreate = PermissionManager::canCreateTask(m_currentUser, project.idDepartement);
        std::cout << "Permission result: " << (canCreate ? "TRUE" : "FALSE") << std::endl;

        return canCreate;
    }
    catch (const std::exception& e) {
        std::cerr << "ERROR in canCreateTask: " << e.what() << std::endl;
        return false;
    }
}
bool TaskController::canEditTask(int taskId) const {
    if (!m_currentUser) {
        qDebug() << "canEditTask: No current user";
        return false;
    }

    try {
        TaskData task = m_dbManager->getTaskById(taskId);
        ProjectData project = m_dbManager->getProjectById(task.idProject);

        qDebug() << "=== DEBUG canEditTask ===";
        qDebug() << "Current user ID:" << m_currentUser->getId();
        qDebug() << "Current user role:" << static_cast<int>(m_currentUser->getRole());
        qDebug() << "Task assigned to:" << task.idEmploye;
        qDebug() << "Project department:" << project.idDepartement;
        qDebug() << "User department:" << m_currentUser->getDepartementId();

        bool canEdit = PermissionManager::canEditTask(m_currentUser, task.idEmploye, project.idDepartement);
        qDebug() << "Permission result:" << canEdit;

        return canEdit;
    }
    catch (const std::exception& e) {
        qWarning() << "Error checking edit permission:" << e.what();
        return false;
    }
}


bool TaskController::canDeleteTask(int taskId) const {
    if (!m_currentUser) return false;

    try {
        TaskData task = m_dbManager->getTaskById(taskId);
        ProjectData project = m_dbManager->getProjectById(task.idProject);
        return PermissionManager::canDeleteTask(m_currentUser, project.idDepartement);
    }
    catch (const std::exception& e) {
        qWarning() << "Error checking delete permission:" << e.what();
        return false;
    }
}

bool TaskController::canAssignTask(int projectId) const {
    if (!m_currentUser) return false;

    try {
        ProjectData project = m_dbManager->getProjectById(projectId);
        return PermissionManager::canAssignTask(m_currentUser, project.idDepartement);
    }
    catch (const std::exception& e) {
        qWarning() << "Error checking assign permission:" << e.what();
        return false;
    }
}

bool TaskController::canChangeStatus(int taskId) const {
    if (!m_currentUser) {
        qDebug() << "canChangeStatus: No current user";
        return false;
    }

    try {
        TaskData task = m_dbManager->getTaskById(taskId);

        qDebug() << "=== DEBUG canChangeStatus ===";
        qDebug() << "Current user ID:" << m_currentUser->getId();
        qDebug() << "Task assigned to:" << task.idEmploye;

        bool canChange = PermissionManager::canChangeTaskStatus(m_currentUser, task.idEmploye);
        qDebug() << "Permission result:" << canChange;

        return canChange;
    }
    catch (const std::exception& e) {
        qWarning() << "Error checking status change permission:" << e.what();
        return false;
    }
}

bool TaskController::isEmployeeView() const {
    return PermissionManager::isEmploye(m_currentUser);
}

