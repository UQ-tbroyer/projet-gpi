import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 6.5
import QtQuick.Window 6.5

ApplicationWindow {
    id: window
    width: 1000
    height: 600
    visible: true
    title: projectName
    color: "white"

    property int projectId
    property string projectName
    property var taskController
    property var projectController

    // Charger les tâches quand la fenêtre est prête
    Component.onCompleted: {
        console.log("MAIN3: loading tasks for project", projectId)
        taskController.loadTasksForProject(projectId)
    }

    // --- Top Bar ---
    Row {
        id: topBar
        spacing: 20
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 20

        Button {
            text: "<- Retour"
            onClicked: window.close()
        }

        Text {
            text: projectName
            font.bold: true
            font.pointSize: 20
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // --- Left Menu ---
    Column {
        id: sideMenu
        spacing: 10
        anchors.top: topBar.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20

        Button {
            id: btnKanban
            text: "Kanban"
            width: 80
            height: 40
            onClicked: stackView.currentIndex = 0
        }

        Button {
            id: btnGantt
            text: "Gantt"
            width: 80
            height: 40
            onClicked: stackView.currentIndex = 1
        }
    }

    // --- Main Content ---
    StackLayout {
        id: stackView
        anchors.top: topBar.bottom
        anchors.left: sideMenu.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        currentIndex: 0

        // =====================
        // ===== KANBAN VIEW ===
        // =====================

        Flickable {
            clip: true
            contentWidth: kanbanRow.width

            Row {
                id: kanbanRow
                spacing: 20

                // Colonnes du Kanban
                Repeater {
                    model: ["A faire", "En cours", "A tester", "Terminee"]

                    Column {
                        property string columnName: modelData
                        spacing: 10

                        Rectangle {
                            width: 200
                            height: 450
                            radius: 10
                            border.color: "black"

                            Column {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 10

                                Text { text: columnName; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }

                                // === Tasks filtered by status ===
                                Repeater {
                                    id: taskRepeater
                                    model: taskController.getTasksForProjectByStatus(window.projectId, columnName) // filtrage côté C++
                                    delegate: Rectangle {
                                        width: parent.width - 20
                                        height: 45
                                        radius: 6
                                        border.color: "black"
                                        color: "lightyellow"

                                        Text { anchors.centerIn: parent; text: modelData["nomTache"] }
                                    }
                                }

                                // === Add new task ===
                                Button {
                                    text: "+ Ajouter une tâche"
                                    onClicked: {
                                        taskController.createTask(
                                            projectId,
                                            "Nouvelle tâche",
                                            "",                     // description vide
                                            taskController.getCurrentUser().id,
                                            10,                     // durée par défaut
                                            columnName,             // statut
                                            new Date(),              // dateDebut
                                            new Date()               // dateFin
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ===================
        // ===== GANTT =======
        // ===================

        Flickable {
            clip: true
            contentWidth: ganttContent.width

            Item {
                id: ganttContent
                width: 1000
                height: 600

                Column {
                    anchors.fill: parent
                    spacing: 20

                    Row {
                        spacing: 40
                        anchors.horizontalCenter: parent.horizontalCenter
                        Repeater {
                            model: ["Sept","Oct","Nov","Dec","Jan","Feb","Mar"]
                            Text { text: modelData }
                        }
                    }

                    Row {
                        spacing: 20

                        // Task names
                        Column {
                            spacing: 10
                            Repeater {
                                model: taskController.getTasksForProject(projectId)
                                Text { text: modelData.nomTache }
                            }
                        }

                        // Gantt bars
                        Rectangle {
                            id: ganttChart
                            width: 700
                            height: 300
                            border.color: "black"
                            color: "transparent"

                            Repeater {
                                model: taskController.getTasksForProject(projectId)

                                Rectangle {
                                    x: 50
                                    y: index * 40
                                    width: 100
                                    height: 30
                                    color: "lightblue"
                                    border.color: "black"
                                    Text { anchors.centerIn: parent; text: modelData.nomTache }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
