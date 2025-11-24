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
    property int refreshTrigger: 0

    // Handle signal connections properly
    Connections {
        target: taskController
        
        function onTaskCreated(taskId) {
            console.log("Task created - refreshing")
            window.refreshTrigger++
        }
        
        function onTaskUpdated(taskId) {
            console.log("Task updated - refreshing")
            window.refreshTrigger++
        }
        
        function onTaskDeleted(taskId) {
            console.log("Task deleted - refreshing")
            window.refreshTrigger++
        }
    }
    
    Component.onCompleted: {
        console.log("MAIN3: loading tasks for project", projectId)
        taskController.loadTasksForProject(projectId)
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

                Repeater {
                    model: ["A faire", "En cours", "A Tester", "Termine"]

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

                                Text { 
                                    text: columnName
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter 
                                }

                                // === Tasks filtered by status ===
                                Repeater {
                                    model: {
                                        refreshTrigger
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
                                                console.log("Opening task:", modelData.nomTache)
    
                                                // Store the properties in local variables to avoid timing issues
                                                var taskId = modelData.idTache
                                                var taskName = modelData.nomTache
                                                var projectId = window.projectId
                                                var taskCtrl = window.taskController
                                                var projectCtrl = window.projectController
    
                                                console.log("Creating window with projectId:", projectId)
    
                                                var component = Qt.createComponent("TaskDetailsView.qml")
    
                                                if (component.status === Component.Ready) {
                                                    createTaskWindow()
                                                } else {
                                                    component.statusChanged.connect(createTaskWindow)
                                                }
    
                                                function createTaskWindow() {
                                                    if (component.status === Component.Ready) {
                                                        var taskWindow = component.createObject(null, {
                                                            taskId: taskId,
                                                            taskName: taskName,
                                                            projectId: projectId,
                                                            taskController: taskCtrl,
                                                            projectController: projectCtrl
                                                        })
                                                        if (taskWindow) {
                                                            taskWindow.show()
                                                        } else {
                                                            console.error("Failed to create task window")
                                                        }
                                                    } else {
                                                        console.error("Component failed to load:", component.errorString())
                                                    }
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

                                            // === Employee Status Change Button ===
                                            Button {
                                                id: taskEmployeeStatusButton
                                                text: "Changer Statut"
                                                visible: taskController && taskController.isEmployeeView && taskController.isEmployeeView() && 
                                                        taskController.canChangeStatus && taskController.canChangeStatus(modelData.idTache)
                                                height: 25
                                                width: parent.width * 0.8
                                                anchors.horizontalCenter: parent.horizontalCenter
            
                                                background: Rectangle {
                                                    color: taskEmployeeStatusButton.down ? "darkblue" : "blue"
                                                    radius: 4
                                                }
            
                                                contentItem: Text {
                                                    text: taskEmployeeStatusButton.text
                                                    color: "white"
                                                    font.pixelSize: 10
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }

                                                onClicked: {
                                                    console.log("Employee changing status for task:", modelData.idTache)
                                                    taskEmployeeStatusDialog.taskId = modelData.idTache
                                                    taskEmployeeStatusDialog.taskName = modelData.nomTache
                                                    taskEmployeeStatusDialog.currentStatus = columnName
                                                    taskEmployeeStatusDialog.open()
                                                }
                                            }
                                        }
                                    }
                                }

                                // === Button to add task - NO DIALOG HERE ===
                                Button {
                                    text: "+ Ajouter une tâche"
                                    visible: taskController && taskController.canCreateTask && 
                                            taskController.canCreateTask(window.projectId)
                                    onClicked: {
                                        // Set which column and open THE SHARED dialog
                                        addTaskDialog.currentColumn = columnName
                                        addTaskDialog.open()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ===== GANTT VIEW =====
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

                        Column {
                            spacing: 10
                            Repeater {
                                model: {
                                    refreshTrigger
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

                        Rectangle {
                            id: ganttChart
                            width: 700
                            height: 300
                            border.color: "black"
                            color: "transparent"

                            Repeater {
                                model: {
                                    refreshTrigger
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
    } // End StackLayout

    // ==========================================
    // SHARED DIALOGS - ONE INSTANCE EACH
    // ==========================================

    // Add Task Dialog - SHARED by all 4 Kanban columns
    Dialog {
        id: addTaskDialog
        title: "Créer une nouvelle tâche"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        width: 400

        property string currentColumn: ""

        onAboutToShow: {
            console.log("Opening task dialog for column:", currentColumn)
            taskNameField.text = ""
            descriptionField.text = ""
            assignedUserField.currentIndex = -1
            estimatedTimeField.text = "0"
            startDateField.text = new Date().toISOString().split('T')[0]
            endDateField.text = ""
        }

        onAccepted: {
            console.log("Creating task in column:", currentColumn)
            
            var assignedId = -1
            if (assignedUserField.currentIndex >= 0) {
                var employees = taskController.getAvailableEmployees()
                if (employees && employees.length > assignedUserField.currentIndex) {
                    assignedId = employees[assignedUserField.currentIndex].idEmploye
                }
            }

            if (!taskNameField.text) {
                console.error("Task name required")
                return
            }

            var success = taskController.createTask(
                window.projectId,
                taskNameField.text,
                descriptionField.text,
                0, // no parent
                assignedId,
                parseInt(estimatedTimeField.text || "0"),
                startDateField.text,
                endDateField.text,
                currentColumn
            )

            if (success) {
                console.log("Task created successfully")
                refreshTrigger++
            } else {
                console.log("Failed to create task")
            }
        }

        contentItem: ColumnLayout {
            spacing: 10

            Label { text: "Nom de la tâche:" }
            TextField { 
                id: taskNameField
                placeholderText: "Nouvelle tâche"
                Layout.fillWidth: true
            }

            Label { text: "Description:" }
            TextArea { 
                id: descriptionField
                placeholderText: "Description"
                Layout.fillWidth: true
                Layout.preferredHeight: 80
            }

            Label { text: "Assigné à:" }
            ComboBox {
                id: assignedUserField
                Layout.fillWidth: true
                model: taskController ? taskController.getAvailableEmployees() : []
                textRole: "fullName"
                currentIndex: -1
                displayText: currentIndex === -1 ? "Non assigné" : currentText
            }

            Label { text: "Temps estimé (heures):" }
            TextField { 
                id: estimatedTimeField
                placeholderText: "0"
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhDigitsOnly
            }

            Label { text: "Date de début (YYYY-MM-DD):" }
            TextField { 
                id: startDateField
                placeholderText: "2025-11-23"
                Layout.fillWidth: true
            }

            Label { text: "Date de fin (YYYY-MM-DD):" }
            TextField { 
                id: endDateField
                placeholderText: "2025-11-30"
                Layout.fillWidth: true
            }

            Label {
                text: "Statut: " + addTaskDialog.currentColumn
                font.italic: true
                color: "gray"
            }
        }
    }

    // === Employee Status Change Dialog for Tasks ===
    Dialog {
        id: taskEmployeeStatusDialog
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
        
            var statusList = ["A faire", "En cours", "A Tester", "Termine"]
            taskEmployeeStatusCombo.currentIndex = -1
            for (var i = 0; i < statusList.length; i++) {
                if (statusList[i] === currentStatus) {
                    taskEmployeeStatusCombo.currentIndex = i
                    break
                }
            }
        }

        onAccepted: {
            if (taskId === -1) {
                console.error("No task ID set for status change")
                return
            }

            console.log("Employee updating task status:", taskId, "to:", taskEmployeeStatusCombo.currentText)
        
            var success = taskController.updateTaskStatus(
                taskId,
                taskEmployeeStatusCombo.currentText
            )

            if (success) {
                console.log("Task status updated successfully")
                // Refresh the project view
                refreshTrigger++
            } else {
                console.log("Failed to update task status")
            }
        }

        contentItem: ColumnLayout {
            spacing: 15

            Label {
                text: "Tâche: " + taskEmployeeStatusDialog.taskName
                font.bold: true
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            Label {
                text: "Nouveau statut:"
                Layout.fillWidth: true
            }

            ComboBox {
                id: taskEmployeeStatusCombo
                Layout.fillWidth: true
                model: ["A faire", "En cours", "A Tester", "Termine"]
                Layout.preferredHeight: 40
            }

            Label {
                text: "Statut actuel: " + taskEmployeeStatusDialog.currentStatus
                font.italic: true
                color: "gray"
                Layout.fillWidth: true
            }
        }
    }

    // Edit Project Dialog
    Dialog {
        id: editProjectDialog
        title: "Modifier le projet"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        width: 400

        onAboutToShow: {
            var projectDetails = projectController.getProjectDetails(projectId)
            editProjectNameField.text = projectDetails.nomProject || ""
            editRepositoryField.text = projectDetails.tempRepository || ""
            editCostField.text = projectDetails.coutService ? projectDetails.coutService.toString() : "0.0"
            
            var clients = projectController.getClients()
            editClientCombo.model = clients
            
            editClientCombo.currentIndex = -1
            for (var i = 0; i < clients.length; i++) {
                if (clients[i].idClient === projectDetails.idClient) {
                    editClientCombo.currentIndex = i
                    break
                }
            }
        }

        onAccepted: {
            var success = projectController.updateProject(
                projectId,
                editProjectNameField.text,
                editRepositoryField.text,
                parseFloat(editCostField.text) || 0.0
            )

            if (success) {
                window.projectName = editProjectNameField.text
                window.title = editProjectNameField.text
            }
        }

        contentItem: ColumnLayout {
            spacing: 10

            Label { text: "Nom du projet:" }
            TextField {
                id: editProjectNameField
                Layout.fillWidth: true
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
            }

            Label { text: "Coût du service:" }
            TextField {
                id: editCostField
                Layout.fillWidth: true
            }
        }
    }

    // Delete Project Dialog
    Dialog {
        id: deleteProjectDialog
        title: "⚠️ Confirmer la suppression"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: parent

        Label {
            text: "Êtes-vous sûr de vouloir supprimer ce projet ?\n\n" +
                  "Projet: " + projectName + "\n\n" +
                  "⚠️ Cette action est irréversible!"
            wrapMode: Text.WordWrap
            width: 350
        }

        onAccepted: {
            var success = projectController.deleteProject(projectId)
            if (success) {
                window.close()
            }
        }
    }

} // End ApplicationWindow