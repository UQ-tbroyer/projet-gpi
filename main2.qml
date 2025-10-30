import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 6.5

ApplicationWindow {
    id: window
    width: 600
    height: 600
    visible: true
    title: "Accueil"
    color: "white"

    // --- En-tête ---
    Row {
         id: header
            spacing: 20
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 200  
        Rectangle {
            radius: 10
            border.color: "black"
            border.width: 1
            color: "transparent"
            width: 200
            height: 60
            Text {
                anchors.centerIn: parent
                text: "Accueil"
                color: "black"
                font.bold: true
                font.pointSize: 18
            }
        }

        Button {
            text: "Deconnexion"
            background: Rectangle {
                color: "transparent"
                border.color: "black"
                border.width: 1
                radius: 6
            }
            Text {
                text: control.text
                color: "black"
                font.pointSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // --- ScrollView horizontale pour les projets ---
    ScrollView {
        id: scrollView
        width: parent.width * 0.9
        height: 250
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: header.bottom
        anchors.topMargin: 100
        clip: false

        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AlwaysOff
            height: 10
            
        }

        Row {
            id: projectRow
            spacing: 20
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: 10
                Rectangle {
                    width: 120
                    height: 200
                    radius: 15
                    color: "transparent"
                    border.color: "black"
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "Projet " + (index + 1)
                        color: "black"
                    }
                }
            }
        }
    }

    // --- Bouton de gestion de temps ---
    Rectangle {
        width: 150
        height: 60
        radius: 10
        border.color: "black"
        border.width: 1
        color: "transparent"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        Text {
            anchors.centerIn: parent
            text: "Gestion de temps"
            color: "black"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: console.log("Gestion de temps cliquée")
        }
    }
}
