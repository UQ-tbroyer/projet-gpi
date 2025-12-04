#include "TaskRepository.h"
#include <stdexcept>

TaskRepository::TaskRepository(sql::Connection* connection)
    : conn(connection)
{
}

TaskData TaskRepository::getTaskById(int id)
{
    std::unique_ptr<sql::PreparedStatement> stmt(
        conn->prepareStatement("SELECT * FROM taches WHERE idTache = ?")
    );
    stmt->setInt(1, id);

    std::unique_ptr<sql::ResultSet> res(stmt->executeQuery());

    if (!res->next()) {
        throw std::runtime_error("Task not found");
    }

    return mapResultToTask(res);
}

TaskData TaskRepository::mapResultToTask(std::unique_ptr<sql::ResultSet>& res)
{
    TaskData task;

    task.idTache = res->getInt("idTache");
    task.idProject = res->getInt("idProject");
    task.memProcessigner = res->getInt("memProcessigner");
    task.idParentTache = res->getInt("idParentTache");
    task.nomTache = res->getString("nomTache");
    task.descTache = res->getString("descTache");
    task.tempsTache = res->getInt("tempsTache");

    task.dateDebut = res->getString("dateDebut");
    task.dateFin = res->getString("dateFin");
    task.etat = res->getString("etat");

    task.assigneeName = res->getString("assigneeName");

    return task;
}
