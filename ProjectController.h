#ifndef PROJECTCONTROLLER_H
#define PROJECTCONTROLLER_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include "DatabaseManager.h"
#include "User.h"

class ProjectController : public QObject
{
    Q_OBJECT
        Q_PROPERTY(QVariantList projects READ projects NOTIFY projectsChanged)
        Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit ProjectController(DatabaseManager* dbManager, User* currentUser, QObject* parent = nullptr);
    ~ProjectController();

    QVariantList projects() const { return m_projects; }
    bool loading() const { return m_loading; }

    void setCurrentUser(User* user);

    // Project management methods
    Q_INVOKABLE void loadProjects();
    Q_INVOKABLE void loadProjectsByUser();
    Q_INVOKABLE void loadProjectsByDepartment();

    Q_INVOKABLE bool createProject(const QString& projectName,
        int clientId,
        const QString& repository,
        double cost,
        const QString& projectDate = "");

    Q_INVOKABLE bool updateProject(int projectId,
        const QString& projectName,
        const QString& repository,
        double cost);

    Q_INVOKABLE bool deleteProject(int projectId);

    Q_INVOKABLE QVariantMap getProjectDetails(int projectId);
    Q_INVOKABLE QVariantList getClients();
    Q_INVOKABLE void loadClients();

    // Permission check methods for QML
    Q_INVOKABLE bool canCreateProject() const;
    Q_INVOKABLE bool canEditProject(int projectId) const;
    Q_INVOKABLE bool canDeleteProject(int projectId) const;
    Q_INVOKABLE bool canViewAllProjects() const;
    Q_INVOKABLE QString getUserRole() const;

signals:
    void projectsChanged();
    void loadingChanged();
    void projectCreated(int projectId);
    void projectCreationFailed(const QString& error);
    void projectUpdated(int projectId);
    void projectUpdateFailed(const QString& error);
    void projectDeleted(int projectId);
    void projectDeletionFailed(const QString& error);
    void clientsLoaded();
    void errorOccurred(const QString& error);
    void currentUserChanged(); // ADD THIS LINE

private:
    DatabaseManager* m_dbManager;
    User* m_currentUser;
    QVariantList m_projects;
    bool m_loading;

    void setLoading(bool loading);
    QVariantMap projectDataToVariantMap(const ProjectData& project) const;
};

#endif // PROJECTCONTROLLER_H