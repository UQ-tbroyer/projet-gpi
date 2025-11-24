#include "Security.h"
#include <openssl/evp.h>
#include <openssl/err.h>
#include <sstream>
#include <iomanip>
#include <regex>
#include <stdexcept>
#include <string>
#include <iostream>


namespace Security {

    std::string hashPassword(const std::string& password) {
        EVP_MD_CTX* context = EVP_MD_CTX_new();
        if (!context) {
            throw std::runtime_error("Failed to create EVP context");
        }

        unsigned char hash[EVP_MAX_MD_SIZE];
        unsigned int hashLength = 0;

        // Initialize the digest operation with SHA-256
        if (EVP_DigestInit_ex(context, EVP_sha256(), nullptr) != 1) {
            EVP_MD_CTX_free(context);
            throw std::runtime_error("Failed to initialize SHA256 digest");
        }

        // Process the input data
        if (EVP_DigestUpdate(context, password.c_str(), password.length()) != 1) {
            EVP_MD_CTX_free(context);
            throw std::runtime_error("Failed to update SHA256 digest");
        }

        // Finalize the digest and get the hash
        if (EVP_DigestFinal_ex(context, hash, &hashLength) != 1) {
            EVP_MD_CTX_free(context);
            throw std::runtime_error("Failed to finalize SHA256 digest");
        }

        EVP_MD_CTX_free(context);

        // Convert hash to hexadecimal string
        std::stringstream ss;
        for (unsigned int i = 0; i < hashLength; ++i) {
            ss << std::hex << std::setw(2) << std::setfill('0') << static_cast<int>(hash[i]);
        }

        return ss.str();
    }

    bool verifyPassword(const std::string& password, const std::string& hash) {
        std::cout << "here" << std::endl;
        std::cout << password << std::endl;
        std::cout << hash << std::endl;
        std::string hashedInput = hashPassword(password);
        std::cout << hashedInput << std::endl;
        return hashedInput == hash;
    }

    bool isValidEmail(const std::string& email) {
        // Basic email validation regex
        const std::regex pattern(R"(^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$)");
        return std::regex_match(email, pattern);
    }

} // namespace Security