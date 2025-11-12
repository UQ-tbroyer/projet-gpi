import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 6.5
import QtQuick.Shapes 6.5
import QtQuick.Window 6.5

ApplicationWindow {
    id: window
    width: 1000
    height: 600
    visible: true
    title: "Page de projet"
    color: "white"

    // --- Barre supérieure ---
    Row {
        id: topBar
        spacing: 20
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 20

        Button {
            text: "<- Retour"
        }

        Text {
            text: "Nom de projet"
            font.bold: true
            font.pointSize: 20
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // --- Menu latéral gauche ---
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
            background: Rectangle {
                color: stackView.currentIndex === 0 ? "green" : "white"
                border.color: "black"
                border.width: 1
            }
            onClicked: stackView.currentIndex = 0
        }

        Button {
            id: btnGantt
            text: "Gantt"
            width: 80
            height: 40
            background: Rectangle {
                color: stackView.currentIndex === 1 ? "green" : "white"
                border.color: "black"
                border.width: 1
            }
            onClicked: stackView.currentIndex = 1
        }
    }

    // --- Contenu central (Kanban / Gantt) ---
    StackLayout {
        id: stackView
        anchors.top: topBar.bottom
        anchors.left: sideMenu.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        currentIndex: 0

        // ======= PAGE KANBAN =======
        Flickable {
            contentWidth: kanbanRow.width
            clip: true

            Row {
                id: kanbanRow
                spacing: 20

                // Exemple de 4 colonnes Kanban
                Repeater {
                    model: ["A faire", "En cours", "A tester", "Terminee"]
                    Column {
                        spacing: 10
                        Rectangle {
                            width: 150
                            height: 350
                            radius: 15
                            border.color: "black"
                            border.width: 1
                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Text {
                                    text: modelData
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                // Exemples de tâches
                                Repeater {
                                    model: index === 0 ? ["tache 1", "tache 2"] :
                                            index === 1 ? ["tache 3"] : []
                                    Rectangle {
                                        width: parent.width - 20
                                        height: 40
                                        radius: 6
                                        border.color: "black"
                                        color: "white"
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData
                                        }
                                    }
                                }

                                Rectangle {
                                    width: parent.width - 20
                                    height: 40
                                    radius: 6
                                    border.color: "transparent"
                                    color: "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "+ ajouter une tache"
                                    }
                                }
                            }
                        }
                    }
                }

                // Dernière colonne : ajout de colonne
                Rectangle {
                    width: 150
                    height: 350
                    radius: 15
                    border.color: "black"
                    border.width: 1
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "+ ajouter une colonne"
                    }
                }
            }
        }

        // ======= PAGE GANTT =======
        Item {
            id: ganttPage

            Rectangle {
                anchors.fill: parent
                border.color: "black"
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 10

                    // Ligne des mois
                    Row {
                        spacing: 40
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { text: "sept" }
                        Text { text: "oct" }
                        Text { text: "nov" }
                        Text { text: "dec" }
                        Text { text: "jan" }
                        Text { text: "fev" }
                        Text { text: "mar" }
                    }

                    // Exemple de tâches avec barres de Gantt
                    Row {
                        spacing: 10
                        anchors.topMargin: 20
                        Column {
                            spacing: 10
                            Text { text: "Tache 1" }
                            Text { text: "Tache 2" }
                            Text { text: "Tache 3" }
                            Text { text: "Tache 4" }
                        }

                        Rectangle {
                            width: 700
                            height: 200
                            border.color: "black"
                            border.width: 1
                            color: "transparent"

                            // Barres des tâches
                            Rectangle {
                                x: 50; y: 20
                                width: 100; height: 20
                                border.color: "black"
                                color: "white"
                            }
                            Rectangle {
                                x: 100; y: 60
                                width: 120; height: 20
                                border.color: "black"
                                color: "white"
                            }
                            Rectangle {
                                x: 220; y: 100
                                width: 140; height: 20
                                border.color: "black"
                                color: "white"
                            }
                            Rectangle {
                                x: 360; y: 140
                                width: 100; height: 20
                                border.color: "black"
                                color: "white"
                            }

                            // Flèches entre tâches (Shape)
                            Shape {
                                ShapePath {
                                    strokeColor: "black"
                                    strokeWidth: 2
                                    startX: 180; startY: 70
                                    PathLine { x: 220; y: 110 }
                                }
                                ShapePath {
                                    strokeColor: "black"
                                    strokeWidth: 2
                                    startX: 360; startY: 120
                                    PathLine { x: 360; y: 140 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
