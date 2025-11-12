#include "TaskController.h"
#include "DatabaseManager.h"
#include "User.h"
#include <QDebug>
#include <QDateTime>

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
}

TaskController::~TaskController()
{
    // Don't delete m_dbManager or m_currentUser - they're owned by main.cpp
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

        // Auto-load tasks when project changes
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

QString TaskController::formatTimeForDisplay(const std::string& timeStr) const
{
    if (timeStr.empty()) {
        return "00:00:00";
    }
    return QString::fromStdString(timeStr);
}

QVariantMap TaskController::taskDataToVariantMap(const TaskData& task) const
{
    QVariantMap map;
    map["idTache"] = task.idTache;
    map["idProject"] = task.idProject;
    map["memProcessigner"] = task.memProcessigner;
    map["idParentTache"] = task.idParentTache;
    map["isSubTask"] = (task.idParentTache > 0);
    map["nomTache"] = QString::fromStdString(task.nomTache);
    map["descTache"] = QString::fromStdString(task.descTache);
    map["dataTache"] = QString::fromStdString(task.dataTache);
    map["tempsTache"] = formatTimeForDisplay(task.tempsTache);
    map["assigneeName"] = QString::fromStdString(task.assigneeName);
    return map;
}

void TaskController::loadTasksForProject(int projectId)
{
    qDebug() << "TaskController: Loading tasks for project" << projectId;
    setLoading(true);

    try {
        std::vector<TaskData> tasksData = m_dbManager->getTasksByProject(projectId);

        m_tasks.clear();
        for (const auto& task : tasksData) {
            m_tasks.append(taskDataToVariantMap(task));
        }

        emit tasksChanged();
        qDebug() << "TaskController: Loaded" << m_tasks.size() << "tasks";
    }
    catch (const std::exception& e) {
        qCritical() << "TaskController: Error loading tasks:" << e.what();
        QString errorMsg = "Erreur lors du chargement des taches: ";
        errorMsg += QString::fromUtf8(e.what());
        emit errorOccurred(errorMsg);
    }

    setLoading(false);
}

void TaskController::loadTasksForCurrentProject()
{
    if (m_currentProjectId > 0) {
        loadTasksForProject(m_currentProjectId);
    }
    else {
        qWarning() << "TaskController: No current project set";
        emit errorOccurred("Aucun projet selectionne");
    }
}

bool TaskController::createTask(int projectId,
    const QString& taskName,
    const QString& description,
    int assignedToId,
    const QString& estimatedTime,
    const QString& taskDate)
{
    if (!m_currentUser) {
        qWarning() << "TaskController: No current user set";
        emit taskCreationFailed("Aucun utilisateur connecte");
        return false;
    }

    if (taskName.isEmpty()) {
        emit taskCreationFailed("Le nom de la tache est requis");
        return false;
    }

    if (projectId <= 0) {
        emit taskCreationFailed("Projet invalide");
        return false;
    }

    qDebug() << "TaskController: Creating task:" << taskName << "for project" << projectId;

    try {
        TaskData newTask;
        newTask.idProject = projectId;
        newTask.nomTache = taskName.toStdString();
        newTask.descTache = description.toStdString();
        newTask.memProcessigner = assignedToId;
        newTask.idParentTache = 0;

        // Set date
        if (taskDate.isEmpty()) {
            newTask.dataTache = QDateTime::currentDateTime().toString("yyyy-MM-dd").toStdString();
        }
        else {
            newTask.dataTache = taskDate.toStdString();
        }

        // Set estimated time (default to 00:00:00 if empty)
        if (estimatedTime.isEmpty()) {
            newTask.tempsTache = "00:00:00";
        }
        else {
            newTask.tempsTache = estimatedTime.toStdString();
        }

        int taskId = m_dbManager->createTask(newTask);

        if (taskId > 0) {
            qDebug() << "TaskController: Task created successfully with ID:" << taskId;
            emit taskCreated(taskId);

            // Reload tasks for this project
            loadTasksForProject(projectId);
            return true;
        }
        else {
            emit taskCreationFailed("Echec de la creation de la tache");
            return false;
        }
    }
    catch (const std::exception& e) {
        qCritical() << "TaskController: Error creating task:" << e.what();
        QString errorMsg = "Erreur: ";
        errorMsg += QString::fromUtf8(e.what());
        emit taskCreationFailed(errorMsg);
        return false;
    }
}

bool TaskController::updateTask(int taskId,
    const QString& taskName,
    const QString& description,
    int assignedToId,
    const QString& estimatedTime)
{
    if (taskName.isEmpty()) {
        emit taskUpdateFailed("Le nom de la tache est requis");
        return false;
    }

    qDebug() << "TaskController: Updating task:" << taskId;

    try {
        TaskData updatedTask;
        updatedTask.idTache = taskId;
        updatedTask.nomTache = taskName.toStdString();
        updatedTask.descTache = description.toStdString();
        updatedTask.memProcessigner = assignedToId;
        updatedTask.tempsTache = estimatedTime.toStdString();

        bool success = m_dbManager->updateTask(updatedTask);

        if (success) {
            qDebug() << "TaskController: Task updated successfully";
            emit taskUpdated(taskId);

            // Reload tasks for current project
            if (m_currentProjectId > 0) {
                loadTasksForProject(m_currentProjectId);
            }
            return true;
        }
        else {
            emit taskUpdateFailed("Echec de la mise a jour de la tache");
            return false;
        }
    }
    catch (const std::exception& e) {
        qCritical() << "TaskController: Error updating task:" << e.what();
        QString errorMsg = "Erreur: ";
        errorMsg += QString::fromUtf8(e.what());
        emit taskUpdateFailed(errorMsg);
        return false;
    }
}

bool TaskController::deleteTask(int taskId)
{
    qDebug() << "TaskController: Deleting task:" << taskId;

    try {
        bool success = m_dbManager->deleteTask(taskId);

        if (success) {
            qDebug() << "TaskController: Task deleted successfully";
            emit taskDeleted(taskId);

            // Reload tasks for current project
            if (m_currentProjectId > 0) {
                loadTasksForProject(m_currentProjectId);
            }
            return true;
        }
        else {
            emit taskDeletionFailed("Echec de la suppression de la tache");
            return false;
        }
    }
    catch (const std::exception& e) {
        qCritical() << "TaskController: Error deleting task:" << e.what();
        QString errorMsg = "Erreur: ";
        errorMsg += QString::fromUtf8(e.what());
        emit taskDeletionFailed(errorMsg);
        return false;
    }
}

bool TaskController::assignTask(int taskId, int employeeId)
{
    qDebug() << "TaskController: Assigning task" << taskId << "to employee" << employeeId;

    try {
        bool success = m_dbManager->assignTaskToEmployee(taskId, employeeId);

        if (success) {
            qDebug() << "TaskController: Task assigned successfully";
            emit taskAssigned(taskId, employeeId);

            // Reload tasks for current project
            if (m_currentProjectId > 0) {
                loadTasksForProject(m_currentProjectId);
            }
            return true;
        }
        else {
            emit taskAssignmentFailed("Echec de l'affectation de la tache");
            return false;
        }
    }
    catch (const std::exception& e) {
        qCritical() << "TaskController: Error assigning task:" << e.what();
        QString errorMsg = "Erreur: ";
        errorMsg += QString::fromUtf8(e.what());
        emit taskAssignmentFailed(errorMsg);
        return false;
    }
}

QVariantMap TaskController::getTaskDetails(int taskId)
{
    qDebug() << "TaskController: Getting task details for ID:" << taskId;

    try {
        TaskData task = m_dbManager->getTaskById(taskId);
        return taskDataToVariantMap(task);
    }
    catch (const std::exception& e) {
        qCritical() << "TaskController: Error getting task details:" << e.what();
        QString errorMsg = "Erreur lors du chargement de la tache: ";
        errorMsg += QString::fromUtf8(e.what());
        emit errorOccurred(errorMsg);
        return QVariantMap();
    }
}

QVariantList TaskController::getSubTasks(int taskId)
{
    qDebug() << "TaskController: Loading subtasks for task" << taskId;
    QVariantList subTaskList;

    try {
        std::vector<TaskData> subTasksData = m_dbManager->getSubTasksByTask(taskId);

        for (const auto& subTask : subTasksData) {
            subTaskList.append(taskDataToVariantMap(subTask));
        }

        qDebug() << "TaskController: Loaded" << subTaskList.size() << "subtasks";
    }
    catch (const std::exception& e) {
        qCritical() << "TaskController: Error loading subtasks:" << e.what();
        QString errorMsg = "Erreur lors du chargement des sous-taches: ";
        errorMsg += QString::fromUtf8(e.what());
        emit errorOccurred(errorMsg);
    }

    return subTaskList;
}

bool TaskController::createSubTask(int parentTaskId,
    const QString& subTaskName,
    const QString& description,
    int assignedToId,
    const QString& estimatedTime,
    const QString& subTaskDate)
{
    if (!m_currentUser) {
        qWarning() << "TaskController: No current user set";
        emit taskCreationFailed("Aucun utilisateur connecte");
        return false;
    }

    if (subTaskName.isEmpty()) {
        emit taskCreationFailed("Le nom de la sous-tache est requis");
        return false;
    }

    if (parentTaskId <= 0) {
        emit taskCreationFailed("Tache parent invalide");
        return false;
    }

    qDebug() << "TaskController: Creating subtask:" << subTaskName << "for task" << parentTaskId;

    try {
        TaskData newSubTask;
        newSubTask.nomTache = subTaskName.toStdString();
        newSubTask.descTache = description.toStdString();
        newSubTask.memProcessigner = assignedToId;

        // Set date
        if (subTaskDate.isEmpty()) {
            newSubTask.dataTache = QDateTime::currentDateTime().toString("yyyy-MM-dd").toStdString();
        }
        else {
            newSubTask.dataTache = subTaskDate.toStdString();
        }

        // Set estimated time (default to 00:00:00 if empty)
        if (estimatedTime.isEmpty()) {
            newSubTask.tempsTache = "00:00:00";
        }
        else {
            newSubTask.tempsTache = estimatedTime.toStdString();
        }

        int subTaskId = m_dbManager->createSubTask(parentTaskId, newSubTask);

        if (subTaskId > 0) {
            qDebug() << "TaskController: SubTask created successfully with ID:" << subTaskId;
            emit taskCreated(subTaskId);

            // Optionally reload tasks for current project
            if (m_currentProjectId > 0) {
                loadTasksForProject(m_currentProjectId);
            }

            return true;
        }
        else {
            emit taskCreationFailed("Echec de la creation de la sous-tache");
            return false;
        }
    }
    catch (const std::exception& e) {
        qCritical() << "TaskController: Error creating subtask:" << e.what();
        QString errorMsg = "Erreur: ";
        errorMsg += QString::fromUtf8(e.what());
        emit taskCreationFailed(errorMsg);
        return false;
    }
}

bool TaskController::deleteSubTask(int taskId)
{
    qDebug() << "TaskController: Deleting subtask (and all children):" << taskId;

    try {
        bool success = m_dbManager->deleteSubTask(taskId);

        if (success) {
            qDebug() << "TaskController: SubTask deleted successfully";
            emit taskDeleted(taskId);

            // Reload tasks for current project
            if (m_currentProjectId > 0) {
                loadTasksForProject(m_currentProjectId);
            }
            return true;
        }
        else {
            emit taskDeletionFailed("Echec de la suppression de la sous-tache");
            return false;
        }
    }
    catch (const std::exception& e) {
        qCritical() << "TaskController: Error deleting subtask:" << e.what();
        QString errorMsg = "Erreur: ";
        errorMsg += QString::fromUtf8(e.what());
        emit taskDeletionFailed(errorMsg);
        return false;
    }
}

QVariantMap TaskController::getTaskHierarchy(int taskId)
{
    qDebug() << "TaskController: Getting task hierarchy for ID:" << taskId;

    try {
        TaskData task = m_dbManager->getTaskById(taskId);
        QVariantMap taskMap = taskDataToVariantMap(task);

        // Recursively get subtasks
        QVariantList subTasks;
        std::vector<TaskData> subTasksData = m_dbManager->getSubTasksByTask(taskId);

        for (const auto& subTask : subTasksData) {
            // Recursive call to get full hierarchy
            subTasks.append(getTaskHierarchy(subTask.idTache));
        }

        taskMap["subTasks"] = subTasks;
        return taskMap;
    }
    catch (const std::exception& e) {
        qCritical() << "TaskController: Error getting task hierarchy:" << e.what();
        QString errorMsg = "Erreur lors du chargement de la hierarchie: ";
        errorMsg += QString::fromUtf8(e.what());
        emit errorOccurred(errorMsg);
        return QVariantMap();
    }
}

QVariantList TaskController::getAvailableEmployees()
{
    qDebug() << "TaskController: Loading all employees";
    QVariantList employeeList;

    try {
        std::vector<std::tuple<int, std::string, std::string>> employees = m_dbManager->getAllEmployees();

        for (const auto& employee : employees) {
            QVariantMap employeeMap;
            employeeMap["idEmploye"] = std::get<0>(employee);
            employeeMap["nom"] = QString::fromStdString(std::get<1>(employee));
            employeeMap["prenom"] = QString::fromStdString(std::get<2>(employee));
            employeeMap["fullName"] = QString::fromStdString(std::get<2>(employee) + " " + std::get<1>(employee));
            employeeList.append(employeeMap);
        }

        qDebug() << "TaskController: Loaded" << employeeList.size() << "employees";
    }
    catch (const std::exception& e) {
        qCritical() << "TaskController: Error loading employees:" << e.what();
        QString errorMsg = "Erreur lors du chargement des employes: ";
        errorMsg += QString::fromUtf8(e.what());
        emit errorOccurred(errorMsg);
    }

    return employeeList;
}

QVariantList TaskController::getDepartmentEmployees()
{
    if (!m_currentUser) {
        qWarning() << "TaskController: No current user set";
        return QVariantList();
    }

    qDebug() << "TaskController: Loading employees for department" << m_currentUser->getDepartementId();
    QVariantList employeeList;

    try {
        std::vector<std::tuple<int, std::string, std::string>> employees =
            m_dbManager->getEmployeesByDepartment(m_currentUser->getDepartementId());

        for (const auto& employee : employees) {
            QVariantMap employeeMap;
            employeeMap["idEmploye"] = std::get<0>(employee);
            employeeMap["nom"] = QString::fromStdString(std::get<1>(employee));
            employeeMap["prenom"] = QString::fromStdString(std::get<2>(employee));
            employeeMap["fullName"] = QString::fromStdString(std::get<2>(employee) + " " + std::get<1>(employee));
            employeeList.append(employeeMap);
        }

        qDebug() << "TaskController: Loaded" << employeeList.size() << "department employees";
    }
    catch (const std::exception& e) {
        qCritical() << "TaskController: Error loading department employees:" << e.what();
        QString errorMsg = "Erreur lors du chargement des employes: ";
        errorMsg += QString::fromUtf8(e.what());
        emit errorOccurred(errorMsg);
        return QVariantList();
    }

    return employeeList;
}