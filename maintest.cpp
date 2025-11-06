#include <iostream>
#include <string>
#include <memory>
#include "DatabaseManager.h"
#include "User.h"
#include "config.h"


void displayMenu() {
    std::cout << "\n=== Employe Authentication System ===" << std::endl;
    std::cout << "1. Authenticate User" << std::endl;
    std::cout << "2. Test Database Connection" << std::endl;
    std::cout << "3. Exit" << std::endl;
    std::cout << "Choose an option: ";
}
/*
int maintest() {
    try {
        // Initialize database connection
        DatabaseManager dbManager(DB_SERVER, DB_USER, DB_PASSWORD, DB_NAME);

        int choice;
        std::string email, password;

        do {
            displayMenu();
            std::cin >> choice;
            std::cin.ignore(); // Clear newline character

            switch (choice) {
            case 1: {
                std::cout << "Enter email: ";
                std::getline(std::cin, email);

                std::cout << "Enter password: ";
                std::getline(std::cin, password);

                auto user = dbManager.authenticateUser(email, password);
                if (user) {
                    std::cout << "\nAuthentication successful!" << std::endl;
                    user->printInfo();
                }
                else {
                    std::cout << "\nAuthentication failed!" << std::endl;
                }
                break;
            }

            case 2: {
                if (dbManager.testConnection()) {
                    std::cout << "Database connection is working properly." << std::endl;
                }
                else {
                    std::cout << "Database connection test failed." << std::endl;
                }
                break;
            }

            case 3:
                std::cout << "Goodbye!" << std::endl;
                break;

            default:
                std::cout << "Invalid option. Please try again." << std::endl;
            }

        } while (choice != 3);

    }
    catch (const std::exception& e) {
        std::cerr << "Fatal error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
*/