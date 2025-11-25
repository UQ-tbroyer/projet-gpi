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

    // Gantt calculation properties
    property date ganttStartDate
    property date ganttEndDate
    property int ganttTotalDays: 0
    property var ganttMonths: []

    Component.onCompleted: {
        console.log("TaskDetailsView: loading subtasks for task", taskId)
    
        taskController.subTasksChanged.connect(function(parentId) {
            if (parentId === taskId) {
                console.log("Refreshing subtasks for current task")
                refreshTrigger++
            }
        })
    
        taskController.taskUpdated.connect(function(updatedTaskId) {
            if (updatedTaskId === taskId) {
                console.log("Current task was updated, refreshing")
                refreshTrigger++
            }
        })
    
        taskController.taskUpdateFailed.connect(function(errorMsg) {
            console.log("Task update failed:", errorMsg)
        })
    }

    // JavaScript functions for Gantt calculations
    function calculateGanttTimeline(tasks) {
        if (!tasks || tasks.length === 0) {
            ganttStartDate = new Date()
            ganttEndDate = new Date()
            ganttTotalDays = 30
            ganttMonths = []
            return
        }

        var dates = []
        for (var i = 0; i < tasks.length; i++) {
            if (tasks[i].dateDebut) dates.push(new Date(tasks[i].dateDebut))
            if (tasks[i].dateFin) dates.push(new Date(tasks[i].dateFin))
        }

        if (dates.length === 0) {
            ganttStartDate = new Date()
            ganttEndDate = new Date()
            ganttTotalDays = 30
            ganttMonths = []
            return
        }

        var minDate = new Date(Math.min.apply(null, dates))
        var maxDate = new Date(Math.max.apply(null, dates))
        
        minDate.setDate(minDate.getDate() - 7)
        maxDate.setDate(maxDate.getDate() + 7)
        
        ganttStartDate = minDate
        ganttEndDate = maxDate
        ganttTotalDays = Math.ceil((maxDate - minDate) / (1000 * 60 * 60 * 24))
        
        var monthsList = []
        var current = new Date(minDate)
        while (current <= maxDate) {
            monthsList.push({
                name: Qt.formatDate(current, "MMM yyyy"),
                month: current.getMonth(),
                year: current.getFullYear()
            })
            current.setMonth(current.getMonth() + 1)
        }
        ganttMonths = monthsList
    }

    function calculateTaskPosition(task) {
        if (!task.dateDebut || !task.dateFin || ganttTotalDays === 0) {
            return { left: 0, width: 50 }
        }

        var taskStart = new Date(task.dateDebut)
        var taskEnd = new Date(task.dateFin)
        
        var daysFromStart = Math.floor((taskStart - ganttStartDate) / (1000 * 60 * 60 * 24))
        var taskDuration = Math.ceil((taskEnd - taskStart) / (1000 * 60 * 60 * 24)) + 1
        
        var left = (daysFromStart / ganttTotalDays) * 100
        var width = (taskDuration / ganttTotalDays) * 100
        
        return { left: Math.max(0, left), width: Math.max(2, width) }
    }

    function getStatusColor(status) {
        switch(status) {
            case "Termine": return "#10b981"
            case "En cours": return "#3b82f6"
            case "A Tester": return "#f59e0b"
            case "A faire": return "#9ca3af"
            default: return "#9ca3af"
        }
    }

    function buildTaskHierarchy(tasks) {
        var sortedTasks = tasks.slice().sort(function(a, b) {
            return new Date(a.dateDebut) - new Date(b.dateDebut)
        })
        return sortedTasks
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

        Row {
            spacing: 10
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Button {
                text: taskController && taskController.isEmployeeView && taskController.isEmployeeView() ? 
                        "✏️ Changer Statut" : "✏️ Modifier"
        
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
                                                    subtaskEmployeeStatusDialog.taskId = modelData.idTache
                                                    subtaskEmployeeStatusDialog.taskName = modelData.nomTache
                                                    subtaskEmployeeStatusDialog.currentStatus = columnName
                                                    subtaskEmployeeStatusDialog.open()
                                                }
                                            }
                                        }
                                    }
                                }

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

        // ===== REAL GANTT VIEW =====
        Item {
            id: ganttView
            
            property var allSubTasks: {
                refreshTrigger
                return taskController.getSubTasks(taskWindow.taskId) || []
            }
            
            property var sortedSubTasks: {
                var tasks = ganttView.allSubTasks
                calculateGanttTimeline(tasks)
                return buildTaskHierarchy(tasks)
            }

            Flickable {
                anchors.fill: parent
                contentWidth: ganttContent.width
                contentHeight: ganttContent.height
                clip: true

                Column {
                    id: ganttContent
                    width: Math.max(parent.width, 1200)
                    spacing: 0

                    // Header
                    Rectangle {
                        width: parent.width
                        height: 80
                        color: "#f3f4f6"
                        border.color: "#d1d5db"
                        border.width: 1

                        Row {
                            anchors.fill: parent

                            // Task names column header
                            Rectangle {
                                width: 250
                                height: parent.height
                                color: "#e5e7eb"
                                border.color: "#d1d5db"
                                border.width: 1

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 5

                                    Text {
                                        text: "Sous-tâches"
                                        font.bold: true
                                        font.pixelSize: 14
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }

                            // Timeline header
                            Item {
                                width: parent.width - 250
                                height: parent.height

                                // Month headers
                                Row {
                                    anchors.fill: parent
                                    Repeater {
                                        model: ganttMonths
                                        Rectangle {
                                            width: ganttMonths.length > 0 ? (parent.width / ganttMonths.length) : 100
                                            height: parent.height
                                            color: index % 2 === 0 ? "#f9fafb" : "#f3f4f6"
                                            border.color: "#d1d5db"
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.name
                                                font.bold: true
                                                font.pixelSize: 12
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Task rows with Gantt bars
                    Repeater {
                        model: ganttView.sortedSubTasks

                        Rectangle {
                            width: ganttContent.width
                            height: 40
                            color: index % 2 === 0 ? "white" : "#f9fafb"
                            border.color: "#e5e7eb"
                            border.width: 1

                            Row {
                                anchors.fill: parent

                                // Task name
                                Rectangle {
                                    width: 250
                                    height: parent.height
                                    color: "transparent"
                                    border.color: "#e5e7eb"
                                    border.width: 1

                                    MouseArea {
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

                                        Rectangle {
                                            anchors.fill: parent
                                            color: parent.containsMouse ? "#e0f2fe" : "transparent"
                                            
                                            Row {
                                                anchors.left: parent.left
                                                anchors.leftMargin: 10
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 5

                                                Text {
                                                    text: "•"
                                                    font.pixelSize: 10
                                                    color: "#6b7280"
                                                }

                                                Column {
                                                    spacing: 2

                                                    Text {
                                                        text: modelData.nomTache
                                                        font.bold: true
                                                        font.pixelSize: 12
                                                        elide: Text.ElideRight
                                                        width: 200
                                                    }

                                                    Text {
                                                        text: modelData.assigneeName || "Non assigné"
                                                        font.pixelSize: 9
                                                        color: "#6b7280"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // Gantt bar
                                Item {
                                    width: parent.width - 250
                                    height: parent.height

                                    // Vertical grid lines
                                    Repeater {
                                        model: ganttMonths.length
                                        Rectangle {
                                            x: ganttMonths.length > 0 ? (index / ganttMonths.length) * parent.width : 0
                                            width: 1
                                            height: parent.height
                                            color: "#e5e7eb"
                                        }
                                    }

                                    // Task bar
                                    Rectangle {
                                        property var pos: calculateTaskPosition(modelData)
                                        x: (pos.left / 100) * parent.width
                                        width: (pos.width / 100) * parent.width
                                        height: 24
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: getStatusColor(modelData.etat)
                                        radius: 4
                                        border.color: Qt.darker(color, 1.2)
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.nomTache
                                            color: "white"
                                            font.pixelSize: 10
                                            font.bold: true
                                            elide: Text.ElideRight
                                            width: parent.width - 8
                                            horizontalAlignment: Text.AlignHCenter
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            
                                            ToolTip {
                                                visible: parent.containsMouse
                                                text: modelData.nomTache + "\n" + 
                                                      modelData.dateDebut + " → " + modelData.dateFin + "\n" +
                                                      "Statut: " + modelData.etat
                                                delay: 500
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Legend
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: "#f9fafb"
                        border.color: "#e5e7eb"
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 20

                            Repeater {
                                model: [
                                    { status: "A faire", color: "#9ca3af" },
                                    { status: "En cours", color: "#3b82f6" },
                                    { status: "A Tester", color: "#f59e0b" },
                                    { status: "Terminé", color: "#10b981" }
                                ]

                                Row {
                                    spacing: 5
                                    Rectangle {
                                        width: 20
                                        height: 12
                                        color: modelData.color
                                        radius: 2
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.status
                                        font.pixelSize: 11
                                        anchors.verticalCenter: parent.verticalCenter
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
            if (!subTaskNameField.text) {
                return
            }
            
            var assignedId = -1
            if (subTaskAssignedUserField.currentIndex >= 0) {
                var employees = taskController.getAvailableEmployees()
                if (employees && employees.length > subTaskAssignedUserField.currentIndex) {
                    assignedId = employees[subTaskAssignedUserField.currentIndex].idEmploye
                }
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
                refreshTrigger++
                taskWindow.close()
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
                taskWindow.taskName = editTaskNameField.text
                taskWindow.title = editTaskNameField.text
                
                if (taskWindow.parentWindow && typeof taskWindow.parentWindow.refreshTrigger !== 'undefined') {
                    taskWindow.parentWindow.refreshTrigger++
                }
                
                refreshTrigger++
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
            var success = taskController.updateTaskStatus(
                taskId,
                statusEditTaskStatusCombo.currentText
            )

            if (success) {
                if (taskWindow.parentWindow && typeof taskWindow.parentWindow.refreshTrigger !== 'undefined') {
                    taskWindow.parentWindow.refreshTrigger++
                }
                
                refreshTrigger++
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
            var success = taskController.deleteTask(taskId)
            if (success) {
                if (taskWindow.parentWindow && typeof taskWindow.parentWindow.refreshTrigger !== 'undefined') {
                    taskWindow.parentWindow.refreshTrigger++
                }
                taskWindow.close()
            }
        }
    }

    // Employee Status Change Dialog for Subtasks
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
                return
            }
        
            var success = taskController.updateTaskStatus(
                taskId,
                subtaskEmployeeStatusCombo.currentText
            )

            if (success) {
                refreshTrigger++
            
                if (taskWindow.parentWindow && taskWindow.parentWindow.refreshTrigger !== undefined) {
                    taskWindow.parentWindow.refreshTrigger++
                }
                
                taskWindow.close()
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