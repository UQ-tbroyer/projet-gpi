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
    property int refreshTrigger: 0  // Used to force refresh

    // Load subtasks when window is ready
    Component.onCompleted: {
        console.log("TaskDetailsView: loading subtasks for task", taskId)
        
        // Connect to the subTasksChanged signal for auto-refresh
        taskController.subTasksChanged.connect(function(parentId) {
            if (parentId === taskWindow.taskId) {
                console.log("SubTasks changed for task", taskId, "- refreshing view")
                refreshTrigger++  // Force all Repeaters to update
            }
        })
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
            onClicked: taskWindow.close()
        }

        Column {
            spacing: 5
            Text {
                text: "Tâche: " + taskName
                font.bold: true
                font.pointSize: 18
            }
            Text {
                text: "Sous-tâches"
                font.pointSize: 12
                color: "gray"
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
                                    id: subTaskRepeater
                                    // Force refresh when refreshTrigger changes
                                    model: {
                                        refreshTrigger  // dependency
                                        console.log("=== Kanban Column:", columnName, "- Getting subtasks for task", taskWindow.taskId, "===")
                                        var allSubTasks = taskController.getSubTasks(taskWindow.taskId)
                                        console.log("Total subtasks retrieved:", allSubTasks.length)
                                        var filtered = []
                                        for (var i = 0; i < allSubTasks.length; i++) {
                                            console.log("  Checking subtask:", allSubTasks[i].nomTache, "| etat:", allSubTasks[i].etat, "| looking for:", columnName)
                                            if (allSubTasks[i].etat === columnName) {
                                                filtered.push(allSubTasks[i])
                                                console.log("    -> MATCHED! Adding to column")
                                            }
                                        }
                                        console.log("Filtered count for", columnName, ":", filtered.length)
                                        return filtered
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
                                                // Recursively open this subtask's view
                                                var component = Qt.createComponent("TaskDetailsView.qml")
                                                if (component.status === Component.Ready) {
                                                    var window = component.createObject(null, {
                                                        taskId: modelData.idTache,
                                                        taskName: modelData.nomTache,
                                                        projectId: taskWindow.projectId,
                                                        taskController: taskWindow.taskController,
                                                        projectController: taskWindow.projectController
                                                    })
                                                    window.show()
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

                                // === Add new subtask ===
                                Button {
                                    text: "+ Ajouter une sous-tâche"
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
                                        console.log("=== Creating subtask in column:", currentColumn, "===")
                                        
                                        var assignedId = -1
                                        if (assignedUserField.currentIndex >= 0) {
                                            var employees = taskController.getAvailableEmployees()
                                            assignedId = employees[assignedUserField.currentIndex].idEmploye
                                        }

                                        console.log("Calling createSubTask with:")
                                        console.log("  parentTaskId:", taskWindow.taskId)
                                        console.log("  taskName:", subTaskNameField.text)
                                        console.log("  assignedId:", assignedId)
                                        console.log("  estimatedTime:", parseInt(subTaskTimeField.text || "0"))
                                        console.log("  dateDebut:", subTaskStartDateField.text)
                                        console.log("  dateFin:", subTaskEndDateField.text)
                                        console.log("  etat:", currentColumn)

                                        // Use same parameters as createTask
                                        var success = taskController.createSubTask(
                                            taskWindow.taskId,         // parentTaskId
                                            subTaskNameField.text,     // taskName
                                            subTaskDescField.text,     // description
                                            assignedId,                // assignedToId
                                            parseInt(subTaskTimeField.text || "0"),  // estimatedTime
                                            subTaskStartDateField.text,  // dateDebut
                                            subTaskEndDateField.text,    // dateFin
                                            currentColumn              // etat
                                        )

                                        if (success) {
                                            console.log("SubTask created successfully - forcing refresh")
                                            // Force immediate refresh
                                            refreshTrigger++
                                        } else {
                                            console.log("Erreur création sous-tâche")
                                        }

                                        // Clear fields
                                        subTaskNameField.text = ""
                                        subTaskDescField.text = ""
                                        subTaskTimeField.text = ""
                                        subTaskStartDateField.text = ""
                                        subTaskEndDateField.text = ""
                                        assignedUserField.currentIndex = -1
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
                                // Force refresh when refreshTrigger changes
                                model: {
                                    refreshTrigger  // dependency
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
                                                    projectController: taskWindow.projectController
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
                                // Force refresh when refreshTrigger changes
                                model: {
                                    refreshTrigger  // dependency
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
                                                    projectController: taskWindow.projectController
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
}