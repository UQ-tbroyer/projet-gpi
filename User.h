#ifndef USER_H
#define USER_H

#include "Role.h"
#include <string>

using namespace std;

enum class Role;

class User {
private:
    Role role; 
    int id;
    int departementId;
    string nom;
    string prenom;
    string email;
    string passwordHash;

public:
    User(Role role, int id , int departementId, string nom, string prenom, string email, string passwordHash);
    virtual ~User(); 
    void printInfo() const; 

    Role getRole() const { return role; }
    int getId() const { return id; }
    int getDepartementId() const { return departementId; }
    string getNom() const { return nom; }
    string getPrenom() const { return prenom; }
    string getEmail() const { return email; }
    string getPasswordHash() const { return passwordHash; }
};

#endif 