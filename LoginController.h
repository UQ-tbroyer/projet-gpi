#ifndef LOGINCONTROLLER_H
#define LOGINCONTROLLER_H

#include <QObject>
#include <QString>

// Forward declarations
class DatabaseManager;
class User;

class LoginController : public QObject
{
    Q_OBJECT

public:
    explicit LoginController(DatabaseManager* dbManager, QObject* parent = nullptr);
    ~LoginController();

    Q_INVOKABLE QString currentUserName() const;
    Q_INVOKABLE QString currentUserEmail() const;
    Q_INVOKABLE void handleLogin(const QString& email, const QString& password);
    User* getUser() { return m_currentUser; }

signals:
    void loginSuccess();
    void loginFailed(const QString& errorMessage);

private:
    DatabaseManager* m_dbManager;
    User* m_currentUser;
};

#endif // LOGINCONTROLLER_H