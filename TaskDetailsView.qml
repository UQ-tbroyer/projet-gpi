import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 6.5
import QtQuick.Window 6.5

ApplicationWindow {
    id: taskWindow
    width: 1000
    height: 600
    visible: true
    title: taskName
    color: "white"

    property int taskId
    property string taskName
    property int projectId
    property var taskController
    property var projectController
    property int refreshTrigger: 0  // LOCAL refresh trigger
    property var parentWindow: null  // Reference to parent window

    Component.onCompleted: {
        console.log("TaskDetailsView: loading subtasks for task", taskId)
    
        // Connect to subtask changes for THIS task
        taskController.subTasksChanged.connect(function(parentId) {
            console.log("subTasksChanged received for parentId:", parentId, "current taskId:", taskId)
            if (parentId === taskId) {
                console.log("Refreshing subtasks for current task")
                refreshTrigger++
            }
        })
    
        // Connect to task updates
        taskController.taskUpdated.connect(function(updatedTaskId) {
            console.log("taskUpdated signal received for:", updatedTaskId)
            if (updatedTaskId === taskId) {
                console.log("Current task was updated, refreshing")
                refreshTrigger++
            } else {
                console.log("Different task updated, ignoring")
            }
        })
    
        // Also connect to any errors
        taskController.taskUpdateFailed.connect(function(errorMsg) {
            console.log("Task update failed:", errorMsg)
        })
    }

    // --- Top Bar ---
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        height: 70
        color: "transparent"

        Button {
            id: backButton
            text: "<- Retour"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                console.log("Closing task window")
                taskWindow.close()
            }
        }

        Column {
            spacing: 5
            anchors.centerIn: parent
            
            Text {
                text: "Tâche: " + taskName
                font.bold: true
                font.pointSize: 18
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Sous-tâches"
                font.pointSize: 12
                color: "gray"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // --- Task Actions Menu ---
        Row {
            spacing: 10
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Button {
                text: taskController && taskController.isEmployeeView && taskController.isEmployeeView() ? 
                        "✏️ Changer Statut" : "✏️ Modifier"
        
                // SIMPLIFIED VISIBILITY LOGIC - Allow employees to always change status
                visible: (taskController && taskController.canEditTask && taskController.canEditTask(taskId)) ||
                        (taskController && taskController.canChangeStatus && taskController.canChangeStatus(taskId))
        
                onClicked: {
                    taskController && taskController.isEmployeeView && taskController.isEmployeeView() ? 
                      statusEditTaskDialog.open() : editTaskDialog.open()
                }
            }

            Button {
                text: "🗑️ Supprimer"
                visible: taskController && taskController.canDeleteTask &&
                        taskController.canDeleteTask(taskId)
                onClicked: deleteTaskDialog.open()
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

        // ===== KANBAN VIEW =====
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

                                // === Subtasks filtered by status ===
                                Repeater {
                                    model: {
                                        refreshTrigger
                                        var allSubTasks = taskController.getSubTasks(taskWindow.taskId)
                                        var filtered = []
                                        for (var i = 0; i < allSubTasks.length; i++) {
                                            if (allSubTasks[i].etat === columnName) {
                                                filtered.push(allSubTasks[i])
                                            }
                                        }
                                        return filtered
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
                                                console.log("Opening subtask:", modelData.nomTache)
                                                var component = Qt.createComponent("TaskDetailsView.qml")
                                                if (component.status === Component.Ready) {
                                                    var window = component.createObject(null, {
                                                        taskId: modelData.idTache,
                                                        taskName: modelData.nomTache,
                                                        projectId: taskWindow.projectId,
                                                        taskController: taskWindow.taskController,
                                                        projectController: taskWindow.projectController,
                                                        parentWindow: taskWindow
                                                    })
                                                    window.show()
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
                                                id: subtaskEmployeeStatusButton
                                                text: "Changer Statut"
                                                visible: taskController && taskController.isEmployeeView && taskController.isEmployeeView() && 
                                                        taskController.canChangeStatus && taskController.canChangeStatus(modelData.idTache)
                                                height: 25
                                                width: parent.width * 0.8
                                                anchors.horizontalCenter: parent.horizontalCenter
            
                                                background: Rectangle {
                                                    color: subtaskEmployeeStatusButton.down ? "darkblue" : "blue"
                                                    radius: 4
                                                }
            
                                                contentItem: Text {
                                                    text: subtaskEmployeeStatusButton.text
                                                    color: "white"
                                                    font.pixelSize: 10
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }

                                                onClicked: {
                                                    console.log("Employee changing status for subtask:", modelData.idTache)
                                                    subtaskEmployeeStatusDialog.taskId = modelData.idTache
                                                    subtaskEmployeeStatusDialog.taskName = modelData.nomTache
                                                    subtaskEmployeeStatusDialog.currentStatus = columnName
                                                    subtaskEmployeeStatusDialog.open()
                                                }
                                            }
                                        }
                                    }
                                }

                                // === Add subtask button ===
                                Button {
                                    text: "+ Ajouter une sous-tâche"
                                    visible: taskController && taskController.canCreateTask && 
                                            taskController.canCreateTask(taskWindow.projectId)
                                    onClicked: {
                                        addSubTaskDialog.currentColumn = columnName
                                        addSubTaskDialog.open()
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
                                    return taskController.getSubTasks(taskWindow.taskId)
                                }
                                
                                Rectangle {
                                    width: 150
                                    height: 30
                                    color: ganttNameMouseArea.containsMouse ? "lightblue" : "transparent"
                                    
                                    MouseArea {
                                        id: ganttNameMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        onClicked: {
                                            var component = Qt.createComponent("TaskDetailsView.qml")
                                            if (component.status === Component.Ready) {
                                                var window = component.createObject(null, {
                                                    taskId: modelData.idTache,
                                                    taskName: modelData.nomTache,
                                                    projectId: taskWindow.projectId,
                                                    taskController: taskWindow.taskController,
                                                    projectController: taskWindow.projectController,
                                                    parentWindow: taskWindow
                                                })
                                                window.show()
                                            }
                                        }
                                    }
                                    
                                    Text { 
                                        text: modelData.nomTache
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
                                    return taskController.getSubTasks(taskWindow.taskId)
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
                                            var component = Qt.createComponent("TaskDetailsView.qml")
                                            if (component.status === Component.Ready) {
                                                var window = component.createObject(null, {
                                                    taskId: modelData.idTache,
                                                    taskName: modelData.nomTache,
                                                    projectId: taskWindow.projectId,
                                                    taskController: taskWindow.taskController,
                                                    projectController: taskWindow.projectController,
                                                    parentWindow: taskWindow
                                                })
                                                window.show()
                                            }
                                        }
                                    }
                                    
                                    Text { 
                                        anchors.centerIn: parent
                                        text: modelData.nomTache 
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // DIALOGS
    // ==========================================

    // Add SubTask Dialog
    Dialog {
        id: addSubTaskDialog
        title: "Créer une sous-tâche"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        width: 400

        property string currentColumn: ""

        onAboutToShow: {
            subTaskNameField.text = ""
            subTaskDescField.text = ""
            subTaskAssignedUserField.currentIndex = -1
            subTaskTimeField.text = "0"
            subTaskStartDateField.text = new Date().toISOString().split('T')[0]
            subTaskEndDateField.text = ""
        }

        onAccepted: {
            console.log("=== Creating subtask ===")
            console.log("Parent task ID:", taskWindow.taskId)
            console.log("Column (status):", currentColumn)
            console.log("Name:", subTaskNameField.text)
            console.log("Description:", subTaskDescField.text)
            console.log("Start date:", subTaskStartDateField.text)
            console.log("End date:", subTaskEndDateField.text)
            console.log("Time:", subTaskTimeField.text)
            
            if (!subTaskNameField.text) {
                console.error("ERROR: Task name is empty!")
                return
            }
            
            var assignedId = -1
            if (subTaskAssignedUserField.currentIndex >= 0) {
                var employees = taskController.getAvailableEmployees()
                console.log("Employees list length:", employees ? employees.length : 0)
                if (employees && employees.length > subTaskAssignedUserField.currentIndex) {
                    assignedId = employees[subTaskAssignedUserField.currentIndex].idEmploye
                    console.log("Assigned to employee ID:", assignedId)
                }
            } else {
                console.log("No employee assigned")
            }

            console.log("Calling createSubTask...")
            var success = taskController.createSubTask(
                taskWindow.taskId,
                subTaskNameField.text,
                subTaskDescField.text,
                assignedId,
                parseInt(subTaskTimeField.text || "0"),
                subTaskStartDateField.text,
                subTaskEndDateField.text,
                currentColumn
            )

            console.log("createSubTask returned:", success)
            if (success) {
                console.log("SubTask created successfully")
                refreshTrigger++
                
                // CLOSE THE WINDOW AFTER SUCCESSFUL CREATION
                console.log("Closing task window after subtask creation")
                taskWindow.close()
            } else {
                console.error("FAILED to create subtask")
            }
        }

        contentItem: ColumnLayout {
            spacing: 10

            Label { text: "Nom de la sous-tâche:" }
            TextField { 
                id: subTaskNameField
                placeholderText: "Nouvelle sous-tâche"
                Layout.fillWidth: true
            }

            Label { text: "Description:" }
            TextArea { 
                id: subTaskDescField
                placeholderText: "Description"
                Layout.fillWidth: true
                Layout.preferredHeight: 80
            }

            Label { text: "Assigné à:" }
            ComboBox {
                id: subTaskAssignedUserField
                Layout.fillWidth: true
                model: taskController ? taskController.getAvailableEmployees() : []
                textRole: "fullName"
                currentIndex: -1
            }

            Label { text: "Temps estimé (heures):" }
            TextField { 
                id: subTaskTimeField
                placeholderText: "0"
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhDigitsOnly
            }

            Label { text: "Date de début:" }
            TextField { 
                id: subTaskStartDateField
                placeholderText: "2025-11-23"
                Layout.fillWidth: true
            }

            Label { text: "Date de fin:" }
            TextField { 
                id: subTaskEndDateField
                placeholderText: "2025-11-30"
                Layout.fillWidth: true
            }
        }
    }

    // Edit Task Dialog (Full edit for Admin/Gestionnaire)
    Dialog {
        id: editTaskDialog
        title: "Modifier la tâche"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        width: 400

        onAboutToShow: {
            var taskDetails = taskController.getTaskDetails(taskId)
            console.log("Loading task details for edit:", JSON.stringify(taskDetails))
            
            editTaskNameField.text = taskDetails.nomTache || ""
            editTaskDescField.text = taskDetails.descTache || ""
            editTaskTimeField.text = taskDetails.tempsTache ? taskDetails.tempsTache.toString() : "0"
            editTaskStartDateField.text = taskDetails.dateDebut || ""
            editTaskEndDateField.text = taskDetails.dateFin || ""
            
            var statusList = ["A faire", "En cours", "A Tester", "Termine"]
            editTaskStatusCombo.currentIndex = -1
            for (var i = 0; i < statusList.length; i++) {
                if (statusList[i] === taskDetails.etat) {
                    editTaskStatusCombo.currentIndex = i
                    break
                }
            }
            
            var employees = taskController.getAvailableEmployees()
            editTaskAssignedCombo.model = employees
            editTaskAssignedCombo.currentIndex = -1
            
            for (var j = 0; j < employees.length; j++) {
                if (employees[j].idEmploye === taskDetails.memProcessigner) {
                    editTaskAssignedCombo.currentIndex = j
                    break
                }
            }
        }

        onAccepted: {
            var assignedId = -1
            if (editTaskAssignedCombo.currentIndex >= 0) {
                assignedId = editTaskAssignedCombo.model[editTaskAssignedCombo.currentIndex].idEmploye
            }

            console.log("Updating task", taskId)
            
            var success = taskController.updateTask(
                taskId,
                editTaskNameField.text,
                editTaskDescField.text,
                assignedId,
                editTaskTimeField.text,
                editTaskStartDateField.text,
                editTaskEndDateField.text,
                editTaskStatusCombo.currentText
            )

            if (success) {
                console.log("Task updated successfully")
                taskWindow.taskName = editTaskNameField.text
                taskWindow.title = editTaskNameField.text
                
                // Notify parent window if it exists
                if (taskWindow.parentWindow && typeof taskWindow.parentWindow.refreshTrigger !== 'undefined') {
                    taskWindow.parentWindow.refreshTrigger++
                }
                
                refreshTrigger++
                
                // CLOSE THE WINDOW AFTER SUCCESSFUL UPDATE
                console.log("Closing task window after update")
                taskWindow.close()
            }
        }

        contentItem: ColumnLayout {
            spacing: 10

            Label { text: "Nom:" }
            TextField {
                id: editTaskNameField
                Layout.fillWidth: true
            }

            Label { text: "Description:" }
            TextArea {
                id: editTaskDescField
                Layout.fillWidth: true
                Layout.preferredHeight: 80
            }

            Label { text: "Assigné à:" }
            ComboBox {
                id: editTaskAssignedCombo
                Layout.fillWidth: true
                textRole: "fullName"
            }

            Label { text: "Temps estimé (heures):" }
            TextField {
                id: editTaskTimeField
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhDigitsOnly
            }

            Label { text: "Date début:" }
            TextField {
                id: editTaskStartDateField
                Layout.fillWidth: true
            }

            Label { text: "Date fin:" }
            TextField {
                id: editTaskEndDateField
                Layout.fillWidth: true
            }

            Label { text: "Statut:" }
            ComboBox {
                id: editTaskStatusCombo
                Layout.fillWidth: true
                model: ["A faire", "En cours", "A Tester", "Termine"]
            }
        }
    }

    // Status-only Edit Dialog (for Employees)
    Dialog {
        id: statusEditTaskDialog
        title: "Modifier le statut"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        width: 300

        onAboutToShow: {
            var taskDetails = taskController.getTaskDetails(taskId)
            
            var statusList = ["A faire", "En cours", "A Tester", "Termine"]
            statusEditTaskStatusCombo.currentIndex = -1
            for (var i = 0; i < statusList.length; i++) {
                if (statusList[i] === taskDetails.etat) {
                    statusEditTaskStatusCombo.currentIndex = i
                    break
                }
            }
        }

        onAccepted: {
            console.log("Updating task status:", taskId)
            
            var success = taskController.updateTaskStatus(
                taskId,
                statusEditTaskStatusCombo.currentText
            )

            if (success) {
                console.log("Status updated")
                
                if (taskWindow.parentWindow && typeof taskWindow.parentWindow.refreshTrigger !== 'undefined') {
                    taskWindow.parentWindow.refreshTrigger++
                }
                
                refreshTrigger++
                
                // CLOSE THE WINDOW AFTER SUCCESSFUL STATUS UPDATE
                console.log("Closing task window after status update")
                taskWindow.close()
            }
        }

        contentItem: ColumnLayout {
            spacing: 15

            Label { 
                text: "Nouveau statut:"
                font.bold: true
            }
            
            ComboBox {
                id: statusEditTaskStatusCombo
                Layout.fillWidth: true
                model: ["A faire", "En cours", "A Tester", "Termine"]
            }
        }
    }

    // Delete Task Dialog
    Dialog {
        id: deleteTaskDialog
        title: "⚠️ Confirmer la suppression"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: parent

        Label {
            text: "Supprimer cette tâche ?\n\n" +
                  "Tâche: " + taskName + "\n\n" +
                  "⚠️ Toutes les sous-tâches seront aussi supprimées!"
            wrapMode: Text.WordWrap
            width: 350
        }

        onAccepted: {
            console.log("Deleting task:", taskId)
            var success = taskController.deleteTask(taskId)
            if (success) {
                if (taskWindow.parentWindow && typeof taskWindow.parentWindow.refreshTrigger !== 'undefined') {
                    taskWindow.parentWindow.refreshTrigger++
                }
                // CLOSE THE WINDOW AFTER SUCCESSFUL DELETION
                taskWindow.close()
            }
        }
    }

    // === Employee Status Change Dialog for Subtasks ===
    Dialog {
        id: subtaskEmployeeStatusDialog
        title: "Changer le statut de la sous-tâche"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        width: 350

        property int taskId: -1
        property string taskName: ""
        property string currentStatus: ""

        onAboutToShow: {
            console.log("Opening status dialog for subtask:", taskId, "Current status:", currentStatus)
        
            var statusList = ["A faire", "En cours", "A Tester", "Termine"]
            subtaskEmployeeStatusCombo.currentIndex = -1
            for (var i = 0; i < statusList.length; i++) {
                if (statusList[i] === currentStatus) {
                    subtaskEmployeeStatusCombo.currentIndex = i
                    break
                }
            }
        }

        onAccepted: {
            if (taskId === -1) {
                console.error("No subtask ID set for status change")
                return
            }

            console.log("Employee updating subtask status:", taskId, "to:", subtaskEmployeeStatusCombo.currentText)
        
            var success = taskController.updateTaskStatus(
                taskId,
                subtaskEmployeeStatusCombo.currentText
            )

            if (success) {
                console.log("Subtask status updated successfully")
                // Refresh the subtasks view
                refreshTrigger++
            
                // Also notify parent window if it exists
                if (taskWindow.parentWindow && taskWindow.parentWindow.refreshTrigger !== undefined) {
                    taskWindow.parentWindow.refreshTrigger++
                }
                
                // CLOSE THE WINDOW AFTER SUCCESSFUL STATUS CHANGE
                console.log("Closing task window after subtask status update")
                taskWindow.close()
            } else {
                console.log("Failed to update subtask status")
            }
        }

        contentItem: ColumnLayout {
            spacing: 15

            Label {
                text: "Sous-tâche: " + subtaskEmployeeStatusDialog.taskName
                font.bold: true
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            Label {
                text: "Nouveau statut:"
                Layout.fillWidth: true
            }

            ComboBox {
                id: subtaskEmployeeStatusCombo
                Layout.fillWidth: true
                model: ["A faire", "En cours", "A Tester", "Termine"]
                Layout.preferredHeight: 40
            }

            Label {
                text: "Statut actuel: " + subtaskEmployeeStatusDialog.currentStatus
                font.italic: true
                color: "gray"
                Layout.fillWidth: true
            }
        }
    }
}