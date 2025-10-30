import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 6.5
import QtQuick.Window

Window {
    visible: true
    width: 1080
    height: 800
    color: "#ffffff"

    
        ColumnLayout {
            anchors.centerIn: parent
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            
            Image {
                source: "image.png"
                width: 200
                height: 200
                Layout.alignment: Qt.AlignHCenter
            }

            ColumnLayout {
                spacing: 5
                Label { text: "Adresse courriel" }
                TextField { id: emailField; width: 250; placeholderText: "Entrez votre adresse" }
                Layout.alignment: Qt.AlignHCenter
            }

            ColumnLayout {
                spacing: 5
                Label { text: "Mot de passe" }
                TextField { id: passwordField; width: 250; echoMode: TextInput.Password; placeholderText: "Entrez votre mot de passe" }
                Layout.alignment: Qt.AlignHCenter
            }

            Button {
                text: "Connexion"
                width: 120
                onClicked: {
                    console.log("Email:", emailField.text)
                    console.log("Mot de passe:", passwordField.text)
                }
                Layout.alignment: Qt.AlignHCenter
            }
        }
 }   

