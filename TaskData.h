#ifndef TASKDATA_H
#define TASKDATA_H

#include <string>

struct TaskData {
    int idTache;
    int idProject;
    int memProcessigner;
    int idParentTache;      // 0 means no parent (root task)
    std::string nomTache;
    std::string descTache;
    int tempsTache;          // en int (comme défini dans MySQL)
    std::string dateDebut;   // YYYY-MM-DD
    std::string dateFin;     // YYYY-MM-DD
    std::string etat;        // exemple: "En cours"
    std::string assigneeName;

    TaskData()
        : idTache(0)
        , idProject(0)
        , memProcessigner(0)
        , idParentTache(0)
        , nomTache("")
        , descTache("")
        , tempsTache(10)
        , dateDebut("")        // valeur par défaut vide
        , dateFin("")          // valeur par défaut vide
        , etat("A Faire")     // valeur par défaut
        , assigneeName("")
    {}
};

#endif // TASKDATA_H

