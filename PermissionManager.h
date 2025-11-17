#ifndef PERMISSIONMANAGER_H
#define PERMISSIONMANAGER_H

#include "User.h"
#include "Role.h"
#include <QObject>

class PermissionManager : public QObject {
    Q_OBJECT

public:
    explicit PermissionManager(QObject* parent = nullptr);

    // Permission check methods
    static bool canCreateProject(const User* user);
    static bool canEditProject(const User* user, int projectDepartmentId);
    static bool canDeleteProject(const User* user, int projectDepartmentId);
    static bool canViewProject(const User* user, int projectDepartmentId, int projectId);

    static bool canCreateTask(const User* user, int projectDepartmentId);
    static bool canEditTask(const User* user, int taskAssigneeId, int projectDepartmentId);
    static bool canDeleteTask(const User* user, int projectDepartmentId);
    static bool canAssignTask(const User* user, int projectDepartmentId);
    static bool canChangeTaskStatus(const User* user, int taskAssigneeId);

    static bool canViewAllProjects(const User* user);
    static bool canViewDepartmentProjects(const User* user);
    static bool canViewAssignedProjects(const User* user);

    static bool canManageEmployees(const User* user);
    static bool canManageClients(const User* user);

    // Role helpers
    static bool isAdmin(const User* user);
    static bool isGestionnaire(const User* user);
    static bool isEmploye(const User* user);

    // Get user role as string for QML
    static QString getUserRoleString(const User* user);
};

#endif // PERMISSIONMANAGER_H
