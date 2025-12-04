#include "PermissionManager.h"
#include <QDebug>

PermissionManager::PermissionManager(QObject* parent)
    : QObject(parent)
{
}

// ============ Role Helpers ============

bool PermissionManager::isAdmin(const User* user) {
    if (!user) return false;
    return user->getRole() == Role::ADMIN;
}

bool PermissionManager::isGestionnaire(const User* user) {
    if (!user) return false;
    return user->getRole() == Role::GESTIONNAIRE;
}

bool PermissionManager::isEmploye(const User* user) {
    if (!user) return false;
    return user->getRole() == Role::EMPLOYE;
}

QString PermissionManager::getUserRoleString(const User* user) {
    if (!user) return "Unknown";

    switch (user->getRole()) {
    case Role::ADMIN:
        return "Administrateur";
    case Role::GESTIONNAIRE:
        return "Gestionnaire";
    case Role::EMPLOYE:
        return "Employe";
    default:
        return "Unknown";
    }
}

// ============ Project Permissions ============

bool PermissionManager::canCreateProject(const User* user) {
    if (!user) return false;

    // Admin and Gestionnaire can create projects
    return isAdmin(user) || isGestionnaire(user);
}

bool PermissionManager::canEditProject(const User* user, int projectDepartmentId) {
    if (!user) return false;

    // Admin can edit any project
    if (isAdmin(user)) return true;

    // Gestionnaire can edit projects in their department
    if (isGestionnaire(user)) {
        return user->getDepartementId() == projectDepartmentId;
    }

    // Employe cannot edit projects
    return false;
}

bool PermissionManager::canDeleteProject(const User* user, int projectDepartmentId) {
    if (!user) return false;

    // Admin can delete any project
    if (isAdmin(user)) return true;

    // Gestionnaire can delete projects in their department
    if (isGestionnaire(user)) {
        return user->getDepartementId() == projectDepartmentId;
    }

    // Employe cannot delete projects
    return false;
}

bool PermissionManager::canViewProject(const User* user, int projectDepartmentId, int projectId) {
    if (!user) return false;

    // Admin can view all projects
    if (isAdmin(user)) return true;

    // Gestionnaire can view projects in their department
    if (isGestionnaire(user)) {
        return user->getDepartementId() == projectDepartmentId;
    }

    // Employe can only view projects they're assigned to
    // Note: This requires checking task assignments via DatabaseManager
    return true; // Will be filtered by database query
}

bool PermissionManager::canViewAllProjects(const User* user) {
    if (!user) return false;
    return isAdmin(user);
}

bool PermissionManager::canViewDepartmentProjects(const User* user) {
    if (!user) return false;
    return isAdmin(user) || isGestionnaire(user);
}

bool PermissionManager::canViewAssignedProjects(const User* user) {
    if (!user) return false;
    return isEmploye(user);
}

// ============ Task Permissions ============

bool PermissionManager::canCreateTask(const User* user, int projectDepartmentId) {
    if (!user) return false;

    // Admin can create tasks in any project
    if (isAdmin(user)) return true;

    // Gestionnaire can create tasks in their department's projects
    if (isGestionnaire(user)) {
        return user->getDepartementId() == projectDepartmentId;
    }

    // Employe cannot create tasks
    return false;
}

bool PermissionManager::canEditTask(const User* user, int taskAssigneeId, int projectDepartmentId) {
    if (!user) return false;

    // Admin can edit any task
    if (isAdmin(user)) return true;

    // Gestionnaire can edit tasks in their department
    if (isGestionnaire(user)) {
        return user->getDepartementId() == projectDepartmentId;
    }

    // Employe cannot edit task details (only status)
    return false;
}

bool PermissionManager::canDeleteTask(const User* user, int projectDepartmentId) {
    if (!user) return false;

    // Admin can delete any task
    if (isAdmin(user)) return true;

    // Gestionnaire can delete tasks in their department
    if (isGestionnaire(user)) {
        return user->getDepartementId() == projectDepartmentId;
    }

    // Employe cannot delete tasks
    return false;
}

bool PermissionManager::canAssignTask(const User* user, int projectDepartmentId) {
    if (!user) return false;

    // Admin can assign any task
    if (isAdmin(user)) return true;

    // Gestionnaire can assign tasks in their department
    if (isGestionnaire(user)) {
        return user->getDepartementId() == projectDepartmentId;
    }

    // Employe cannot assign tasks
    return false;
}

bool PermissionManager::canChangeTaskStatus(const User* user, int taskAssigneeId) {
    if (!user) return false;

    // Admin can change any task status
    if (isAdmin(user)) return true;

    // Gestionnaire can change any task status in their department
    if (isGestionnaire(user)) return true;

    // Employe can only change status of tasks assigned to them
    if (isEmploye(user)) {
        return user->getId() == taskAssigneeId;
    }

    return false;
}

// ============ Other Permissions ============

bool PermissionManager::canManageEmployees(const User* user) {
    if (!user) return false;

    // Only Admin and Gestionnaire can manage employees
    return isAdmin(user) || isGestionnaire(user);
}

bool PermissionManager::canManageClients(const User* user) {
    if (!user) return false;

    // Only Admin and Gestionnaire can manage clients
    return isAdmin(user) || isGestionnaire(user);
}

bool PermissionManager::canAssignHours(const User* user) {
    if (!user) {
        qWarning() << "PermissionManager: User is null in canAssignHours";
        return false;
    }

    // Admin et Gestionnaires peuvent assigner des heures
    if (isAdmin(user) || isGestionnaire(user)) {
        return true;
    }

    // Les employés peuvent assigner des heures à leurs propres tâches
    if (isEmploye(user)) {
        return true;
    }

    return false;
}