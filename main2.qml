import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 6.5

Item {
    id: mainPage
    
    // Controller properties - these should be set from C++
    property var projectController
    property var taskController
    property var loginController  // ADD THIS
    
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
            text: "Déconnexion"
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
    
    // --- Menu de navigation ---
    Row {
        id: navigationMenu
        spacing: 15
        anchors.top: welcomeText.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        
        Button {
            text: "Tous les Projets"
            onClicked: {
                console.log("Chargement de tous les projets...")
                projectController.loadProjects()
            }
        }
        
        Button {
            text: "Mes Projets"
            onClicked: {
                console.log("Chargement de mes projets...")
                projectController.loadProjectsByUser()
            }
        }
        
        Button {
            text: "Projets Département"
            onClicked: {
                console.log("Chargement des projets du département...")
                projectController.loadProjectsByDepartment()
            }
        }
        
        Button {
            text: "Nouveau Projet"
            onClicked: {
                projectCreationDialog.open()
            }
        }
    }
    
    // --- ScrollView horizontale pour les projets ---
    ScrollView {
        id: scrollView
        width: parent.width * 0.9
        height: 300
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: navigationMenu.bottom
        anchors.topMargin: 30
        clip: true
        
        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AsNeeded
            height: 10
        }
        
        Row {
            id: projectRow
            spacing: 20
            padding: 10
            
            Repeater {
                id: projectRepeater
                model: projectController ? projectController.projects : []
                
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
                            text: "Coût: " + projectCost.toFixed(2) + " €"
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
                                console.log("taskController exists:", taskController !== null && taskController !== undefined)
                                console.log("projectDetailDialog exists:", typeof projectDetailDialog !== 'undefined')
        
                                if (taskController) {
                                    console.log("Setting current project ID...")
                                    taskController.setCurrentProjectId(projectId)
                                } else {
                                    console.log("ERROR: taskController is null!")
                                }
        
                                console.log("Setting dialog properties...")
                                projectDetailDialog.projectId = projectId
                                projectDetailDialog.projectName = projectName
        
                                console.log("Opening dialog...")
                                projectDetailDialog.open()
                                console.log("=== END OUVRIR ===")
                            }
                        }

                        Button {
                            text: "Supprimer"
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 80
                            background: Rectangle { 
                                color: "#dc3545"
                                radius: 4
                            }
                            contentItem: Text {
                                text: "Supprimer"
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                console.log("=== SUPPRIMER BUTTON CLICKED ===")
                                console.log("Project ID:", projectId)
                                console.log("Project Name:", projectName)
                                console.log("deleteProjectDialog exists:", typeof deleteProjectDialog !== 'undefined')
        
                                deleteProjectDialog.projectId = projectId
                                deleteProjectDialog.projectName = projectName
        
                                console.log("Opening delete dialog...")
                                deleteProjectDialog.open()
                                console.log("=== END SUPPRIMER ===")
                            }
                        }
                    }
                    /*
                    MouseArea {
                        anchors.fill: parent
                        propagateComposedEvents: true  // ADD THIS
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Projet cliqué:", projectId)
                            mouse.accepted = false  // ADD THIS - let clicks pass through to buttons
                        }
                    }*/
                }
            }
        }
    }
    
    // --- Indicateur de chargement ---
    BusyIndicator {
        id: loadingIndicator
        running: projectController ? projectController.loading : false
        visible: running
        anchors.centerIn: scrollView
        width: 50
        height: 50
    }
    
    // --- Bouton de gestion de temps ---
    Rectangle {
        width: 200
        height: 60
        radius: 10
        border.color: "black"
        border.width: 1
        color: "#e9ecef"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        
        Text {
            anchors.centerIn: parent
            text: "Gestion de Temps"
            color: "black"
            font.pointSize: 12
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("Gestion de temps cliquée")
                // TODO: Implement time management functionality
            }
            cursorShape: Qt.PointingHandCursor
        }
    }
    
    // --- Dialogue de création de projet ---
    Dialog {
        id: projectCreationDialog
        title: "Nouveau Projet"
        anchors.centerIn: parent
        width: 400
        height: 450
        modal: true
    
        property var clientsList: []
    
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
        
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
            
                Component.onCompleted: {
                    console.log("Client ComboBox created")
                    console.log("Model count:", count)
                }
                onModelChanged: {
                    console.log("ComboBox model changed, new count:", count)
                }
            }
        
            Label { text: "Répertoire"; font.bold: true }
            TextField {
                id: repositoryField
                placeholderText: "Répertoire du projet"
                Layout.fillWidth: true
            }
        
            Label { text: "Coűt du service (€)"; font.bold: true }
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
        
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10
            
                Button {
                    text: "Annuler"
                    onClicked: projectCreationDialog.close()
                }
            
                Button {
                    id: createProjectButton
                    text: "Créer"
                    enabled: projectNameField.text !== "" && clientComboBox.currentValue > 0
                    onClicked: {
                        console.log("Creating project with:", projectNameField.text, "client:", clientComboBox.currentValue)
                        var success = projectController.createProject(
                            projectNameField.text,
                            clientComboBox.currentValue,
                            repositoryField.text,
                            parseFloat(costField.text || "0"),
                            projectDateField.text
                        )
                    
                        if (success) {
                            projectCreationDialog.close()
                            resetForm()
                        }
                    }
                }
            }
        }
    
        function loadClientsData() {
            console.log("Loading clients data...")
            if (projectController) {
                var clients = projectController.getClients()
                console.log("Raw clients data:", clients)
                console.log("Number of clients:", clients.length)
        
                // Just use the clients directly - no need to add default option
                // since C++ already includes it
                projectCreationDialog.clientsList = clients
                console.log("Final clients list length:", projectCreationDialog.clientsList.length)
        
                // Force ComboBox refresh
                clientComboBox.model = projectCreationDialog.clientsList
                clientComboBox.currentIndex = 0
            }
        }
    
        function resetForm() {
            projectNameField.text = ""
            repositoryField.text = ""
            costField.text = "0.00"
            projectDateField.text = new Date().toISOString().split('T')[0]
            if (clientComboBox.count > 0) {
                clientComboBox.currentIndex = 0
            }
        }
    
        onOpened: {
            console.log("Project dialog opened - loading clients")
            loadClientsData()
            projectNameField.forceActiveFocus()
        }
    }
    
    // --- Dialogue de détail de projet ---
    Dialog {
        id: projectDetailDialog
        title: "Détails du Projet - " + projectName
        parent: Overlay.overlay  // ADD THIS - ensures dialog appears on top
        anchors.centerIn: parent
        width: 600
        height: 500
        modal: true
    
        property int projectId: 0
        property string projectName: ""
    
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
        
            Text {
                text: "Tâches du projet: " + projectDetailDialog.projectName
                font.bold: true
                font.pointSize: 14
                Layout.alignment: Qt.AlignHCenter
            }
        
            Button {
                text: "Nouvelle Tâche"
                onClicked: {
                    console.log("Opening task creation dialog for project:", projectDetailDialog.projectId)
                    taskCreationDialog.projectId = projectDetailDialog.projectId
                    taskCreationDialog.open()
                }
                Layout.alignment: Qt.AlignRight
            }
        
            ListView {
                id: taskListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: taskController ? taskController.tasks : []
                spacing: 5
                clip: true
            
                delegate: Rectangle {
                    required property var modelData
                    width: taskListView.width
                    height: 80
                    radius: 8
                    color: "#f8f9fa"
                    border.color: "#dee2e6"
                    border.width: 1
                
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                    
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                        
                            Text {
                                text: modelData.nomTache || "Sans nom"
                                font.bold: true
                                font.pointSize: 12
                                color: "#212529"
                            }
                        
                            Text {
                                text: modelData.descTache || "Aucune description"
                                font.pointSize: 10
                                color: "#6c757d"
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        
                            Text {
                                text: "Assigné à: " + (modelData.assigneeName || "Non assigné")
                                font.pointSize: 9
                                color: "#495057"
                            }
                        
                            Text {
                                text: "Temps estimé: " + (modelData.tempsTache || "00:00:00")
                                font.pointSize: 9
                                color: "#495057"
                            }
                        }
                    
                        Button {
                            text: "Sous-tâches"
                            onClicked: {
                                console.log("Voir sous-tâches pour:", modelData.idTache)
                                // TODO: Implement subtask view
                            }
                        }
                    
                        Button {
                            text: "Supprimer"
                            background: Rectangle { 
                                color: "#dc3545"
                                radius: 4
                            }
                            contentItem: Text {
                                text: "Supprimer"
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                console.log("Deleting task:", modelData.idTache)
                                taskController.deleteTask(modelData.idTache)
                            }
                        }
                    }
                }
            }
        
            Button {
                text: "Fermer"
                onClicked: projectDetailDialog.close()
                Layout.alignment: Qt.AlignRight
            }
        }
    
        onOpened: {
            console.log("=== PROJECT DETAIL DIALOG OPENED ===")
            console.log("Project ID:", projectId)
            console.log("Project Name:", projectName)
            console.log("taskController exists:", taskController !== null)
        
            if (projectId > 0 && taskController) {
                console.log("Loading tasks for project:", projectId)
                taskController.loadTasksForProject(projectId)
            } else {
                console.log("ERROR: Cannot load tasks - projectId:", projectId, "taskController:", taskController !== null)
            }
        }
    }
    
    Dialog {
        id: taskCreationDialog
        title: "Nouvelle Tâche"
        anchors.centerIn: parent
        parent: Overlay.overlay
        width: 400
        height: 450
        modal: true
    
        property int projectId: 0
        property var employeesList: []  // ADD THIS to store employees
    
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
        
            Label { text: "Nom de la tâche"; font.bold: true }
            TextField {
                id: taskNameField
                placeholderText: "Entrez le nom de la tâche"
                Layout.fillWidth: true
            }
        
            Label { text: "Description"; font.bold: true }
            TextArea {
                id: taskDescriptionField
                placeholderText: "Description de la tâche"
                Layout.fillWidth: true
                Layout.preferredHeight: 80
            }
        
            Label { text: "Assigné à"; font.bold: true }
            ComboBox {
                id: assigneeComboBox
                Layout.fillWidth: true
                model: taskCreationDialog.employeesList  // Use the dialog's property
                textRole: "fullName"
                valueRole: "idEmploye"
            
                Component.onCompleted: {
                    console.log("Assignee ComboBox created")
                }
            
                onModelChanged: {
                    console.log("Assignee ComboBox model changed, count:", count)
                }
            }
        
            Label { text: "Temps estimé (HH:MM:SS)"; font.bold: true }
            TextField {
                id: estimatedTimeField
                placeholderText: "00:00:00"
                Layout.fillWidth: true
                text: "00:00:00"
            }
        
            Label { text: "Date de la tâche"; font.bold: true }
            TextField {
                id: taskDateField
                placeholderText: "AAAA-MM-JJ"
                Layout.fillWidth: true
                text: new Date().toISOString().split('T')[0]
            }
        
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10
            
                Button {
                    text: "Annuler"
                    onClicked: taskCreationDialog.close()
                }
            
                Button {
                    text: "Créer"
                    enabled: taskNameField.text !== "" && taskCreationDialog.projectId > 0
                    onClicked: {
                        console.log("Creating task with assignee:", assigneeComboBox.currentValue)
                        var success = taskController.createTask(
                            taskCreationDialog.projectId,
                            taskNameField.text,
                            taskDescriptionField.text,
                            assigneeComboBox.currentValue || 0,
                            estimatedTimeField.text,
                            taskDateField.text
                        )
                    
                        if (success) {
                            taskCreationDialog.close()
                            resetForm()
                        }
                    }
                }
            }
        }
    
        function loadEmployees() {
            console.log("Loading employees for task assignment...")
            if (taskController) {
                var employees = taskController.getDepartmentEmployees()
                console.log("Got employees:", employees.length)
            
                // Create a new list with default option
                var newEmployeesList = []
            
                // Add default "Non assigné" option
                newEmployeesList.push({
                    "idEmploye": 0,
                    "fullName": "Non assigné"
                })
            
                // Add actual employees
                for (var i = 0; i < employees.length; i++) {
                    console.log("Employee:", employees[i].fullName)
                    newEmployeesList.push(employees[i])
                }
            
                // Update the property
                taskCreationDialog.employeesList = newEmployeesList
                console.log("Employees list updated, total:", taskCreationDialog.employeesList.length)
            
                // Force ComboBox refresh
                assigneeComboBox.model = taskCreationDialog.employeesList
                assigneeComboBox.currentIndex = 0
            }
        }
    
        function resetForm() {
            taskNameField.text = ""
            taskDescriptionField.text = ""
            estimatedTimeField.text = "00:00:00"
            taskDateField.text = new Date().toISOString().split('T')[0]
            if (assigneeComboBox.count > 0) {
                assigneeComboBox.currentIndex = 0
            }
        }
    
        onOpened: {
            console.log("=== TASK CREATION DIALOG OPENED ===")
            console.log("Project ID:", projectId)
            loadEmployees()  // LOAD EMPLOYEES WHEN DIALOG OPENS
            taskNameField.forceActiveFocus()
        }
    }
    
    // --- Dialogue de confirmation de suppression ---
    
    Dialog {
        id: deleteProjectDialog
        title: "Confirmation de suppression"
        parent: Overlay.overlay  // ADD THIS
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
                    background: Rectangle { 
                        color: "#dc3545"
                        radius: 4
                    }
                    contentItem: Text {
                        text: "Supprimer"
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        console.log("Deleting project:", deleteProjectDialog.projectId)
                        if (projectController) {
                            projectController.deleteProject(deleteProjectDialog.projectId)
                        }
                        deleteProjectDialog.close()
                    }
                }
            }
        }
    
        onOpened: {
            console.log("=== DELETE DIALOG OPENED ===")
            console.log("Project to delete:", projectName, "ID:", projectId)
        }
    }
    
    // --- Connexions aux signaux ---
    Connections {
        target: projectController
        
        function onProjectsChanged() {
            console.log("Liste des projets mise à jour")
        }
        
        function onProjectCreated(projectId) {
            console.log("Projet créé avec ID:", projectId)
        }
        
        function onProjectCreationFailed(error) {
            console.log("Erreur création projet:", error)
        }
        
        function onProjectDeleted(projectId) {
            console.log("Projet supprimé:", projectId)
        }
    }
    
    Connections {
        target: taskController
        
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
        console.log("MainPage chargée - Chargement des projets du département...")
        if (projectController) {
            projectController.loadProjectsByDepartment()
        }
    }
}