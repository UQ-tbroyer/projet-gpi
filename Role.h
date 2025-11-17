#ifndef ROLE_H
#define ROLE_H

#include <string>

enum class Role {
    ADMIN = 3,       // Database role ID 3
    GESTIONNAIRE = 1,  // Database role ID 1 (Gestionnaire)
    EMPLOYE = 2     // Database role ID 2 (Employé)
};

inline Role intToRole(int roleId) {
    switch (roleId) {
    case 3: return Role::ADMIN;
    case 1: return Role::GESTIONNAIRE;
    case 2: return Role::EMPLOYE;
    default: return Role::EMPLOYE;
    }
}

inline std::string roleToString(Role role) {
    switch (role) {
    case Role::ADMIN: return "ADMIN";
    case Role::GESTIONNAIRE: return "GESTIONNAIRE";
    case Role::EMPLOYE: return "EMPLOYE";
    default: return "UNKNOWN";
    }
}

#endif 