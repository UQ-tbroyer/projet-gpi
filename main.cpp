#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include "DatabaseManager.h"
#include "LoginController.h"
#include "config.h"

int main(int argc, char* argv[])
{
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

    // Setup QML engine
    QQmlApplicationEngine engine;

    // Expose loginController to QML as a context property
    engine.rootContext()->setContextProperty("loginController", loginController);

    // Load the login QML file
    const QUrl url(QUrl::fromLocalFile("C:/Users/Thomas/Documents/projet_gpi/QtQuickApplication1/QtQuickApplication1/QtQuickApplication1/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Failed to load QML file";
        delete loginController;
        delete dbManager;
        return -1;
    }

    // Run the application
    int resultCode = app.exec();

    // Cleanup
    delete loginController;
    delete dbManager;

    return resultCode;
}
/*
int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    // Chemin local, pas une ressource .qrc
    engine.load(QUrl::fromLocalFile("C:/Users/Thomas/Documents/projet_gpi/QtQuickApplication1/QtQuickApplication1/QtQuickApplication1/main.qml"));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
*/