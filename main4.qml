import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0

Page {
    id: main4Page
    width: 800
    height: 800
    title: "Feuille de temps"

    // Propriétés requises pour les contrôleurs
    required property var projectController
    required property var taskController
    required property var loginController

    // Utilise directement les projets du contrôleur
    property var projects: main4Page.projectController && main4Page.projectController.projects ? main4Page.projectController.projects : []
    property int currentProjectIndex: 0
    property int currentProjectId: -1

    // Données pour les heures
    property var currentProjectEmployees: []
    property var currentProjectTasks: []
    property var employeeTaskHours: ({}) // Stocke les heures par employé par tâche

    function updateProjectData() {
        if (main4Page.projects.length > 0) {
            main4Page.currentProjectIndex = projectComboBox.currentIndex
            loadProjectDetails()
        }
    }

   function loadProjectDetails() {
    if (main4Page.projects.length === 0) return
    
    main4Page.currentProjectId = main4Page.projects[main4Page.currentProjectIndex].idProject
    var projectName = main4Page.projects[main4Page.currentProjectIndex].nomProject
    console.log("Chargement des détails pour le projet:", projectName, "ID:", main4Page.currentProjectId)
    
    // Charger les employés disponibles
    loadAvailableEmployees()
    
    // Charger les tâches du projet
    loadProjectTasks()
    
    // Initialiser la structure des heures par employé par tâche
    initializeEmployeeTaskHours()
    
    // CHARGER LES HEURES EXISTANTES depuis la base de données
    loadExistingHours()
    }

    function isEmployeeRole() {
    if (!main4Page.projectController || !main4Page.projectController.getUserRole) return false
    return main4Page.projectController.getUserRole() === "Employe"
    }

    function getCurrentUserId() {
    if (!main4Page.projectController || !main4Page.projectController.getCurrentUserId) return -1
    return main4Page.projectController.getCurrentUserId()
    }

    function loadExistingHours() {
        if (main4Page.currentProjectId <= 0) return
    
        console.log("Chargement des heures existantes pour le projet:", main4Page.currentProjectId)
    
        try {
            // Pour chaque employé et chaque tâche, charger les heures depuis la BD
            for (var i = 0; i < main4Page.currentProjectEmployees.length; i++) {
                var employee = main4Page.currentProjectEmployees[i]
            
                for (var j = 0; j < main4Page.currentProjectTasks.length; j++) {
                    var task = main4Page.currentProjectTasks[j]
                
                    // Récupérer les heures depuis le contrôleur
                    var existingHours = taskController.getEmployeeTaskHours(
                        parseInt(main4Page.currentProjectId),
                        parseInt(employee.id),
                        parseInt(task.id)
                    )
                
                    if (existingHours > 0) {
                        console.log("Heures trouvées - Employé:", employee.id, "Tâche:", task.id, "Heures:", existingHours)
                        setEmployeeTaskHours(employee.id, task.id, existingHours)
                    }
                }
            }
            console.log("Chargement des heures existantes terminé")
        } catch (error) {
            console.error("Erreur lors du chargement des heures existantes:", error)
        }
    }
    function loadAvailableEmployees() {
    try {
        var employees = []
        
        if (isEmployeeRole()) {
            // Mode EMPLOYÉ : charger seulement l'utilisateur courant
            var currentUserId = getCurrentUserId()
            console.log("=== DEBUG MODE EMPLOYÉ ===")
            console.log("ID utilisateur courant:", currentUserId)
            console.log("Type de currentUserId:", typeof currentUserId)
            
            if (currentUserId > 0) {
                // Récupérer tous les employés d'abord pour debugger
                var allEmployees = taskController.getAvailableEmployees()
                console.log("Tous les employés disponibles:", allEmployees.length)
                
                // Afficher tous les employés pour debugger
                for (var i = 0; i < allEmployees.length; i++) {
                    var emp = allEmployees[i]
                    console.log("Employé", i, "ID:", emp.idEmploye || emp.id, "Type:", typeof (emp.idEmploye || emp.id))
                    console.log("  Nom:", emp.prenom + " " + emp.nom)
                }
                
                // Rechercher l'employé courant
                var currentEmployee = allEmployees.find(function(employee) {
                    var empId = employee.idEmploye || employee.id
                    console.log("Comparaison: currentUserId=", currentUserId, "empId=", empId, "Égal?", empId == currentUserId)
                    return empId == currentUserId
                })
                
                if (currentEmployee) {
                    employees = [currentEmployee]
                    console.log("✓ Employé courant trouvé:", currentEmployee.prenom + " " + currentEmployee.nom)
                } else {
                    console.error("✗ Employé courant NON trouvé avec ID:", currentUserId)
                    // Fallback: prendre le premier employé
                    if (allEmployees.length > 0) {
                        employees = [allEmployees[0]]
                        console.log("Fallback: utilisation du premier employé")
                    }
                }
            }
        } else {
            // Mode GESTIONNAIRE : charger tous les employés
            employees = taskController.getAvailableEmployees()
            console.log("Mode gestionnaire - Chargement de tous les employés:", employees.length)
        }
        
        if (employees && employees.length > 0) {
            main4Page.currentProjectEmployees = employees.map(function(employee) {
                return {
                    id: employee.idEmploye || employee.id,
                    name: (employee.prenomEmploye || employee.prenom) + " " + (employee.nomEmploye || employee.nom),
                    totalHours: 0
                }
            })
            console.log("Employés chargés:", main4Page.currentProjectEmployees.length)
        } else {
            console.warn("Aucun employé trouvé")
            main4Page.currentProjectEmployees = []
        }
    } catch (error) {
        console.error("Erreur lors du chargement des employés:", error)
        main4Page.currentProjectEmployees = []
    }
}

    function loadProjectTasks() {
        try {
            if (main4Page.currentProjectId <= 0) return
            
            // Utiliser la méthode du taskController pour récupérer les tâches
            var tasks = taskController.getTasksForProject(main4Page.currentProjectId)
            if (tasks && tasks.length > 0) {
                main4Page.currentProjectTasks = tasks.map(function(task) {
                    return {
                        id: task.idTache || task.id,
                        name: task.nomTache || task.nom,
                        totalHours: task.tempsTache ? task.tempsTache / 60.0 : 0, // Convertir minutes en heures
                        originalHours: task.tempsTache ? task.tempsTache / 60.0 : 0
                    }
                })
                console.log("Tâches chargées:", main4Page.currentProjectTasks.length)
            } else {
                console.log("Aucune tâche trouvée pour ce projet")
                main4Page.currentProjectTasks = []
            }
        } catch (error) {
            console.error("Erreur lors du chargement des tâches:", error)
            main4Page.currentProjectTasks = []
        }
    }

    function initializeEmployeeTaskHours() {
        // Initialiser la structure pour stocker les heures par employé par tâche
        main4Page.employeeTaskHours = {}
        
        for (var i = 0; i < main4Page.currentProjectEmployees.length; i++) {
            var employee = main4Page.currentProjectEmployees[i]
            main4Page.employeeTaskHours[employee.id] = {}
            
            for (var j = 0; j < main4Page.currentProjectTasks.length; j++) {
                var task = main4Page.currentProjectTasks[j]
                main4Page.employeeTaskHours[employee.id][task.id] = 0
            }
        }
        console.log("Structure heures employé-tâche initialisée")
    }

    function getEmployeeTaskHours(employeeId, taskId) {
        if (main4Page.employeeTaskHours[employeeId] && main4Page.employeeTaskHours[employeeId][taskId] !== undefined) {
            return main4Page.employeeTaskHours[employeeId][taskId]
        }
        return 0
    }

    function setEmployeeTaskHours(employeeId, taskId, hours) {
        if (!main4Page.employeeTaskHours[employeeId]) {
            main4Page.employeeTaskHours[employeeId] = {}
        }
        main4Page.employeeTaskHours[employeeId][taskId] = hours
        
        // Mettre à jour le total des heures de l'employé
        updateEmployeeTotalHours(employeeId)
        
        // Mettre à jour le total des heures de la tâche
        updateTaskTotalHours(taskId)
        
        // Forcer la mise à jour de l'interface
        main4Page.currentProjectEmployeesChanged()
        main4Page.currentProjectTasksChanged()
    }

    function updateEmployeeTotalHours(employeeId) {
        var total = 0
        if (main4Page.employeeTaskHours[employeeId]) {
            for (var taskId in main4Page.employeeTaskHours[employeeId]) {
                total += main4Page.employeeTaskHours[employeeId][taskId]
            }
        }
        
        // Mettre à jour l'employé dans la liste
        for (var i = 0; i < main4Page.currentProjectEmployees.length; i++) {
            if (main4Page.currentProjectEmployees[i].id === employeeId) {
                main4Page.currentProjectEmployees[i].totalHours = total
                break
            }
        }
    }

    function updateTaskTotalHours(taskId) {
        var total = 0
        for (var employeeId in main4Page.employeeTaskHours) {
            if (main4Page.employeeTaskHours[employeeId][taskId]) {
                total += main4Page.employeeTaskHours[employeeId][taskId]
            }
        }
        
        // Mettre à jour la tâche dans la liste
        for (var i = 0; i < main4Page.currentProjectTasks.length; i++) {
            if (main4Page.currentProjectTasks[i].id === taskId) {
                main4Page.currentProjectTasks[i].totalHours = total
                break
            }
        }
    }

    function saveTimeEntries() {
        if (main4Page.projects.length === 0 || main4Page.currentProjectId <= 0) {
            showError("Aucun projet sélectionné")
            return
        }
        
        var projectName = main4Page.projects[main4Page.currentProjectIndex].nomProject
        var hasChanges = false
        var successCount = 0
        var errorCount = 0
        
        console.log("=== SAUVEGARDE DES HEURES ===")
        console.log("Projet:", projectName, "ID:", main4Page.currentProjectId)
        
        // Sauvegarder les heures par employé par tâche
        for (var employeeId in main4Page.employeeTaskHours) {
            for (var taskId in main4Page.employeeTaskHours[employeeId]) {
                var hours = main4Page.employeeTaskHours[employeeId][taskId]
                if (hours > 0) {
                    console.log("Sauvegarde heures - Projet:", main4Page.currentProjectId, 
                              "Employé:", employeeId, "Tâche:", taskId, "Heures:", hours)
                    
                    try {
                        // Appeler la méthode avec les bons paramètres dans le bon ordre
                        var success = taskController.saveEmployeeTaskHours(
                            parseInt(main4Page.currentProjectId),
                            parseInt(employeeId),
                            parseInt(taskId),
                            hours  // Déjà en heures, pas besoin de conversion
                        )
                        
                        if (success) {
                            console.log("✓ Heures sauvegardées pour employé", employeeId, "tâche", taskId)
                            successCount++
                            hasChanges = true
                        } else {
                            console.error("✗ Échec sauvegarde heures pour employé", employeeId, "tâche", taskId)
                            errorCount++
                        }
                    } catch (error) {
                        console.error("Erreur lors de la sauvegarde:", error)
                        errorCount++
                    }
                }
            }
        }
        
        if (hasChanges) {
            if (errorCount === 0) {
                saveConfirmationDialog.text = "Toutes les heures ont été sauvegardées avec succès! (" + successCount + " entrées)"
                saveConfirmationDialog.open()
            } else {
                showError("Certaines heures n'ont pas pu être sauvegardées. Réussites: " + successCount + ", Échecs: " + errorCount)
            }
        } else {
            showInfo("Aucune modification à sauvegarder")
        }
    }

    function showError(message) {
        errorDialog.text = message
        errorDialog.open()
    }

    function showInfo(message) {
        infoDialog.text = message
        infoDialog.open()
    }

    // Bouton retour
    Button {
        text: "← Retour"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        z: 1000
        
        onClicked: {
            if (main4Page.parent && main4Page.parent.pop) {
                main4Page.parent.pop()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Titre principal
        Label {
            text: "FEUILLE DE TEMPS"
            font.bold: true
            font.pixelSize: 24
            Layout.alignment: Qt.AlignCenter
        }

        // Message si aucun projet
        Label {
            text: "Aucun projet disponible"
            font.pixelSize: 16
            color: "gray"
            Layout.alignment: Qt.AlignCenter
            visible: main4Page.projects.length === 0
        }

        // Section SÉLECTIONNER LE PROJET
        ColumnLayout {
            spacing: 10
            Layout.fillWidth: true
            visible: main4Page.projects.length > 0

            Label {
                text: "SÉLECTIONNER LE PROJET :"
                font.bold: true
                font.pixelSize: 16
            }

            Label {
                text: "AJOUTER UNE NOUVELLE ENTRÉE D'HEURES"
                font.pixelSize: 14
                color: "gray"
            }

            // Liste déroulante des projets réels
            ComboBox {
                id: projectComboBox
                Layout.fillWidth: true
                model: main4Page.projects.map(project => project.nomProject + (project.nomClient ? " - " + project.nomClient : ""))
                currentIndex: 0
                onCurrentIndexChanged: updateProjectData()
            }
        }

        // Section HEURES PAR EMPLOYÉ
        ColumnLayout {
            spacing: 10
            Layout.fillWidth: true
            visible: main4Page.projects.length > 0 && main4Page.currentProjectEmployees.length > 0 && !isEmployeeRole()

           // Section HEURES PAR EMPLOYÉ - Titre conditionnel
            Label {
                text: {
                    if (isEmployeeRole()) {
                        return 'MES HEURES SUR "' + (main4Page.projects[main4Page.currentProjectIndex] ? main4Page.projects[main4Page.currentProjectIndex].nomProject.toUpperCase() : "") + '"'
                    } else {
                        return 'HEURES PAR EMPLOYÉ SUR "' + (main4Page.projects[main4Page.currentProjectIndex] ? main4Page.projects[main4Page.currentProjectIndex].nomProject.toUpperCase() : "") + '"'
                    }
                }
                font.bold: true
                font.pixelSize: 16
                wrapMode: Text.WordWrap
            }

            // Tableau des employés avec heures totales
            Rectangle {
                Layout.fillWidth: true
                height: Math.min(400, Math.max(140, main4Page.currentProjectEmployees.length * 50 + 40))
                border.color: "lightgray"
                border.width: 1
                clip: true

                ScrollView {
                    anchors.fill: parent
                    contentWidth: parent.width
                    contentHeight: Math.max(140, main4Page.currentProjectEmployees.length * 50 + 40)

                    ColumnLayout {
                        width: parent.width
                        anchors.margins: 10
                        spacing: 5

                        // En-tête du tableau
                        RowLayout {
                            width: parent.width
                            
                            Label {
                                text: "EMPLOYÉS"
                                font.bold: true
                                Layout.preferredWidth: 300
                            }
                            
                            Label {
                                text: "HEURES TOTALES"
                                font.bold: true
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        // Répéteur pour les employés
                        Repeater {
                            model: main4Page.currentProjectEmployees
                            
                            RowLayout {
                                width: parent.width
                                spacing: 10
                                
                                Label {
                                    text: modelData.name
                                    Layout.preferredWidth: 300
                                    elide: Text.ElideRight
                                    font.bold: true
                                }
                                
                                Label {
                                    text: modelData.totalHours.toFixed(1) + " h"
                                    font.bold: true
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    background: Rectangle {
                                        color: "#f0f0f0"
                                        radius: 5
                                    }
                                    padding: 5
                                }
                            }
                        }
                    }
                }
            }
        }

        // Section DÉTAIL DES HEURES PAR TÂCHE (avec slider)
       ColumnLayout {
        spacing: 10
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: main4Page.projects.length > 0 && main4Page.currentProjectEmployees.length > 0 && main4Page.currentProjectTasks.length > 0

        Label {
            text: {
                if (isEmployeeRole()) {
                    return 'MES HEURES PAR TÂCHE'
                } else {
                    return 'DÉTAIL DES HEURES PAR TÂCHE'
                }
            }
            font.bold: true
            font.pixelSize: 16
            wrapMode: Text.WordWrap
        }

            // Conteneur avec slider pour les boîtes d'ajout d'heures
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                border.color: "lightgray"
                border.width: 1
                radius: 5
                clip: true

                ScrollView {
                    id: employeeTasksScrollView
                    anchors.fill: parent
                    anchors.margins: 5
                    contentWidth: parent.width - 20

                    ColumnLayout {
                        id: employeeTasksColumn
                        width: parent.width
                        spacing: 10

                        // Répéteur pour chaque employé
                        Repeater {
                            model: main4Page.currentProjectEmployees
                            
                            Rectangle {
                                id: employeeCard
                                Layout.fillWidth: true
                                height: taskColumn.height + 40
                                border.color: "#d0d0d0"
                                border.width: 1
                                radius: 5
                                
                                property var currentEmployee: modelData
                                
                                ColumnLayout {
                                    id: taskColumn
                                    width: parent.width
                                    anchors.margins: 10
                                    spacing: 5
                                    
                                    // En-tête de l'employé
                                    Label {
                                        text: employeeCard.currentEmployee.name + " - Heures par tâche:"
                                        font.bold: true
                                        font.pixelSize: 14
                                        color: "#2c3e50"
                                        Layout.topMargin: 10
                                        Layout.leftMargin: 10
                                    }
                                    
                                    // Répéteur pour les tâches de cet employé
                                    Repeater {
                                        model: main4Page.currentProjectTasks
                                        
                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.leftMargin: 20
                                            Layout.rightMargin: 20
                                            spacing: 10
                                            
                                            property var currentTask: modelData
                                            property var currentEmployee: employeeCard.currentEmployee
                                            
                                            Label {
                                                text: currentTask.name
                                                Layout.preferredWidth: 200
                                                elide: Text.ElideRight
                                            }
                                            
                                            // Bouton -
                                            Button {
                                                text: "-"
                                                width: 30
                                                height: 30
                                                onClicked: {
                                                    var currentHours = getEmployeeTaskHours(parent.currentEmployee.id, parent.currentTask.id)
                                                    if (currentHours > 0) {
                                                        var newHours = currentHours - 0.5
                                                        setEmployeeTaskHours(parent.currentEmployee.id, parent.currentTask.id, Math.max(0, newHours))
                                                    }
                                                }
                                            }
                                            
                                            // Affichage des heures
                                            Label {
                                                text: getEmployeeTaskHours(parent.currentEmployee.id, parent.currentTask.id).toFixed(1) + " h"
                                                Layout.preferredWidth: 60
                                                horizontalAlignment: Text.AlignHCenter
                                                font.bold: true
                                                background: Rectangle {
                                                    color: "#e8f4fd"
                                                    border.color: "#3498db"
                                                    border.width: 1
                                                    radius: 3
                                                }
                                                padding: 5
                                            }
                                            
                                            // Bouton +
                                            Button {
                                                text: "+"
                                                width: 30
                                                height: 30
                                                onClicked: {
                                                    var currentHours = getEmployeeTaskHours(parent.currentEmployee.id, parent.currentTask.id)
                                                    var newHours = currentHours + 0.5
                                                    setEmployeeTaskHours(parent.currentEmployee.id, parent.currentTask.id, newHours)
                                                }
                                            }
                                            
                                            // Total de la tâche (pour information)
                                            Label {
                                                text: "Total tâche: " + parent.currentTask.totalHours.toFixed(1) + " h"
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignRight
                                                color: "gray"
                                                font.pixelSize: 12
                                            }
                                        }
                                    }
                                    
                                    // Séparateur
                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 1
                                        color: "lightgray"
                                        Layout.topMargin: 5
                                        Layout.bottomMargin: 5
                                    }
                                }
                            }
                        }
                    }
                }

                // Indicateur de scroll (optionnel)
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 100
                    height: 20
                    color: "transparent"
                    visible: employeeTasksScrollView.contentHeight > employeeTasksScrollView.height

                    Label {
                        anchors.centerIn: parent
                        text: "↓ Défiler ↓"
                        color: "gray"
                        font.pixelSize: 10
                    }
                }
            }
        }

        // Message si pas d'employés/tâches
        Label {
            text: "Aucun employé ou tâche trouvé pour ce projet"
            font.pixelSize: 14
            color: "gray"
            Layout.alignment: Qt.AlignCenter
            visible: main4Page.projects.length > 0 && (main4Page.currentProjectEmployees.length === 0 || main4Page.currentProjectTasks.length === 0)
        }

        // Bouton de sauvegarde
        Button {
            text: "SAUVEGARDER LES MODIFICATIONS"
            font.bold: true
            Layout.alignment: Qt.AlignCenter
            visible: main4Page.projects.length > 0 && main4Page.currentProjectEmployees.length > 0 && main4Page.currentProjectTasks.length > 0
            onClicked: saveTimeEntries()
        }

        // Espace vide
        Item {
            Layout.fillHeight: true
        }
    }

    // Dialogue de confirmation
    Dialog {
        id: saveConfirmationDialog
        title: "Sauvegarde réussie"
        anchors.centerIn: parent
        width: 300
        height: 150
        modal: true
        
        property string text: ""
        
        Label {
            text: saveConfirmationDialog.text
            anchors.centerIn: parent
            wrapMode: Text.WordWrap
        }
        
        standardButtons: Dialog.Ok
    }

    // Dialogue d'erreur
    Dialog {
        id: errorDialog
        title: "Erreur"
        anchors.centerIn: parent
        width: 300
        height: 150
        modal: true
        
        property string text: ""
        
        Label {
            text: errorDialog.text
            anchors.centerIn: parent
            wrapMode: Text.WordWrap
        }
        
        standardButtons: Dialog.Ok
    }

    // Dialogue d'information
    Dialog {
        id: infoDialog
        title: "Information"
        anchors.centerIn: parent
        width: 300
        height: 150
        modal: true
        
        property string text: ""
        
        Label {
            text: infoDialog.text
            anchors.centerIn: parent
            wrapMode: Text.WordWrap
        }
        
        standardButtons: Dialog.Ok
    }

    // Initialisation
    Component.onCompleted: {
        console.log("Main4 chargé - Projets disponibles:", main4Page.projects.length)
        console.log("ProjectController disponible:", projectController !== null)
        console.log("TaskController disponible:", taskController !== null)
        
        if (main4Page.projects.length > 0) {
            updateProjectData()
        }
    }

    // Connexion aux signaux
    Connections {
        target: projectController
        
        function onProjectsChanged() {
            console.log("Projets mis à jour dans main4 - count:", main4Page.projects.length)
            if (main4Page.projects.length > 0 && projectComboBox.currentIndex >= 0) {
                updateProjectData()
            }
        }
    }
    
    Connections {
        target: taskController
        
        function onTaskHoursSaved(projectId, taskId, hours) {
            console.log("Heures tâche sauvegardées - Projet:", projectId, "Tâche:", taskId, "Heures:", hours)
        }
        
        function onTaskHoursSaveFailed(errorMessage) {
            console.error("Échec sauvegarde heures tâche:", errorMessage)
            showError("Erreur sauvegarde heures tâche: " + errorMessage)
        }
    }

    Settings {
        id: settings
    }
}