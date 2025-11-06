import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 6.5

ApplicationWindow {
    id: root
    visible: true
    width: 1080
    height: 800
    color: "#ffffff"
    
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: loginPage
    }
    
    Component {
        id: loginPage
        
        Item {
            id: loginPageItem
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10
                
                Image {
                    source: "image.png"
                    width: 200
                    height: 200
                    Layout.alignment: Qt.AlignHCenter
                }
                
                ColumnLayout {
                    spacing: 5
                    Label { 
                        text: "Adresse courriel" 
                        font.pixelSize: 14
                    }
                    TextField { 
                        id: emailField
                        width: 250
                        placeholderText: "Entrez votre adresse"
                        font.pixelSize: 14
                    }
                    Layout.alignment: Qt.AlignHCenter
                }
                
                ColumnLayout {
                    spacing: 5
                    Label { 
                        text: "Mot de passe" 
                        font.pixelSize: 14
                    }
                    TextField { 
                        id: passwordField
                        width: 250
                        echoMode: TextInput.Password
                        placeholderText: "Entrez votre mot de passe"
                        font.pixelSize: 14
                        onAccepted: loginPageItem.handleLogin()
                    }
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Label {
                    id: errorLabel
                    text: ""
                    color: "red"
                    font.pixelSize: 12
                    visible: text !== ""
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Button {
                    id: loginButton
                    text: "Connexion"
                    width: 120
                    enabled: !busyIndicator.visible
                    onClicked: loginPageItem.handleLogin()
                    Layout.alignment: Qt.AlignHCenter
                }
                
                BusyIndicator {
                    id: busyIndicator
                    running: false
                    visible: running
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            
            function handleLogin() {
                console.log("Email:", emailField.text)
                console.log("Attempting login...")
                
                errorLabel.text = ""
                
                if (emailField.text === "" || passwordField.text === "") {
                    errorLabel.text = "Veuillez remplir tous les champs"
                    return
                }
                
                busyIndicator.running = true
                loginController.handleLogin(emailField.text, passwordField.text)
            }
            
            Connections {
                target: loginController
                
                function onLoginSuccess() {
                    console.log("Login successful, navigating to main2...")
                    busyIndicator.running = false
                    stackView.push("file:///C:/Users/Thomas/Documents/projet_gpi/QtQuickApplication1/QtQuickApplication1/QtQuickApplication1/main2.qml")
                }
                
                function onLoginFailed(errorMessage) {
                    busyIndicator.running = false
                    errorLabel.text = errorMessage
                    console.log("Login failed:", errorMessage)
                    passwordField.text = ""
                    passwordField.focus = true
                }
            }
        }
    }
}