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

    // Gantt calculation properties
    property date ganttStartDate
    property date ganttEndDate
    property int ganttTotalDays: 0
    property var ganttMonths: []

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
        
        // Add padding
        minDate.setDate(minDate.getDate() - 7)
        maxDate.setDate(maxDate.getDate() + 7)
        
        ganttStartDate = minDate
        ganttEndDate = maxDate
        ganttTotalDays = Math.ceil((maxDate - minDate) / (1000 * 60 * 60 * 24))
        
        // Generate months
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
        var parentTasks = []
        var taskMap = {}
        
        // Create task map
        for (var i = 0; i < tasks.length; i++) {
            taskMap[tasks[i].idTache] = Object.assign({}, tasks[i])
            taskMap[tasks[i].idTache].children = []
        }
        
        // Build hierarchy
        for (var id in taskMap) {
            var task = taskMap[id]
            if (task.idParentTache === 0) {
                parentTasks.push(task)
            } else if (taskMap[task.idParentTache]) {
                taskMap[task.idParentTache].children.push(task)
            }
        }
        
        // Sort by start date
        parentTasks.sort(function(a, b) {
            return new Date(a.dateDebut) - new Date(b.dateDebut)
        })
        
        for (var j = 0; j < parentTasks.length; j++) {
            parentTasks[j].children.sort(function(a, b) {
                return new Date(a.dateDebut) - new Date(b.dateDebut)
            })
        }
        
        return parentTasks
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
    
                                                var taskId = modelData.idTache
                                                var taskName = modelData.nomTache
                                                var projectId = window.projectId
                                                var taskCtrl = window.taskController
                                                var projectCtrl = window.projectController
    
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
                                                        }
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
                                                    taskEmployeeStatusDialog.taskId = modelData.idTache
                                                    taskEmployeeStatusDialog.taskName = modelData.nomTache
                                                    taskEmployeeStatusDialog.currentStatus = columnName
                                                    taskEmployeeStatusDialog.open()
                                                }
                                            }
                                        }
                                    }
                                }

                                Button {
                                    text: "+ Ajouter une tâche"
                                    visible: taskController && taskController.canCreateTask && 
                                            taskController.canCreateTask(window.projectId)
                                    onClicked: {
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

        // ===== REAL GANTT VIEW =====
        Item {
            id: ganttView
            
            property var allTasks: {
                refreshTrigger
                return taskController.getTasksForProject(window.projectId) || []
            }
            
            property var taskHierarchy: {
                var tasks = ganttView.allTasks
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
                                        text: "Tâches"
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
                                            width: (parent.width / ganttMonths.length)
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
                        model: ganttView.taskHierarchy

                        Column {
                            width: ganttContent.width
                            spacing: 0

                            // Parent task row
                            Rectangle {
                                width: parent.width
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

                                            Rectangle {
                                                anchors.fill: parent
                                                color: parent.containsMouse ? "#e0f2fe" : "transparent"
                                                
                                                Row {
                                                    anchors.left: parent.left
                                                    anchors.leftMargin: 10
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    spacing: 5

                                                    Text {
                                                        text: modelData.children.length > 0 ? "▼" : "•"
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
                                                x: (index / ganttMonths.length) * parent.width
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

                            // Child tasks
                            Repeater {
                                model: modelData.children

                                Rectangle {
                                    width: ganttContent.width
                                    height: 35
                                    color: "white"
                                    border.color: "#e5e7eb"
                                    border.width: 1

                                    Row {
                                        anchors.fill: parent

                                        // Task name (indented)
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

                                                Rectangle {
                                                    anchors.fill: parent
                                                    color: parent.containsMouse ? "#fef3c7" : "transparent"
                                                    
                                                    Row {
                                                        anchors.left: parent.left
                                                        anchors.leftMargin: 30
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        spacing: 5

                                                        Text {
                                                            text: "└"
                                                            font.pixelSize: 10
                                                            color: "#9ca3af"
                                                        }

                                                        Column {
                                                            spacing: 2

                                                            Text {
                                                                text: modelData.nomTache
                                                                font.pixelSize: 11
                                                                elide: Text.ElideRight
                                                                width: 180
                                                            }

                                                            Text {
                                                                text: modelData.assigneeName || "Non assigné"
                                                                font.pixelSize: 8
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
                                                    x: (index / ganttMonths.length) * parent.width
                                                    width: 1
                                                    height: parent.height
                                                    color: "#f3f4f6"
                                                }
                                            }

                                            // Task bar
                                            Rectangle {
                                                property var pos: calculateTaskPosition(modelData)
                                                x: (pos.left / 100) * parent.width
                                                width: (pos.width / 100) * parent.width
                                                height: 20
                                                anchors.verticalCenter: parent.verticalCenter
                                                color: getStatusColor(modelData.etat)
                                                radius: 3
                                                border.color: Qt.darker(color, 1.2)
                                                border.width: 1

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.nomTache
                                                    color: "white"
                                                    font.pixelSize: 9
                                                    elide: Text.ElideRight
                                                    width: parent.width - 6
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
    } // End StackLayout

    // ==========================================
    // SHARED DIALOGS - ONE INSTANCE EACH
    // ==========================================

    // Add Task Dialog
    Dialog {
        id: addTaskDialog
        title: "Créer une nouvelle tâche"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        width: 400

        property string currentColumn: ""

        onAboutToShow: {
            taskNameField.text = ""
            descriptionField.text = ""
            assignedUserField.currentIndex = -1
            estimatedTimeField.text = "0"
            startDateField.text = new Date().toISOString().split('T')[0]
            endDateField.text = ""
        }

        onAccepted: {
            var assignedId = -1
            if (assignedUserField.currentIndex >= 0) {
                var employees = taskController.getAvailableEmployees()
                if (employees && employees.length > assignedUserField.currentIndex) {
                    assignedId = employees[assignedUserField.currentIndex].idEmploye
                }
            }

            if (!taskNameField.text) {
                return
            }

            var success = taskController.createTask(
                window.projectId,
                taskNameField.text,
                descriptionField.text,
                0,
                assignedId,
                parseInt(estimatedTimeField.text || "0"),
                startDateField.text,
                endDateField.text,
                currentColumn
            )

            if (success) {
                refreshTrigger++
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

    // Employee Status Change Dialog
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
            if (taskId === -1) return

            var success = taskController.updateTaskStatus(
                taskId,
                taskEmployeeStatusCombo.currentText
            )

            if (success) {
                refreshTrigger++
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