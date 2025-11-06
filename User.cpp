#include "User.h"
#include "Role.h"
#include <iostream>

User::User(Role role, int id, int departementId, string nom, string prenom, string email, string passwordHash) {
	this->role = role;
	this->id = id;
	this->departementId = departementId;
	this->nom = nom;
	this->prenom = prenom;
	this->email = email;
    this->passwordHash = passwordHash;

}

User::~User() {
}

void User::printInfo() const {
    std::cout << "=== User Information ===" << std::endl;
    std::cout << "ID: " << id << std::endl;
    std::cout << "Name: " << prenom << " " << nom << std::endl;
    std::cout << "Email: " << email << std::endl;
    std::cout << "Department ID: " << departementId << std::endl;
    //std::cout << "Role ID: " << role << std::endl;
    std::cout << "=========================" << std::endl;
}
