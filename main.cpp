#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include "DatabaseManager.h"
#include "LoginController.h"
#include "ProjectController.h"
#include "TaskController.h"
#include "config.h"
#include "User.h"
#include <iostream>
int main(int argc, char* argv[])
{
    std::cout << "=== TEST CONSOLE ===" << std::endl;
    QGuiApplication app(argc, argv);

    // Initialize database connection using config.h credentials
    DatabaseManager* dbManager = nullptr;
    try {
        dbManager = new DatabaseManager(
            DB_SERVER,
            DB_USER,
            DB_PASSWORD,
            DB_NAME
        );

        if (!dbManager->testConnection()) {
            qCritical() << "Failed to connect to database";
            delete dbManager;
            return -1;
        }

        qDebug() << "Database connection successful";
    }
    catch (const std::exception& e) {
        qCritical() << "Database initialization error:" << e.what();
        if (dbManager) {
            delete dbManager;
        }
        return -1;
    }

    // Create login controller
    LoginController* loginController = new LoginController(dbManager, &app);

    // CREATE PROJECT CONTROLLER with nullptr user initially (will be set after login)
    ProjectController* projectController = new ProjectController(dbManager, nullptr, &app);

    // CREATE TASK CONTROLLER with nullptr user initially (will be set after login)
    TaskController* taskController = new TaskController(dbManager, nullptr, &app);

    // Connect login success to update controllers with current user
    QObject::connect(loginController, &LoginController::loginSuccess, [=]() {
        User* currentUser = loginController->getUser();
        if (currentUser) {
            projectController->setCurrentUser(currentUser);
            taskController->setCurrentUser(currentUser);
            qDebug() << "Controllers updated with current user:" << currentUser->getId();
        }
        else {
            qWarning() << "Login succeeded but no current user found!";
        }
        });

    // Setup QML engine
    QQmlApplicationEngine engine;

    // Expose controllers to QML as context properties
    engine.rootContext()->setContextProperty("loginController", loginController);
    engine.rootContext()->setContextProperty("projectController", projectController);
    engine.rootContext()->setContextProperty("taskController", taskController);

    // Load the login QML file
    const QUrl url(QUrl::fromLocalFile("C:/Users/david/source/repos/QtQuickApplication2/QtQuickApplication2/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Failed to load QML file";
        delete taskController;
        delete projectController;
        delete loginController;
        delete dbManager;
        return -1;
    }

    qDebug() << "Application started successfully";

    // Run the application
    int resultCode = app.exec();

    // Cleanup
    delete taskController;
    delete projectController;
    delete loginController;
    delete dbManager;

    return resultCode;
}
