#include "TaskController.h"
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

TaskController::~TaskController() {}

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
    map["memProcessigner"] = task.memProcessigner;
    map["idParentTache"] = task.idParentTache;

    // sous-tâche
    map["isSubTask"] = (task.idParentTache > 0);

    // strings
    map["nomTache"] = QString::fromStdString(task.nomTache);
    map["descTache"] = QString::fromStdString(task.descTache);
    map["dateDebut"] = QString::fromStdString(task.dateDebut);
    map["dateFin"] = QString::fromStdString(task.dateFin);
    map["etat"] = QString::fromStdString(task.etat);
    map["assigneeName"] = QString::fromStdString(task.assigneeName);

    // temps
    map["tempsTache"] = task.tempsTache;

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
    }
    catch (const std::exception& e) {
        QString errorMsg = "Erreur lors du chargement des taches: ";
        errorMsg += QString::fromUtf8(e.what());
        emit errorOccurred(errorMsg);
    }
    setLoading(false);
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
        newTask.memProcessigner = assignedToId;
        newTask.idParentTache = idParentTache; // tâche normale

        QString today = QDate::currentDate().toString("yyyy-MM-dd");
        newTask.dateDebut = dateDebut.isEmpty() ? today.toStdString() : dateDebut.toStdString();
        newTask.dateFin = dateFin.toStdString();

        newTask.tempsTache = estimatedTime;
        newTask.etat = etat.toStdString();

        // assigneeName laissé par défaut : ""

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
    if (taskName.isEmpty()) {
        emit taskUpdateFailed("Le nom de la tâche est requis");
        return false;
    }

    try {
        TaskData updatedTask;

        updatedTask.idTache = taskId;
        updatedTask.nomTache = taskName.toStdString();
        updatedTask.descTache = description.toStdString();
        updatedTask.memProcessigner = assignedToId;

        updatedTask.tempsTache = estimatedTime.isEmpty() ? 0 : estimatedTime.toInt();
        updatedTask.dateDebut = dateDebut.toStdString();
        updatedTask.dateFin = dateFin.toStdString();
        updatedTask.etat = etat.toStdString();

        // les champs non modifiés restent à 0/"" → c'est le DBManager qui remplit

        bool success = m_dbManager->updateTask(updatedTask);
        if (success) {
            emit taskUpdated(taskId);
            if (m_currentProjectId > 0)
                loadTasksForProject(m_currentProjectId);
            return true;
        }

        emit taskUpdateFailed("Échec de la mise à jour de la tâche");
        return false;
    }
    catch (const std::exception& e) {
        emit taskUpdateFailed(QString("Erreur: ") + e.what());
        return false;
    }
}

// --- Suppression ---
bool TaskController::deleteTask(int taskId)
{
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
    try {
        TaskData task = m_dbManager->getTaskById(taskId);
        return taskDataToVariantMap(task);
    }
    catch (const std::exception& e) {
        QString errorMsg = "Erreur lors du chargement de la tâche: ";
        errorMsg += QString::fromUtf8(e.what());
        emit errorOccurred(errorMsg);
        return QVariantMap();
    }
}

// --- Sous-tâches ---
QVariantList TaskController::getSubTasks(int taskId)
{
    QVariantList subTaskList;
    try {
        std::vector<TaskData> subTasksData = m_dbManager->getSubTasksByTask(taskId);
        for (const auto& subTask : subTasksData)
            subTaskList.append(taskDataToVariantMap(subTask));
    }
    catch (const std::exception& e) {
        QString errorMsg = "Erreur lors du chargement des sous-tâches: ";
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
        newSubTask.memProcessigner = assignedToId;

        QString today = QDate::currentDate().toString("yyyy-MM-dd");
        newSubTask.dateDebut = subTaskDate.isEmpty() ? today.toStdString() : subTaskDate.toStdString();
        newSubTask.dateFin = newSubTask.dateDebut;

        newSubTask.tempsTache = estimatedTime.toInt();
        newSubTask.etat = "À Faire";

        int subTaskId = m_dbManager->createSubTask(parentTaskId, newSubTask);
        if (subTaskId > 0) {
            emit taskCreated(subTaskId);
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


