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
    property int refreshTrigger: 0  // Used to force refresh of tasks
    property bool isRefreshing: false  // Prevent recursive refreshes

    // Charger les tâches quand la fenêtre est prête
    // In main3.qml, replace your Component.onCompleted with:

      Component.onCompleted: {
        console.log("MAIN3: loading tasks for project", projectId)
        taskController.loadTasksForProject(projectId)
    
        // Simple connections without complex logic
        taskController.taskCreated.connect(function(taskId) {
            console.log("Task created - refreshing")
            refreshTrigger++
        })
    
        taskController.taskUpdated.connect(function(taskId) {
            console.log("Task updated - refreshing")
            refreshTrigger++
        })
    
        taskController.taskDeleted.connect(function(taskId) {
            console.log("Task deleted - refreshing")
            refreshTrigger++
        })
    }

    // --- Top Bar ---
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        height: 60
        color: "transparent"

        Button {
            id: backButton
            text: "<- Retour"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            onClicked: window.close()
        }

        Text {
            text: projectName
            font.bold: true
            font.pointSize: 20
            anchors.centerIn: parent
        }

        // --- Project Actions Menu ---
       // --- Project Actions Menu ---
        Row {
            spacing: 10
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Button {
                text: "✏️ Modifier"
                visible: projectController && projectController.canEditProject && 
                        projectController.canEditProject(projectId)
                onClicked: editProjectDialog.open()
            }

            Button {
                text: "🗑️ Supprimer"
                visible: projectController && projectController.canDeleteProject && 
                        projectController.canDeleteProject(projectId)
                onClicked: deleteProjectDialog.open()
            }
        }
    }

    // --- Edit Project Dialog ---
    Dialog {
        id: editProjectDialog
        title: "Modifier le projet"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        width: 400

        onAboutToShow: {
            // Load current project details
            var projectDetails = projectController.getProjectDetails(projectId)
            console.log("Loading project details:", JSON.stringify(projectDetails))
            
            editProjectNameField.text = projectDetails.nomProject || ""
            editRepositoryField.text = projectDetails.tempRepository || ""
            editCostField.text = projectDetails.coutService ? projectDetails.coutService.toString() : "0.0"
            
            // Load clients first
            var clients = projectController.getClients()
            editClientCombo.model = clients
            
            // Then set the current client
            editClientCombo.currentIndex = -1
            for (var i = 0; i < clients.length; i++) {
                if (clients[i].idClient === projectDetails.idClient) {
                    editClientCombo.currentIndex = i
                    console.log("Set client index to:", i, "for client:", clients[i].nomClient)
                    break
                }
            }
        }

        onAccepted: {
            var clientId = editClientCombo.currentIndex >= 0 
                ? editClientCombo.model[editClientCombo.currentIndex].idClient 
                : -1

            var success = projectController.updateProject(
                projectId,
                editProjectNameField.text,
                editRepositoryField.text,
                parseFloat(editCostField.text) || 0.0
            )

            if (success) {
                console.log("Project updated successfully")
                window.projectName = editProjectNameField.text
                window.title = editProjectNameField.text
                // No need to refresh trigger - project info doesn't affect task list
            } else {
                console.log("Failed to update project")
            }
        }

        contentItem: ColumnLayout {
            spacing: 10

            Label { text: "Nom du projet:" }
            TextField {
                id: editProjectNameField
                Layout.fillWidth: true
                placeholderText: "Nom du projet"
            }

            Label { text: "Client:" }
            ComboBox {
                id: editClientCombo
                Layout.fillWidth: true
                textRole: "nomClient"
            }

            Label { text: "Repository:" }
            TextField {
                id: editRepositoryField
                Layout.fillWidth: true
                placeholderText: "Repository path"
            }

            Label { text: "Coût du service:" }
            TextField {
                id: editCostField
                Layout.fillWidth: true
                placeholderText: "0.00"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }
        }
    }

    // --- Delete Project Confirmation Dialog ---
    Dialog {
        id: deleteProjectDialog
        title: "⚠️ Confirmer la suppression"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: parent

        Label {
            text: "Êtes-vous sûr de vouloir supprimer ce projet ?\n\n" +
                  "Projet: " + projectName + "\n\n" +
                  "⚠️ Cette action est irréversible et supprimera toutes les tâches associées!"
            wrapMode: Text.WordWrap
            width: 350
        }

        onAccepted: {
            console.log("Deleting project:", projectId)
            var success = projectController.deleteProject(projectId)
            if (success) {
                console.log("Project deleted successfully")
                window.close()
            } else {
                console.log("Failed to delete project")
            }
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
                                    // Force refresh when refreshTrigger changes
                                    model: {
                                        refreshTrigger  // dependency
                                        return taskController.getTasksForProjectByStatus(window.projectId, columnName)
                                    }
                                    
                                    delegate: Rectangle {
                                        width: parent.width - 20
                                        height: 60
                                        radius: 6
                                        border.color: "black"
                                        color: mouseArea.containsMouse ? "lightgreen" : "lightyellow"

                                        MouseArea {
                                            id: mouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            
                                            onClicked: {
                                                console.log("Opening task details for:", modelData.nomTache, "ID:", modelData.idTache)
                                                
                                                // Create and open TaskDetailsView window
                                                var component = Qt.createComponent("TaskDetailsView.qml")
                                                if (component.status === Component.Ready) {
                                                    var taskWindow = component.createObject(null, {
                                                        taskId: modelData.idTache,
                                                        taskName: modelData.nomTache,
                                                        projectId: window.projectId,
                                                        taskController: window.taskController,
                                                        projectController: window.projectController
                                                    })
                                                    taskWindow.show()
                                                } else if (component.status === Component.Error) {
                                                    console.error("Error loading component:", component.errorString())
                                                }
                                            }
                                        }

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 3

                                            Text { 
                                                text: modelData.nomTache
                                                font.bold: true
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                            Text { 
                                                text: "Assigné: " + (modelData.assigneeName || "Non assigné")
                                                font.pixelSize: 10
                                                color: "gray"
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }
                                }

                                // === Add new task ===
                                Button {
                                    text: "+ Ajouter une tâche"
                                    onClicked:{
                                        addTaskDialog.currentColumn = columnName;
                                        addTaskDialog.open()
                                    }
                                }
                                
                                Dialog {
                                    id: addTaskDialog
                                    title: "Créer une nouvelle tâche"
                                    modal: true
                                    standardButtons: Dialog.Ok | Dialog.Cancel

                                    property string currentColumn: ""

                                    onAccepted: {
                                        var assignedId = -1
                                        if (assignedUserField.currentIndex >= 0) {
                                            assignedId = assignedUserField.model[assignedUserField.currentIndex]["idEmploye"]
                                        }

                                        var success = taskController.createTask(
                                            window.projectId,
                                            taskNameField.text,
                                            descriptionField.text,
                                            -1,
                                            assignedId,
                                            parseInt(estimatedTimeField.text),
                                            startDateField.text,
                                            endDateField.text,
                                            currentColumn
                                        )

                                        if (success) {
                                            console.log("Task created successfully")
                                            // Trigger refresh
                                            refreshTrigger++
                                        } else {
                                            console.log("Erreur création tâche")
                                        }
                                    }

                                    contentItem: ColumnLayout {
                                        spacing: 10
                                        width: 300

                                        Label { text: "Nom de la tâche:" }
                                        TextField { id: taskNameField; placeholderText: "Nouvelle tâche" }

                                        Label { text: "Description:" }
                                        TextArea { id: descriptionField; placeholderText: "Description"; height: 80 }

                                        Label { text: "Assigné à:" }
                                        ComboBox {
                                            id: assignedUserField
                                            model: taskController.getAvailableEmployees()
                                            textRole: "fullName"
                                            currentIndex: -1
                                        }

                                        Label { text: "Temps estimé (minutes):" }
                                        TextField { id: estimatedTimeField; placeholderText: "10"; inputMethodHints: Qt.ImhDigitsOnly }

                                        Label { text: "Date de début (YYYY-MM-DD):" }
                                        TextField { id: startDateField; placeholderText: "2025-11-20" }

                                        Label { text: "Date de fin (YYYY-MM-DD):" }
                                        TextField { id: endDateField; placeholderText: "2025-11-21" }
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
                                // Force refresh when refreshTrigger changes
                                model: {
                                    refreshTrigger  // dependency
                                    var tasks = taskController.getTasksForProject(window.projectId)
                                    return tasks || []
                                }
                                
                                Rectangle {
                                    width: 150
                                    height: 30
                                    color: ganttMouseArea.containsMouse ? "lightblue" : "transparent"
                                    
                                    MouseArea {
                                        id: ganttMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        onClicked: {
                                            if (!modelData) return
                                            console.log("Opening task from Gantt:", modelData.nomTache)
                                            var component = Qt.createComponent("TaskDetailsView.qml")
                                            if (component.status === Component.Ready) {
                                                var taskWindow = component.createObject(null, {
                                                    taskId: modelData.idTache,
                                                    taskName: modelData.nomTache,
                                                    projectId: window.projectId,
                                                    taskController: window.taskController,
                                                    projectController: window.projectController
                                                })
                                                taskWindow.show()
                                            }
                                        }
                                    }
                                    
                                    Text { 
                                        text: modelData ? modelData.nomTache : ""
                                        anchors.centerIn: parent
                                    }
                                }
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
                                model: {
                                    refreshTrigger  // dependency
                                    var tasks = taskController.getTasksForProject(window.projectId)
                                    return tasks || []
                                }

                                Rectangle {
                                    x: 50
                                    y: index * 40
                                    width: 100
                                    height: 30
                                    color: ganttBarMouseArea.containsMouse ? "skyblue" : "lightblue"
                                    border.color: "black"
                                    
                                    MouseArea {
                                        id: ganttBarMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        onClicked: {
                                            if (!modelData) return
                                            var component = Qt.createComponent("TaskDetailsView.qml")
                                            if (component.status === Component.Ready) {
                                                var taskWindow = component.createObject(null, {
                                                    taskId: modelData.idTache,
                                                    taskName: modelData.nomTache,
                                                    projectId: window.projectId,
                                                    taskController: window.taskController,
                                                    projectController: window.projectController
                                                })
                                                taskWindow.show()
                                            }
                                        }
                                    }
                                    
                                    Text { 
                                        anchors.centerIn: parent
                                        text: modelData ? modelData.nomTache : ""
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}