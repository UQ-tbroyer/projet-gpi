#ifndef PROJECTDATA_H
#define PROJECTDATA_H

#include <string>

struct ProjectData {
    int idProject;
    int idClient;
    int idDepartement;
    double tempsProject;
    std::string nomProject;
    std::string dataProject;
    std::string tempRepository;
    std::string etatProject;
    double coutService;
    std::string nomClient;
    bool estTemplate;

    ProjectData() : idProject(0), idClient(0), idDepartement(0), tempsProject(0), coutService(0.0), estTemplate(false) {}
};
#endif // PROJECTDATA_H