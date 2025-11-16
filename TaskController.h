#ifndef TASKCONTROLLER_H
#define TASKCONTROLLER_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>

#include "DatabaseManager.h"
#include "User.h"
#include "TaskData.h"


class TaskController : public QObject
{
    Q_OBJECT

        Q_PROPERTY(int currentProjectId READ currentProjectId WRITE setCurrentProjectId NOTIFY currentProjectIdChanged)
        Q_PROPERTY(bool loading READ loading WRITE setLoading NOTIFY loadingChanged)
        Q_PROPERTY(QVariantList tasks READ tasks NOTIFY tasksChanged)

public:
    explicit TaskController(DatabaseManager* dbManager,
        User* currentUser = nullptr,
        QObject* parent = nullptr);
    ~TaskController();

    // --- Getters ---
    int currentProjectId() const { return m_currentProjectId; }
    bool loading() const { return m_loading; }
    Q_INVOKABLE User* getCurrentUser() const { return m_currentUser; }
    QVariantList tasks() const { return m_tasks; }

    // --- Setters ---
    void setCurrentUser(User* user);
    void setCurrentProjectId(int projectId);
    void setLoading(bool loading);

    // --- Task Conversion ---
    QVariantMap taskDataToVariantMap(const TaskData& task) const;
    QString formatTimeForDisplay(int timeMinutes) const;
    Q_INVOKABLE QVariantList getTasksForProjectByStatus(int projectId, const QString& status);
    Q_INVOKABLE QVariantList getSubTasksByStatus(int parentTaskId, const QString& status);
    
  
public slots:

    // --- Chargement ---
    void loadTasksForProject(int projectId);
    void loadTasksForCurrentProject();

    // --- Opérations principales sur les tâches ---
    bool createTask(int projectId,
        const QString& taskName,
        const QString& description,
        int idParentTache,
        int assignedToId,
        const int estimatedTime,
        const QString& dateDebut,
        const QString& dateFin,
        const QString& etat);

    bool updateTask(int taskId,
        const QString& taskName,
        const QString& description,
        int assignedToId,
        const QString& estimatedTime,
        const QString& dateDebut,
        const QString& dateFin,
        const QString& etat);

    bool deleteTask(int taskId);
    bool assignTask(int taskId, int employeeId);

    // --- Détails ---
    QVariantMap getTaskDetails(int taskId);

    // --- Sous-tâches ---
    QVariantList getSubTasks(int taskId);

    bool createSubTask(int parentTaskId,
        const QString& subTaskName,
        const QString& description,
        int assignedToId,
        const int estimatedTime,
        const QString& dateDebut,
        const QString& dateFin,
        const QString& etat);


    bool deleteSubTask(int taskId);

    QVariantMap getTaskHierarchy(int taskId);

    // --- Employés ---
    QVariantList getAvailableEmployees();
    QVariantList getDepartmentEmployees();

    // --- Pour QML (retourne m_tasks après reload) ---
    QVariantList getTasksForProject(int projectId);

signals:

    // Propriétés
    void currentProjectIdChanged();
    void loadingChanged();
    void tasksChanged();
    void subTasksChanged(int parentTaskId);

    // Success
    void taskCreated(int taskId);
    void taskUpdated(int taskId);
    void taskDeleted(int taskId);
    void taskAssigned(int taskId, int employeeId);

    // Errors
    void errorOccurred(const QString& errorMessage);
    void taskCreationFailed(const QString& errorMessage);
    void taskUpdateFailed(const QString& errorMessage);
    void taskDeletionFailed(const QString& errorMessage);
    void taskAssignmentFailed(const QString& errorMessage);


private:
    DatabaseManager* m_dbManager;
    User* m_currentUser;
    int m_currentProjectId;

    bool m_loading;
    QVariantList m_tasks;
};

#endif // TASKCONTROLLER_H
