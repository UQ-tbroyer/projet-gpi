#ifndef TASKCONTROLLER_H
#define TASKCONTROLLER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <vector>
#include "Taskdata.h"

class DatabaseManager;
class User;

class TaskController : public QObject
{
    Q_OBJECT
        Q_PROPERTY(QVariantList tasks READ tasks NOTIFY tasksChanged)
        Q_PROPERTY(int currentProjectId READ currentProjectId WRITE setCurrentProjectId NOTIFY currentProjectIdChanged)
        Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit TaskController(DatabaseManager* dbManager, User* currentUser, QObject* parent = nullptr);
    ~TaskController();

    // Q_PROPERTY getters/setters
    QVariantList tasks() const { return m_tasks; }
    int currentProjectId() const { return m_currentProjectId; }
    
    bool loading() const { return m_loading; }

    // Q_INVOKABLE methods - callable from QML
    Q_INVOKABLE void setCurrentProjectId(int projectId);
    Q_INVOKABLE void loadTasksForProject(int projectId);
    Q_INVOKABLE void loadTasksForCurrentProject();
    Q_INVOKABLE bool createTask(int projectId,
        const QString& taskName,
        const QString& description,
        int assignedToId,
        const QString& estimatedTime,
        const QString& taskDate);
    Q_INVOKABLE bool updateTask(int taskId,
        const QString& taskName,
        const QString& description,
        int assignedToId,
        const QString& estimatedTime);
    Q_INVOKABLE bool deleteTask(int taskId);
    Q_INVOKABLE bool assignTask(int taskId, int employeeId);
    Q_INVOKABLE QVariantMap getTaskDetails(int taskId);

    // Recursive SubTask methods (subtasks are tasks with parent references)
    Q_INVOKABLE QVariantList getSubTasks(int taskId);
    Q_INVOKABLE bool createSubTask(int parentTaskId,
        const QString& subTaskName,
        const QString& description,
        int assignedToId,
        const QString& estimatedTime,
        const QString& subTaskDate);
    Q_INVOKABLE bool deleteSubTask(int taskId);  // Deletes task and all children

    // Optional: Get complete task hierarchy
    Q_INVOKABLE QVariantMap getTaskHierarchy(int taskId);

    Q_INVOKABLE QVariantList getAvailableEmployees();
    Q_INVOKABLE QVariantList getDepartmentEmployees();

    // Setter for current user
    void setCurrentUser(User* user);

signals:
    void tasksChanged();
    void currentProjectIdChanged();
    void loadingChanged();
    void taskCreated(int taskId);
    void taskCreationFailed(const QString& error);
    void taskUpdated(int taskId);
    void taskUpdateFailed(const QString& error);
    void taskDeleted(int taskId);
    void taskDeletionFailed(const QString& error);
    void taskAssigned(int taskId, int employeeId);
    void taskAssignmentFailed(const QString& error);
    void errorOccurred(const QString& error);

private:
    DatabaseManager* m_dbManager;
    User* m_currentUser;
    QVariantList m_tasks;
    int m_currentProjectId;
    bool m_loading;

    // Helper methods
    void setLoading(bool loading);
    QVariantMap taskDataToVariantMap(const TaskData& task) const;
    QString formatTimeForDisplay(const std::string& timeStr) const;
};

#endif // TASKCONTROLLER_H