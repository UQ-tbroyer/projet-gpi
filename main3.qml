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
                            width: 220  // Increased width to accommodate button
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
                                    model: {
                                        refreshTrigger  // dependency
                                        return taskController.getTasksForProjectByStatus(window.projectId, columnName)
                                    }
                            
                                    delegate: Rectangle {
                                        width: parent.width - 20
                                        height: taskController && taskController.isEmployeeView && taskController.isEmployeeView() ? 90 : 60
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
                                            width: parent.width - 10

                                            Text { 
                                                text: modelData.nomTache
                                                font.bold: true
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                width: parent.width
                                                wrapMode: Text.Wrap
                                                maximumLineCount: 2
                                                elide: Text.ElideRight
                                            }
                                            Text { 
                                                text: "Assigné: " + (modelData.assigneeName || "Non assigné")
                                                font.pixelSize: 10
                                                color: "gray"
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            // === Status Change Button for Employees ===
                                            Button {
                                                id: employeeStatusButton
                                                text: "Changer Statut"
                                                visible: taskController && taskController.isEmployeeView && taskController.isEmployeeView() && 
                                                        taskController.canChangeStatus && taskController.canChangeStatus(modelData.idTache)
                                                height: 25
                                                width: parent.width * 0.8
                                                anchors.horizontalCenter: parent.horizontalCenter
                                        
                                                background: Rectangle {
                                                    color: employeeStatusButton.down ? "darkblue" : "blue"
                                                    radius: 4
                                                }
                                        
                                                contentItem: Text {
                                                    text: employeeStatusButton.text
                                                    color: "white"
                                                    font.pixelSize: 10
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }

                                                onClicked: {
                                                    console.log("Employee changing status for task:", modelData.idTache)
                                                    employeeStatusDialog.taskId = modelData.idTache
                                                    employeeStatusDialog.taskName = modelData.nomTache
                                                    employeeStatusDialog.currentStatus = columnName
                                                    employeeStatusDialog.open()
                                                }
                                            }
                                        }
                                    }
                                }

                                // === Add new task ===
                                Button {
                                    text: "+ Ajouter une tâche"
                                    visible: projectController && projectController.canDeleteProject && 
                                        projectController.canDeleteProject(projectId)
                                    onClicked: {
                                        addTaskDialog.currentColumn = columnName;
                                        addTaskDialog.open()
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
    Dialog {
        id: employeeStatusDialog
        title: "Changer le statut de la tâche"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        width: 350

        property int taskId: -1
        property string taskName: ""
        property string currentStatus: ""

        onAboutToShow: {
            console.log("Opening status dialog for task:", taskId, "Current status:", currentStatus)
        
            var statusList = ["A faire", "En cours", "A tester", "Terminee"]
            employeeStatusCombo.currentIndex = -1
            for (var i = 0; i < statusList.length; i++) {
                if (statusList[i] === currentStatus) {
                    employeeStatusCombo.currentIndex = i
                    break
                }
            }
        }

        onAccepted: {
            if (taskId === -1) {
                console.error("No task ID set for status change")
                return
            }

            console.log("Employee updating task status:", taskId, "to:", employeeStatusCombo.currentText)
        
            var success = taskController.updateTaskStatus(
                taskId,
                employeeStatusCombo.currentText
            )

            if (success) {
                console.log("Task status updated successfully")
                // Refresh the view
                refreshTrigger++
            } else {
                console.log("Failed to update task status")
            }
        }

        contentItem: ColumnLayout {
            spacing: 15

            Label {
                text: "Tâche: " + employeeStatusDialog.taskName
                font.bold: true
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            Label {
                text: "Nouveau statut:"
                Layout.fillWidth: true
            }

            ComboBox {
                id: employeeStatusCombo
                Layout.fillWidth: true
                model: ["A faire", "En cours", "A tester", "Terminee"]
                Layout.preferredHeight: 40
            }

            Label {
                text: "Statut actuel: " + employeeStatusDialog.currentStatus
                font.italic: true
                color: "gray"
                Layout.fillWidth: true
            }
        }
    }
}