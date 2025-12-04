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
    property int refreshTrigger: 0
    property var parentWindow: null

    Component.onCompleted: {
        console.log("TaskDetailsView: loading subtasks for task", taskId)
        
        // Connect to subtask changes for THIS task (for subtask creation)
        taskController.subTasksChanged.connect(function(parentId) {
            console.log("subTasksChanged received for parentId:", parentId, "current taskId:", taskId)
            if (parentId === taskId) {
                console.log("Refreshing subtasks for current task")
                refreshTrigger++
            }
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
            onClicked: taskWindow.close()
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
                visible: (taskController && taskController.canEditTask && taskController.canEditTask(taskId)) ||
                        (taskController && taskController.canChangeStatus && taskController.canChangeStatus(taskId))
                onClicked:  taskController && taskController.isEmployeeView && taskController.isEmployeeView() ? 
                      statusEditTaskDialog.open() : editTaskDialog.open()
            }

            Button {
                text: "🗑️ Supprimer"
                visible: taskController && taskController.canDeleteTask &&
                        taskController.canDeleteTask(taskId)
                onClicked: deleteTaskDialog.open()
            }
        }
    }

    // --- Edit Task Dialog ---
    Dialog {
        id: editTaskDialog
        title: "Modifier la tâche"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        width: 400

        onAboutToShow: {
            var taskDetails = taskController.getTaskDetails(taskId)
            console.log("Loading task details for edit")
            
            editTaskNameField.text = taskDetails.nomTache || ""
            editTaskDescField.text = taskDetails.descTache || ""
            editTaskTimeField.text = taskDetails.tempsTache ? taskDetails.tempsTache.toString() : "0"
            editTaskStartDateField.text = taskDetails.dateDebut || ""
            editTaskEndDateField.text = taskDetails.dateFin || ""
            
            var statusList = ["A faire", "En cours", "A tester", "Terminee"]
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
                console.log("Task update completed - closing window")
                
                // Update window title immediately
                taskWindow.taskName = editTaskNameField.text
                taskWindow.title = editTaskNameField.text
                
                // Notify parent window to refresh
                if (taskWindow.parentWindow && taskWindow.parentWindow.refreshTrigger !== undefined) {
                    taskWindow.parentWindow.refreshTrigger++
                }
                
                // Close this window after a short delay to ensure everything is saved
                //closeTimer.start()
                taskWindow.close()
            } else {
                console.log("Failed to update task")
            }
        }

        contentItem: ColumnLayout {
            spacing: 10

            Label { text: "Nom de la tâche:" }
            TextField {
                id: editTaskNameField
                Layout.fillWidth: true
                placeholderText: "Nom de la tâche"
            }

            Label { text: "Description:" }
            TextArea {
                id: editTaskDescField
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                placeholderText: "Description"
            }

            Label { text: "Assigné à:" }
            ComboBox {
                id: editTaskAssignedCombo
                Layout.fillWidth: true
                textRole: "fullName"
            }

            Label { text: "Temps estimé (minutes):" }
            TextField {
                id: editTaskTimeField
                Layout.fillWidth: true
                placeholderText: "0"
                inputMethodHints: Qt.ImhDigitsOnly
            }

            Label { text: "Date de début (YYYY-MM-DD):" }
            TextField {
                id: editTaskStartDateField
                Layout.fillWidth: true
                placeholderText: "2025-11-20"
            }

            Label { text: "Date de fin (YYYY-MM-DD):" }
            TextField {
                id: editTaskEndDateField
                Layout.fillWidth: true
                placeholderText: "2025-11-21"
            }

            Label { text: "Statut:" }
            ComboBox {
                id: editTaskStatusCombo
                Layout.fillWidth: true
                model: ["A faire", "En cours", "A tester", "Terminee"]
            }
        }
    }
    Dialog {
    id: statusEditTaskDialog
    title: "Modifier le statut de la tâche"  // Better title
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel
    anchors.centerIn: parent
    width: 300  // Smaller width for status-only dialog

    onAboutToShow: {
        var taskDetails = taskController.getTaskDetails(taskId)
        console.log("Loading task status for edit")
        
        var statusList = ["A faire", "En cours", "A tester", "Terminee"]
        statusEditTaskStatusCombo.currentIndex = -1
        for (var i = 0; i < statusList.length; i++) {
            if (statusList[i] === taskDetails.etat) {
                statusEditTaskStatusCombo.currentIndex = i
                break
            }
        }
    }

    onAccepted: {
        console.log("Updating task status for task:", taskId)
        
        var success = taskController.updateTaskStatus(
            taskId,
            statusEditTaskStatusCombo.currentText  // FIXED: Use correct ID
        )

        if (success) {
            console.log("Task status updated successfully")
            
            // Update window title if needed
            taskWindow.title = taskName + " - " + statusEditTaskStatusCombo.currentText
            
            // Notify parent window to refresh
            if (taskWindow.parentWindow && taskWindow.parentWindow.refreshTrigger !== undefined) {
                taskWindow.parentWindow.refreshTrigger++
            }
            
            // Refresh current window
            taskWindow.refreshTrigger++
            
            taskWindow.close()
        } else {
            console.log("Failed to update task status")
        }
    }

    contentItem: ColumnLayout {
        spacing: 15
        width: parent.width

        Label { 
            text: "Nouveau statut:"
            font.bold: true
            Layout.alignment: Qt.AlignCenter
        }
        
        ComboBox {
            id: statusEditTaskStatusCombo
            Layout.fillWidth: true
            model: ["A faire", "En cours", "A tester", "Terminee"]
            Layout.preferredHeight: 40
        }
    }
}

    // Timer to close window after successful modification
    Timer {
        id: closeTimer
        interval: 50  // Short delay to ensure everything is saved
        onTriggered: {
            console.log("Closing task window after successful modification")
            taskWindow.close()
        }
    }

    // --- Delete Task Confirmation Dialog ---
    Dialog {
        id: deleteTaskDialog
        title: "⚠️ Confirmer la suppression"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: parent

        Label {
            text: "Êtes-vous sûr de vouloir supprimer cette tâche ?\n\n" +
                  "Tâche: " + taskName + "\n\n" +
                  "⚠️ Cette action est irréversible et supprimera toutes les sous-tâches associées!"
            wrapMode: Text.WordWrap
            width: 350
        }

        onAccepted: {
            console.log("Deleting task:", taskId)
            var success = taskController.deleteTask(taskId)
            if (success) {
                console.log("Task deleted successfully")
                if (taskWindow.parentWindow && taskWindow.parentWindow.refreshTrigger !== undefined) {
                    taskWindow.parentWindow.refreshTrigger++
                }
                taskWindow.close()
            } else {
                console.log("Failed to delete task")
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

                // Kanban columns
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

                                   // In TaskDetailsView.qml - Kanban section
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

                                // === Add new subtask ===
                                Button {
                                    text: "+ Ajouter une sous-tâche"

                                    visible: taskController && taskController.canDeleteTask && 
                                        taskController.canDeleteTask(taskId)

                                    onClicked: {
                                        addSubTaskDialog.currentColumn = columnName
                                        addSubTaskDialog.open()
                                    }
                                }
                                
                                Dialog {
                                    id: addSubTaskDialog
                                    title: "Créer une nouvelle sous-tâche"
                                    modal: true
                                    standardButtons: Dialog.Ok | Dialog.Cancel

                                    property string currentColumn: ""

                                    onAccepted: {
                                        console.log("Creating subtask in column:", currentColumn)
                                        
                                        var assignedId = -1
                                        if (assignedUserField.currentIndex >= 0) {
                                            var employees = taskController.getAvailableEmployees()
                                            assignedId = employees[assignedUserField.currentIndex].idEmploye
                                        }

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

                                        if (success) {
                                            console.log("SubTask created successfully")
                                            // Just refresh the current view - DON'T close the window
                                            refreshTrigger++
                                        } else {
                                            console.log("Erreur création sous-tâche")
                                        }
                                    }

                                    contentItem: ColumnLayout {
                                        spacing: 10
                                        width: 300

                                        Label { text: "Nom de la sous-tâche:" }
                                        TextField { 
                                            id: subTaskNameField
                                            placeholderText: "Nouvelle sous-tâche" 
                                        }

                                        Label { text: "Description:" }
                                        TextArea { 
                                            id: subTaskDescField
                                            placeholderText: "Description"
                                            height: 80 
                                        }

                                        Label { text: "Assigné à:" }
                                        ComboBox {
                                            id: assignedUserField
                                            model: taskController.getAvailableEmployees()
                                            textRole: "fullName"
                                            currentIndex: -1
                                        }

                                        Label { text: "Temps estimé (minutes):" }
                                        TextField { 
                                            id: subTaskTimeField
                                            placeholderText: "10"
                                            inputMethodHints: Qt.ImhDigitsOnly 
                                        }

                                        Label { text: "Date de début (YYYY-MM-DD):" }
                                        TextField { 
                                            id: subTaskStartDateField
                                            placeholderText: "2025-11-20" 
                                        }

                                        Label { text: "Date de fin (YYYY-MM-DD):" }
                                        TextField { 
                                            id: subTaskEndDateField
                                            placeholderText: "2025-11-21" 
                                        }
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

                        // SubTask names
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

                        // Gantt bars
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
        
            var statusList = ["A faire", "En cours", "A tester", "Terminee"]
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
                model: ["A faire", "En cours", "A tester", "Terminee"]
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