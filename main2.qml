import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Controls.impl 6.5
import QtQuick.Layouts 6.5
import QtQuick.Dialogs 6.5

Page {
    id: mainPage

    background: Rectangle { color: "white" }

    // Controller properties - ONLY declared once here
    required property var projectController
    required property var taskController
    required property var loginController

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

    // --- Welcome message ---
    Column {
        id: welcomeSection
        spacing: 5
        anchors.top: accueilRect.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        
        Text {
            id: welcomeText
            text: {
                if (mainPage.loginController && mainPage.loginController.currentUserName) {
                    return "Bienvenue, " + mainPage.loginController.currentUserName()
                } else {
                    return "Bienvenue"
                }
            }
            font.pointSize: 14
            font.bold: true
            color: "#333333"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Text {
            id: roleText
            text: {
                if (mainPage.projectController && mainPage.projectController.getUserRole) {
                    var role = mainPage.projectController.getUserRole()
                    console.log("User role:", role)
                    return "Role: " + role
                }
                return ""
            }
            font.pointSize: 11
            color: "#666666"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // --- Bouton déconnexion ---
    Button {
        id: deconnexionBtn
        width: 120
        height: 40
        text: "Déconnexion"
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: accueilRect.verticalCenter

         onClicked: {
            console.log("Déconnexion cliquée")
            
            // Utilisez mainPage.parent pour accéder au StackView
            if (mainPage.parent && mainPage.parent.pop) {
                mainPage.parent.pop(null) // Retour à la page de login
            } else {
                console.log("Erreur: Parent n'est pas un StackView")
            }
            
            // Nettoyage optionnel
            if (loginController && loginController.logout) {
                loginController.logout()
            }
        }
    }

    // --- Menu de navigation ---
    Row {
        id: navigationMenu
        spacing: 15
        anchors.top: welcomeSection.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        
        Button {
            text: "Tous les Projets"
            visible: mainPage.projectController && mainPage.projectController.canViewAllProjects && mainPage.projectController.canViewAllProjects()
            onClicked: {
                console.log("Chargement de tous les projets...")
                if (mainPage.projectController && mainPage.projectController.loadProjects) {
                    mainPage.projectController.loadProjects()
                }
            }
        }
        
        Button {
            text: "Projets Département"
            visible: {
                if (!mainPage.projectController || !mainPage.projectController.getUserRole) 
                    return false
                var role = mainPage.projectController.getUserRole()
                return role === "Administrateur" || role === "Gestionnaire"
            }
            onClicked: {
                console.log("Chargement des projets du département...")
                if (mainPage.projectController && mainPage.projectController.loadProjectsByDepartment) {
                    mainPage.projectController.loadProjectsByDepartment()
                }
            }
        }
        
        Button {
            text: "Mes Projets"
            onClicked: {
                console.log("Chargement de mes projets...")
                if (mainPage.projectController && mainPage.projectController.loadProjectsByUser) {
                    mainPage.projectController.loadProjectsByUser()
                }
            }
        }
    }
    
    function isEmployeeRole() {
        if (!mainPage.projectController || !mainPage.projectController.getUserRole) return false
        return mainPage.projectController.getUserRole() === "Employe"
    }

    // --- ScrollView des projets ---
    ScrollView {
        id: scrollView
        width: parent.width * 0.9
        height: 400
        anchors.top: navigationMenu.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        clip: true

        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AsNeeded
            height: 10
        }
        
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 10
        }

        Row {
            id: projectRow
            spacing: 20
            padding: 10

            // Bouton "+ ajouter un projet"
            Rectangle {
                id: addProjectBtn
                width: 180
                height: 220
                radius: 15
                border.color: "black"
                border.width: 1
                color: "transparent"
                visible: mainPage.projectController && mainPage.projectController.canCreateProject && mainPage.projectController.canCreateProject()

                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    
                    Text {
                        text: "+"
                        font.pointSize: 24
                        color: "black"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "ajouter un projet"
                        font.pointSize: 12
                        color: "black"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        console.log("Opening project creation dialog")
                        projectCreationDialog.open()
                    }
                }
            }

            // Projects from C++ controller
            Repeater {
                id: projectRepeater
                model: mainPage.projectController && mainPage.projectController.projects ? mainPage.projectController.projects : []
                
                delegate: Rectangle {
                    required property var modelData
                    property int projectId: modelData.idProject
                    property string projectName: modelData.nomProject
                    property string clientName: modelData.nomClient
                    property double projectCost: modelData.coutService
                    property string projectDate: modelData.dataProject
                    
                    width: 180
                    height: 220
                    radius: 15
                    color: "#f8f9fa"
                    border.color: "#dee2e6"
                    border.width: 2
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5
                        
                        Text {
                            text: projectName
                            font.bold: true
                            font.pointSize: 12
                            color: "#212529"
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: "Client: " + clientName
                            font.pointSize: 10
                            color: "#495057"
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: "Coût: " + (projectCost ? projectCost.toFixed(2) : "0.00") + " €"
                            font.pointSize: 10
                            color: "#495057"
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: "Date: " + projectDate
                            font.pointSize: 9
                            color: "#6c757d"
                            Layout.fillWidth: true
                        }
                        
                        Button {
                            text: "Ouvrir"
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 80
                            onClicked: {
                                console.log("=== OUVRIR BUTTON CLICKED ===")
                                console.log("Project ID:", projectId)
                                console.log("Project Name:", projectName)
                                console.log("taskController exists:", mainPage.taskController !== null)
                                
                                var component = Qt.createComponent("main3.qml")
                                if (component.status === Component.Ready) {
                                    var projectDetailWindow = component.createObject(null, {
                                        projectId: projectId,
                                        projectName: projectName,
                                        taskController: mainPage.taskController,
                                        projectController: mainPage.projectController
                                    })
                                    projectDetailWindow.show()
                                } else {
                                    console.log("Error loading main3.qml:", component.errorString())
                                    errorDialog.text = "Erreur: Impossible de charger la page de détails du projet"
                                    errorDialog.open()
                                }
                            }
                        }

                        Button {
                            text: "Supprimer"
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 80
                            visible: mainPage.projectController && mainPage.projectController.canDeleteProject && 
                                    mainPage.projectController.canDeleteProject(projectId)
                            
                            onClicked: {
                                console.log("=== SUPPRIMER BUTTON CLICKED ===")
                                console.log("Project ID:", projectId)
                                console.log("Project Name:", projectName)
                                
                                deleteProjectDialog.projectId = projectId
                                deleteProjectDialog.projectName = projectName
                                deleteProjectDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }

    // --- Indicateur de chargement ---
    BusyIndicator {
        id: loadingIndicator
        running: mainPage.projectController && mainPage.projectController.loading !== undefined ? mainPage.projectController.loading : false
        visible: running
        anchors.centerIn: scrollView
        width: 50
        height: 50
    }

    // --- Message si aucun projet ---
    Text {
        id: noProjectsText
        visible: mainPage.projectController && mainPage.projectController.projects && mainPage.projectController.projects.length === 0 && !loadingIndicator.running
        text: "Aucun projet trouvé.\nCliquez sur '+' pour créer un nouveau projet."
        font.pointSize: 14
        color: "#6c757d"
        horizontalAlignment: Text.AlignHCenter
        anchors.centerIn: scrollView
    }

    // --- Bouton gestion de temps ---
    Button {
        id: btntemps
        width: 200
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        text: "Gestion de temps"

        onClicked: {
            console.log("Gestion de temps cliquée")
        
            if (mainPage.parent && mainPage.parent.push) {
                mainPage.parent.push("main4.qml", {
                    projectController: mainPage.projectController,
                    taskController: mainPage.taskController,
                    loginController: mainPage.loginController
                })
            }
        }
    }

    // --- Dialogue de création de projet ---
    Dialog {
        id: projectCreationDialog
        title: "Nouveau Projet"
        anchors.centerIn: parent
        width: 450
        height: 600
        modal: true

        property var clientsList: []
        property var templatesList: []

        // Functions defined at Dialog level so they're accessible everywhere
        function loadClientsData() {
            console.log("Loading clients data...")
            if (mainPage.projectController && mainPage.projectController.getClients) {
                var clients = mainPage.projectController.getClients()
                console.log("Number of clients:", clients ? clients.length : 0)

                projectCreationDialog.clientsList = clients || []
                clientComboBox.model = projectCreationDialog.clientsList
                if (clientComboBox.count > 0) {
                    clientComboBox.currentIndex = 0
                }
            } else {
                console.log("ERROR: Cannot load clients - controller or method not available")
            }
        }

        function loadTemplatesData() {
            console.log("Loading templates data...")
            if (mainPage.projectController && mainPage.projectController.getTemplateProjects) {
                var templates = mainPage.projectController.getTemplateProjects()
                console.log("Number of templates:", templates ? templates.length : 0)

                projectCreationDialog.templatesList = templates || []
                templateComboBox.model = projectCreationDialog.templatesList
                templateComboBox.currentIndex = -1
            } else {
                console.log("ERROR: Cannot load templates - controller or method not available")
            }
        }

        function loadTemplateData(templateId) {
            console.log("Loading template data for project:", templateId)
            if (mainPage.projectController && mainPage.projectController.getProjectDetails) {
                var projectDetails = mainPage.projectController.getProjectDetails(templateId)
            
                if (projectDetails && Object.keys(projectDetails).length > 0) {
                    // Pre-fill fields with template data
                    repositoryField.text = projectDetails.tempRepository || ""
                    costField.text = projectDetails.coutService ? projectDetails.coutService.toFixed(2) : "0.00"
                
                    console.log("Template data loaded successfully")
                }
            }
        }

        function resetForm() {
            projectNameField.text = ""
            repositoryField.text = ""
            costField.text = "0.00"
            projectDateField.text = new Date().toISOString().split('T')[0]
        
            fromScratchRadio.checked = true
            fromTemplateRadio.checked = false
            templateComboBox.currentIndex = -1
            copyTasksCheckbox.checked = false
        
            if (clientComboBox.count > 0) {
                clientComboBox.currentIndex = 0
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            // Template selection section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "#f0f0f0"
                radius: 5
                border.color: "#cccccc"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Label { 
                        text: "Créer à partir de :"
                        font.bold: true 
                        font.pointSize: 11
                    }
                
                    Row {
                        spacing: 10
                        Layout.fillWidth: true
                    
                        RadioButton {
                            id: fromScratchRadio
                            text: "Projet vide"
                            checked: true
                            onCheckedChanged: {
                                if (checked) {
                                    templateComboBox.currentIndex = -1
                                    copyTasksCheckbox.checked = false
                                }
                            }
                        }
                    
                        RadioButton {
                            id: fromTemplateRadio
                            text: "Copier un projet"
                            onCheckedChanged: {
                                if (checked && templateComboBox.count > 0) {
                                    templateComboBox.currentIndex = 0
                                }
                            }
                        }
                    }
                
                    ComboBox {
                        id: templateComboBox
                        Layout.fillWidth: true
                        enabled: fromTemplateRadio.checked
                        model: projectCreationDialog.templatesList
                        textRole: "displayName"
                        valueRole: "idProject"
                        displayText: currentIndex === -1 ? "Sélectionnez un projet..." : currentText
                    
                        onActivated: {
                            if (currentIndex >= 0) {
                                projectCreationDialog.loadTemplateData(currentValue)
                            }
                        }
                    }
                
                    CheckBox {
                        id: copyTasksCheckbox
                        text: "Copier les tâches"
                        enabled: fromTemplateRadio.checked && templateComboBox.currentIndex >= 0
                        checked: fromTemplateRadio.checked
                    }
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#cccccc"
            }

            // Project details section
            Label { text: "Nom du projet"; font.bold: true }
            TextField {
                id: projectNameField
                placeholderText: "Entrez le nom du projet"
                Layout.fillWidth: true
            }

            Label { text: "Client"; font.bold: true }
            ComboBox {
                id: clientComboBox
                Layout.fillWidth: true
                model: projectCreationDialog.clientsList
                textRole: "nomClient"
                valueRole: "idClient"
            }

            Label { text: "Répertoire"; font.bold: true }
            TextField {
                id: repositoryField
                placeholderText: "Répertoire du projet"
                Layout.fillWidth: true
            }

            Label { text: "Coût du service (€)"; font.bold: true }
            TextField {
                id: costField
                placeholderText: "0.00"
                validator: DoubleValidator { bottom: 0; decimals: 2 }
                Layout.fillWidth: true
                text: "0.00"
            }

            Label { text: "Date du projet"; font.bold: true }
            TextField {
                id: projectDateField
                placeholderText: "AAAA-MM-JJ"
                Layout.fillWidth: true
                text: new Date().toISOString().split('T')[0]
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10

                Button {
                    text: "Annuler"
                    onClicked: {
                        projectCreationDialog.close()
                    }
                }

                Button {
                    id: createProjectButton
                    text: fromTemplateRadio.checked ? "Créer à partir du modèle" : "Créer"
                    enabled: projectNameField.text !== "" && clientComboBox.currentValue > 0
                    onClicked: {
                        console.log("Creating project:", projectNameField.text)
                        console.log("From template:", fromTemplateRadio.checked)
                        console.log("Template ID:", templateComboBox.currentValue)
                        console.log("Copy tasks:", copyTasksCheckbox.checked)
                    
                        var success = false
                    
                        if (fromTemplateRadio.checked && templateComboBox.currentValue > 0) {
                            // Create from template
                            console.log("=== CALLING createProjectFromTemplate ===")
                            success = mainPage.projectController.createProjectFromTemplate(
                                projectNameField.text,
                                clientComboBox.currentValue,
                                repositoryField.text,
                                parseFloat(costField.text || "0"),
                                projectDateField.text,
                                templateComboBox.currentValue,
                                copyTasksCheckbox.checked
                            )
                        } else {
                            // Create from scratch
                            console.log("=== CALLING createProject ===")
                            success = mainPage.projectController.createProject(
                                projectNameField.text,
                                clientComboBox.currentValue,
                                repositoryField.text,
                                parseFloat(costField.text || "0"),
                                projectDateField.text
                            )
                        }

                        if (success) {
                            projectCreationDialog.close()
                        }
                    }
                }
            }
        }

        onOpened: {
            console.log("Project dialog opened - loading data")
            loadClientsData()
            loadTemplatesData()
            projectNameField.forceActiveFocus()
        }
    
        onClosed: {
            console.log("Dialog closed - resetting form")
            resetForm()
        }
    }

    // --- Dialogue de confirmation de suppression ---
    Dialog {
        id: deleteProjectDialog
        title: "Confirmation de suppression"
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: 300
        height: 150
        modal: true
    
        property int projectId: 0
        property string projectName: ""
    
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
        
            Text {
                text: "Êtes-vous sûr de vouloir supprimer le projet:\n\"" + deleteProjectDialog.projectName + "\" ?"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10
            
                Button {
                    text: "Annuler"
                    onClicked: {
                        console.log("Delete cancelled")
                        deleteProjectDialog.close()
                    }
                }
            
                Button {
                    text: "Supprimer"
                    onClicked: {
                        console.log("Deleting project:", deleteProjectDialog.projectId)
                        if (mainPage.projectController && mainPage.projectController.deleteProject) {
                            mainPage.projectController.deleteProject(deleteProjectDialog.projectId)
                        } else {
                            console.log("ERROR: projectController or deleteProject not available")
                        }
                        deleteProjectDialog.close()
                    }
                }
            }
        }
    }

    // --- Error dialog ---
    Dialog {
        id: errorDialog
        title: "Erreur"
        anchors.centerIn: parent
        width: 300
        height: 150
        modal: true
        
        property string text: ""
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            
            Text {
                text: errorDialog.text
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            
            Button {
                text: "OK"
                onClicked: errorDialog.close()
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // --- Connexions aux signaux ---
    Connections {
        target: mainPage.projectController
        
        function onCurrentUserChanged() {
            console.log("=== Current user changed - reloading data ===")
            loadInitialData()
        }
        
        function onProjectsChanged() {
            console.log("Liste des projets mise à jour - count:", mainPage.projectController.projects ? mainPage.projectController.projects.length : 0)
        }
        
        function onProjectCreated(projectId) {
            console.log("Projet créé avec ID:", projectId)
        }
        
        function onProjectCreationFailed(error) {
            console.log("Erreur création projet:", error)
            errorDialog.text = "Erreur lors de la création du projet: " + error
            errorDialog.open()
        }
        
        function onProjectDeleted(projectId) {
            console.log("Projet supprimé:", projectId)
        }
    }
    
    Connections {
        target: mainPage.taskController
        
        function onTasksChanged() {
            console.log("Liste des tâches mise à jour")
        }
        
        function onTaskCreated(taskId) {
            console.log("Tâche créée avec ID:", taskId)
        }
        
        function onTaskCreationFailed(error) {
            console.log("Erreur création tâche:", error)
        }
    }

    // --- Initialisation ---
    Component.onCompleted: {
        console.log("MainPage chargée - Vérification des contrôleurs...")
        console.log("projectController exists:", mainPage.projectController !== null)
        console.log("taskController exists:", mainPage.taskController !== null)
        console.log("loginController exists:", mainPage.loginController !== null)
        
        // Delay initial setup to allow controllers to be fully initialized
        Qt.callLater(function() {
            loadInitialData()
        })
    }
    
    function loadInitialData() {
        if (mainPage.projectController) {
            console.log("Available projectController methods:")
            console.log(" - loadProjects:", !!mainPage.projectController.loadProjects)
            console.log(" - getUserRole:", !!mainPage.projectController.getUserRole)
            console.log(" - canCreateProject:", !!mainPage.projectController.canCreateProject)
            
            if (mainPage.projectController.getUserRole) {
                var role = mainPage.projectController.getUserRole()
                console.log("Current user role:", role)
                
                if (role !== "No User" && role !== "Unknown") {
                    if (role === "Administrateur" && mainPage.projectController.canViewAllProjects && mainPage.projectController.canViewAllProjects()) {
                        console.log("Loading all projects for Admin...")
                        mainPage.projectController.loadProjects()
                    } else if (role === "Gestionnaire") {
                        console.log("Loading department projects for Gestionnaire...")
                        mainPage.projectController.loadProjectsByDepartment()
                    } else if (role === "Employe") {
                        console.log("Loading assigned projects for Employe...")
                        mainPage.projectController.loadProjectsByUser()
                    }
                } else {
                    console.log("WARNING: No valid user role - retrying in 100ms")
                    // User not set yet, try again in a moment
                    retryTimer.start()
                }
            }
        } else {
            console.log("ERROR: projectController is null")
        }
    }
    
    // Timer to retry loading if user isn't set yet
    Timer {
        id: retryTimer
        interval: 100
        repeat: false
        onTriggered: {
            console.log("Retrying initial data load...")
            loadInitialData()
        }
    }
}