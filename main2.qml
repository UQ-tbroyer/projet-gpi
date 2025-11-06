import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 6.5

Item {
    id: mainPage
    
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
            id: logoutButton
            text: "Deconnexion"
            width: 150
            height: 60
            
            background: Rectangle {
                color: "transparent"
                border.color: "black"
                border.width: 1
                radius: 10
            }
            
            contentItem: Text {
                text: logoutButton.text
                color: "black"
                font.pointSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                console.log("Déconnexion...")
                StackView.view.pop()
            }
        }
    }
    
    // --- Welcome message ---
    Text {
        id: welcomeText
        text: "Bienvenue, " + loginController.currentUserName()
        font.pointSize: 14
        font.bold: true
        color: "#333333"
        anchors.top: header.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
    }
    
    // --- ScrollView horizontale pour les projets ---
    ScrollView {
        id: scrollView
        width: parent.width * 0.9
        height: 250
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: welcomeText.bottom
        anchors.topMargin: 40
        clip: false
        
        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AlwaysOn
            height: 10
        }
        
        Row {
            id: projectRow
            spacing: 20
            anchors.verticalCenter: parent.verticalCenter
            
            Repeater {
                model: 10
                
                delegate: Rectangle {
                    required property int index
                    
                    width: 120
                    height: 200
                    radius: 15
                    color: "transparent"
                    border.color: "black"
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Projet " + (parent.index + 1)
                        color: "black"
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: console.log("Projet " + (parent.index + 1) + " cliqué")
                        cursorShape: Qt.PointingHandCursor
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
            cursorShape: Qt.PointingHandCursor
        }
    }
}