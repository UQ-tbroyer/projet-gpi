#ifndef PROJECTDATA_H
#define PROJECTDATA_H

#include <string>

struct ProjectData {
    int idProject;
    int idClient;
    int idDepartement;
    std::string nomProject;
    std::string dataProject;
    std::string tempRepository;
    double coutService;
    std::string nomClient;

    ProjectData() : idProject(0), idClient(0), idDepartement(0), coutService(0.0) {}
};
#endif // PROJECTDATA_H