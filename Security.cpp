#include "Security.h"
#include <QCryptographicHash>
#include <QRegularExpression>
#include <QString>

namespace Security {

    std::string hashPassword(const std::string& password) {
        QByteArray hash = QCryptographicHash::hash(
            QString::fromStdString(password).toUtf8(),
            QCryptographicHash::Sha256
        );
        return hash.toHex().toStdString();
    }

    bool verifyPassword(const std::string& password, const std::string& hash) {
        return hashPassword(password) == hash;
    }

    bool isValidEmail(const std::string& email) {
        QRegularExpression pattern(R"(^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$)");
        return pattern.match(QString::fromStdString(email)).hasMatch();
    }

} // namespace Security