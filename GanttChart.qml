// GanttChart.qml
import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 6.5

Flickable {
    id: ganttFlickable
    // Set a large content width for the timeline to span
    property real timelineWidth: 1500
    contentWidth: timelineWidth
    contentHeight: ganttColumn.implicitHeight + 50 // Add margin for header

    property var taskController
    property var ganttTasks: [] // Will hold the QVariantList from C++
    property alias refreshTrigger: ganttLoader.refreshTrigger

    // Timeline properties provided by the C++ controller
    readonly property real minDateMs: taskController.minProjectDate.toMSecsSinceEpoch()
    readonly property real maxDateMs: taskController.maxProjectDate.toMSecsSinceEpoch()
    readonly property real totalDurationMs: maxDateMs - minDateMs

    // Helper to load and refresh data
    Component {
        id: ganttLoader
        property int refreshTrigger: 0
        onRefreshTriggerChanged: {
            if (taskController && taskController.projectId > 0) {
                // Fetch the sorted data from the C++ controller
                ganttTasks = taskController.getGanttTasks(taskController.projectId);
            }
        }
        // Initial load
        Component.onCompleted: refreshTrigger = 1
    }
    
    // Auto-refresh when the underlying controller's dates change (e.g., a new task is created)
    Connections {
        target: taskController
        function onDatesRangeChanged() {
            ganttLoader.refreshTrigger++
        }
    }
    
    // --- VISUALIZATION AREA ---
    ColumnLayout {
        id: ganttColumn
        width: ganttFlickable.contentWidth
        spacing: 2
        
        // --- Gantt Header (Timeline) ---
        Rectangle {
            width: parent.width
            height: 30
            color: "#f0f0f0"
            
            // **Implement a proper date scale ruler here**
            Label { text: "Timeline Header (e.g., Months/Weeks)" }
        }

        // --- Task List and Bars ---
        Repeater {
            model: ganttTasks // The QVariantList from C++
            
            // Task Row
            Rectangle {
                width: parent.width
                height: 30
                color: model.parentId === 0 ? "#e0e0e0" : "#ffffff" // Parent/Subtask color differentiation
                
                // LEFT: Task Name (Fixed width)
                Text {
                    id: taskLabel
                    text: model.taskName
                    width: 200
                    height: parent.height
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: model.parentId !== 0 ? 20 : 5 // Indent subtasks
                    font.pointSize: model.parentId === 0 ? 10 : 9
                    font.bold: model.parentId === 0
                }
                
                // RIGHT: Gantt Bar
                Rectangle {
                    id: ganttBar
                    anchors.left: taskLabel.right
                    anchors.right: parent.right
                    height: parent.height
                    color: "transparent"

                    // The actual task bar visualization
                    Rectangle {
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 3
                        color: model.parentId === 0 ? "#4CAF50" : "#2196F3" // Different colors for Parent/Child
                        
                        // --- CORE LOGIC: MAP DATE TO POSITION/WIDTH ---
                        
                        // 1. Task's start time in milliseconds
                        readonly property real taskStartMs: new Date(model.dateDebut).getTime()
                        
                        // 2. Task's end time in milliseconds
                        readonly property real taskEndMs: new Date(model.dateFin).getTime()
                        
                        // 3. Start X Position calculation (Offset from min project date)
                        x: totalDurationMs > 0 ? (taskStartMs - minDateMs) / totalDurationMs * ganttFlickable.timelineWidth : 0

                        // 4. Width calculation (Duration relative to total project duration)
                        width: totalDurationMs > 0 ? (taskEndMs - taskStartMs) / totalDurationMs * ganttFlickable.timelineWidth : 0
                        
                        // Min width for visibility
                        implicitWidth: Math.max(width, 5) 
                        
                        // Label on the bar
                        Label {
                            text: model.taskName
                            color: "white"
                            font.pointSize: 8
                            anchors.centerIn: parent
                            visible: parent.width > 50 // Only show label if bar is wide enough
                        }

                        // Tooltip on hover
                        ToolTip.qmlAttached: ToolTip {
                            text: model.taskName + "\\nStart: " + model.dateDebut + "\\nEnd: " + model.dateFin
                        }
                    }
                }
            }
        }
    }
}