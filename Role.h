#ifndef ROLE_H
#define ROLE_H

#include <string>

enum class Role {
    PROFESSEUR,
    ETUDIANT,
    ADMIN
};

inline Role intToRole(int roleId) {
    switch (roleId) {
    case 0: return Role::ADMIN;
    case 1: return Role::PROFESSEUR;
    case 2: return Role::ETUDIANT;
    default: return Role::ETUDIANT; 
    }
}

inline std::string roleToString(Role role) {
    switch (role) {
    case Role::ADMIN: return "ADMIN";
    case Role::PROFESSEUR: return "PROFESSEUR";
    case Role::ETUDIANT: return "ETUDIANT";
    default: return "UNKNOWN";
    }
}

#endif 
