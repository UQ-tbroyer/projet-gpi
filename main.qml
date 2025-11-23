pragma ComponentBehavior: Bound
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
    
    // Preload main2.qml component
    Component {
        id: main2Component
        Loader {
            source: "main2.qml"
        }
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
             // Fonction publique pour la déconnexion
             function handleLogout() {
            console.log("Handling logout...")
            stackView.pop(null) // Retour au login
            }
            Connections {
                target: loginController
    
                function onLoginSuccess() {
                    console.log("Login successful, navigating to main2...")
                    console.log("projectController available:", projectController !== null)
                    console.log("taskController available:", taskController !== null)
                    console.log("loginController available:", loginController !== null)
        
                    busyIndicator.running = false

                    // IMPORTANT: Wait a tiny bit for the user to be fully set in controllers
                    Qt.callLater(function() {
                        // Create the main2 page with properties set at creation time
                        var component = Qt.createComponent("main2.qml")
                        
                        if (component.status === Component.Ready) {
                            var main2Page = component.createObject(stackView, {
                            projectController: projectController,
                            taskController: taskController,
                            loginController: loginController,
                            mainAppWindow: root  // Passe la référence
                             })
                            
                            if (main2Page) {
                                stackView.push(main2Page)
                                console.log("Successfully pushed main2.qml")
                            } else {
                                console.error("Failed to create main2 page object")
                                errorLabel.text = "Erreur de navigation"
                            }
                        } else if (component.status === Component.Error) {
                            console.error("Error loading main2.qml:", component.errorString())
                            errorLabel.text = "Erreur de chargement"
                        } else {
                            console.log("Component not ready, waiting...")
                            component.statusChanged.connect(function() {
                                if (component.status === Component.Ready) {
                                    var main2Page = component.createObject(stackView, {
                                        projectController: projectController,
                                        taskController: taskController,
                                        loginController: loginController
                                    })
                                    
                                    if (main2Page) {
                                        stackView.push(main2Page)
                                        console.log("Successfully pushed main2.qml after waiting")
                                    }
                                }
                            })
                        }
                    })
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
