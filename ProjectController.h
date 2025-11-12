#ifndef PROJECTCONTROLLER_H
#define PROJECTCONTROLLER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <vector>
#include <memory>
#include "ProjectData.h"

class DatabaseManager;
class User;



class ProjectController : public QObject
{
    Q_OBJECT
        Q_PROPERTY(QVariantList projects READ projects NOTIFY projectsChanged)
        Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit ProjectController(DatabaseManager* dbManager, User* currentUser, QObject* parent = nullptr);
    ~ProjectController();

    // Q_PROPERTY getters
    QVariantList projects() const { return m_projects; }
    bool loading() const { return m_loading; }

    // Q_INVOKABLE methods - callable from QML
    Q_INVOKABLE void loadProjects();
    Q_INVOKABLE void loadProjectsByUser();
    Q_INVOKABLE void loadProjectsByDepartment();
    Q_INVOKABLE bool createProject(const QString& projectName,
        int clientId,
        const QString& repository,
        double cost,
        const QString& projectDate);
    Q_INVOKABLE bool updateProject(int projectId,
        const QString& projectName,
        const QString& repository,
        double cost);
    Q_INVOKABLE bool deleteProject(int projectId);
    Q_INVOKABLE QVariantList getClients();
    Q_INVOKABLE void loadClients();
    Q_INVOKABLE QVariantMap getProjectDetails(int projectId);

    // Setter for current user (when user changes)
    void setCurrentUser(User* user);

signals:
    void projectsChanged();
    void loadingChanged();
    void clientsLoaded();
    void projectCreated(int projectId);
    void projectCreationFailed(const QString& error);
    void projectUpdated(int projectId);
    void projectUpdateFailed(const QString& error);
    void projectDeleted(int projectId);
    void projectDeletionFailed(const QString& error);
    void errorOccurred(const QString& error);

private:
    DatabaseManager* m_dbManager;
    User* m_currentUser;
    QVariantList m_projects;
    bool m_loading;

    // Helper methods
    void setLoading(bool loading);
    QVariantMap projectDataToVariantMap(const ProjectData& project) const;
    std::vector<ProjectData> convertToProjectDataVector(const std::vector<ProjectData>& projects);
};

#endif // PROJECTCONTROLLER_H