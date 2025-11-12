import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 6.5
import QtQuick.Dialogs 6.5

ApplicationWindow {
    id: window
    width: 600
    height: 600
    visible: true
    title: "Accueil"
    color: "white"

    property int projectCount: 0

    // --- Rectangle Accueil ---
    Rectangle {
        id: accueilRect
        width: 200
        height: 60
        radius: 10
        border.color: "black"
        border.width: 1
        color: "transparent"
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            anchors.centerIn: parent
            text: "Accueil"
            color: "black"
            font.bold: true
            font.pointSize: 18
        }
    }

    // --- Bouton déconnexion ---
    Button {
        id: deconnexionBtn
        width: 90
        height: 30
        text: "Deconnexion"
        anchors.left: accueilRect.right
        anchors.leftMargin: 20
        anchors.verticalCenter: accueilRect.verticalCenter

        onClicked: {
            console.log("Déconnexion cliquée")
            window.close()
        }

        background: Rectangle {
            color: "transparent"
            border.color: "black"
            border.width: 1
            radius: 6
        }

        contentItem: Text {
            text: deconnexionBtn.text  
            anchors.centerIn: parent
            color: "black"
            font.pointSize: 10
        }
    }

    // --- ScrollView des projets ---
    ScrollView {
        id: scrollView
        width: parent.width
        height: 250
        anchors.top: accueilRect.bottom
        anchors.topMargin: 50
        clip: true

        Row {
            id: projectRow
            spacing: 20
            anchors.centerIn: parent

            // Bouton "+ ajouter un projet"
            Button {
                id: addProjectBtn
                width: 120
                height: 200

                onClicked: nameDialog.open()

                background: Rectangle {
                    color: "transparent"
                    border.color: "black"
                    border.width: 1
                    radius: 6
                }

                contentItem: Text {
                    text: "+ ajouter un projet"
                    anchors.centerIn: parent
                    color: "black"
                    font.pointSize: 10
                }
            }

            // Modèle des projets
            ListModel {
                id: projectModel
            }

            // Création dynamique des boutons projet
            Repeater {
                model: projectModel
                delegate: Button {
                    width: 120
                    height: 200

                    background: Rectangle {
                        color: "transparent"
                        border.color: "black"
                        border.width: 1
                        radius: 6
                    }

                    contentItem: Text {
                        text: name
                        anchors.centerIn: parent
                        color: "black"
                        font.pointSize: 10
                    }

                    onClicked: console.log(name + " cliqué")
                }
            }
        }
    }

    // --- Fenêtre de saisie du nom du projet ---
    Dialog {
        id: nameDialog
        title: "Nouveau projet"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        property string projectName: ""

        onAccepted: {
            if (projectName.trim().length > 0) {
                projectModel.append({"name": projectName})
                console.log("Projet ajouté :", projectName)
                projectName = ""
            } else {
                console.log("Nom de projet vide — aucun projet ajouté.")
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            

            Label {
                text: "Entrez le nom du projet :"
            }

            TextField {
                id: nameField
                placeholderText: "Ex: Site web, Application mobile..."
                text: nameDialog.projectName
                onTextChanged: nameDialog.projectName = text
            }
        }
    }

    // --- Bouton gestion de temps ---
    Button {
        id: btntemps
        width: 150
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40

        onClicked: console.log("Gestion de temps cliquée")

        background: Rectangle {
            color: "transparent"
            border.color: "black"
            border.width: 1
            radius: 6
        }

        contentItem: Text {
            text: "Gestion de temps"
            anchors.centerIn: parent
            color: "black"
            font.pointSize: 10
        }
    }
}
