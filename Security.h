#ifndef SECURITY_H
#define SECURITY_H

#include <string>

namespace Security {
    std::string hashPassword(const std::string& password);
    bool verifyPassword(const std::string& password, const std::string& hash);
    bool isValidEmail(const std::string& email);
}

#endif
