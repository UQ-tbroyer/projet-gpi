#include "LoginController.h"
#include "DatabaseManager.h"
#include "User.h"
#include <QDebug>

LoginController::LoginController(DatabaseManager* dbManager, QObject* parent)
    : QObject(parent), m_dbManager(dbManager), m_currentUser(nullptr)
{
}

LoginController::~LoginController()
{
    if (m_currentUser) {
        delete m_currentUser;
        m_currentUser = nullptr;
    }
}

QString LoginController::currentUserName() const
{
    if (m_currentUser) {
        return QString::fromStdString(m_currentUser->getPrenom() + " " + m_currentUser->getNom());
    }
    return QString();
}

QString LoginController::currentUserEmail() const
{
    if (m_currentUser) {
        return QString::fromStdString(m_currentUser->getEmail());
    }
    return QString();
}

void LoginController::handleLogin(const QString& email, const QString& password)
{
    qDebug() << "LoginController: Attempting login for" << email;

    if (email.isEmpty() || password.isEmpty()) {
        emit loginFailed("L'email et le mot de passe sont requis");
        return;
    }

    try {
        // Convert QString to std::string for database operations
        std::string emailStd = email.toStdString();
        std::string passwordStd = password.toStdString();

        // Authenticate user through DatabaseManager
        User* user = m_dbManager->authenticateUser(emailStd, passwordStd);

        if (user) {
            // Clean up old user if exists
            if (m_currentUser) {
                delete m_currentUser;
            }

            m_currentUser = user;

            qDebug() << "LoginController: Authentication successful for" << email;
            emit loginSuccess();
        }
        else {
            qDebug() << "LoginController: Authentication failed for" << email;
            qDebug() << "LoginController: Authentication failed for" << password;
            emit loginFailed("Email ou mot de passe incorrect");
        }
    }
    catch (const std::exception& e) {
        qDebug() << "LoginController: Exception during login:" << e.what();
        emit loginFailed("Erreur de connexion à la base de données");
    }
}