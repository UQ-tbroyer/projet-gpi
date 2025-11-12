#ifndef TASKDATA_H
#define TASKDATA_H

#include <string>

struct TaskData {
    int idTache;
    int idProject;
    int memProcessigner;
    int idParentTache;
    std::string nomTache;
    std::string descTache;
    std::string dataTache;
    std::string tempsTache;
    std::string assigneeName;

    TaskData()
        : idTache(0)
        , idProject(0)
        , memProcessigner(0)
        , idParentTache(0)  // 0 means no parent (root task)
        , nomTache("")
        , descTache("")
        , dataTache("")
        , tempsTache("00:00:00")
        , assigneeName("")
    {}
};
#endif // TASKDATA_H once
