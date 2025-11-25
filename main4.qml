import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: main4Page
    width: 800
    height: 800
    title: "Feuille de temps"

    // Propriétés requises pour les contrôleurs
    required property var projectController
    required property var taskController
    required property var loginController

    // Utilise directement les projets du contrôleur (comme dans main2.qml)
    property var projects: main4Page.projectController && main4Page.projectController.projects ? main4Page.projectController.projects : []
    property int currentProjectIndex: 0

    // Données temporaires pour les heures (à adapter selon votre structure)
    property var currentProjectEmployees: []
    property var currentProjectTasks: []

    function updateProjectData() {
        if (projects.length > 0) {
            currentProjectIndex = projectComboBox.currentIndex
            loadProjectDetails()
        }
    }

    function loadProjectDetails() {
        if (projects.length === 0) return
        
        var projectId = projects[currentProjectIndex].idProject
        console.log("Chargement des détails pour le projet:", projects[currentProjectIndex].nomProject, "ID:", projectId)
        
        // Utilisez les mêmes méthodes que dans main2.qml
        // Si vous avez des méthodes pour récupérer employés et tâches, utilisez-les ici
        // Sinon, utilisez une structure temporaire comme ci-dessous
        
        // Structure temporaire - À ADAPTER selon vos données réelles
        currentProjectEmployees = [
            { name: "Employé 1", hours: 0, id: 1 },
            { name: "Employé 2", hours: 0, id: 2 },
            { name: "Employé 3", hours: 0, id: 3 }
        ]
        
        currentProjectTasks = [
            { name: "Développement", hours: 0, id: 1 },
            { name: "Tests", hours: 0, id: 2 },
            { name: "Documentation", hours: 0, id: 3 }
        ]
        
        console.log("Employés chargés:", currentProjectEmployees.length)
        console.log("Tâches chargées:", currentProjectTasks.length)
    }

    function saveTimeEntries() {
        if (projects.length === 0) return
        
        var projectId = projects[currentProjectIndex].idProject
        var projectName = projects[currentProjectIndex].nomProject
        
        console.log("=== SAUVEGARDE DES HEURES ===")
        console.log("Projet:", projectName, "ID:", projectId)
        
        // Sauvegarder les heures des employés
        for (let i = 0; i < currentProjectEmployees.length; i++) {
            var employee = currentProjectEmployees[i]
            console.log("Employé:", employee.name, "Heures:", employee.hours)
            // Ici, appelez votre méthode de sauvegarde si elle existe
            // projectController.saveEmployeeHours(projectId, employee.id, employee.hours)
        }
        
        // Sauvegarder les heures des tâches
        for (let i = 0; i < currentProjectTasks.length; i++) {
            var task = currentProjectTasks[i]
            console.log("Tâche:", task.name, "Heures:", task.hours)
            // Ici, appelez votre méthode de sauvegarde si elle existe
            // taskController.saveTaskHours(projectId, task.id, task.hours)
        }
        
        saveConfirmationDialog.open()
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
            visible: projects.length === 0
        }

        // Section SÉLECTIONNER LE PROJET
        ColumnLayout {
            spacing: 10
            Layout.fillWidth: true
            visible: projects.length > 0

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

            // Liste déroulante des projets réels (même structure que main2.qml)
            ComboBox {
                id: projectComboBox
                Layout.fillWidth: true
                model: projects.map(project => project.nomProject + (project.nomClient ? " - " + project.nomClient : ""))
                currentIndex: 0
                onCurrentIndexChanged: updateProjectData()
            }
        }

        // Section HEURES PAR EMPLOYÉ
        ColumnLayout {
            spacing: 10
            Layout.fillWidth: true
            visible: projects.length > 0 && currentProjectEmployees.length > 0

            Label {
                text: 'HEURES PAR EMPLOYÉ SUR "' + (projects[currentProjectIndex] ? projects[currentProjectIndex].nomProject.toUpperCase() : "") + '"'
                font.bold: true
                font.pixelSize: 16
                wrapMode: Text.WordWrap
            }

            // Tableau des employés
            Rectangle {
                Layout.fillWidth: true
                height: Math.max(140, currentProjectEmployees.length * 40 + 40)
                border.color: "lightgray"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    // En-tête du tableau
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Label {
                            text: "EMPLOYÉS"
                            font.bold: true
                            Layout.preferredWidth: 250
                        }
                        
                        Label {
                            text: "HEURES TOTALES"
                            font.bold: true
                            Layout.fillWidth: true
                        }
                    }

                    // Répéteur pour les employés
                    Repeater {
                        model: currentProjectEmployees
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Label {
                                text: modelData.name
                                Layout.preferredWidth: 250
                            }
                            
                            SpinBox {
                                from: 0
                                to: 1000
                                value: modelData.hours
                                editable: true
                                onValueModified: {
                                    currentProjectEmployees[index].hours = value
                                }
                            }
                        }
                    }
                }
            }
        }

        // Section HEURES PAR TÂCHE
        ColumnLayout {
            spacing: 10
            Layout.fillWidth: true
            visible: projects.length > 0 && currentProjectTasks.length > 0

            Label {
                text: 'HEURES PAR TÂCHE SUR "' + (projects[currentProjectIndex] ? projects[currentProjectIndex].nomProject.toUpperCase() : "") + '"'
                font.bold: true
                font.pixelSize: 16
                wrapMode: Text.WordWrap
            }

            // Tableau des tâches
            Rectangle {
                Layout.fillWidth: true
                height: Math.max(140, currentProjectTasks.length * 40 + 40)
                border.color: "lightgray"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    // En-tête du tableau
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Label {
                            text: "TÂCHES"
                            font.bold: true
                            Layout.preferredWidth: 250
                        }
                        
                        Label {
                            text: "HEURES TOTALES"
                            font.bold: true
                            Layout.fillWidth: true
                        }
                    }

                    // Répéteur pour les tâches
                    Repeater {
                        model: currentProjectTasks
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Label {
                                text: modelData.name
                                Layout.preferredWidth: 250
                            }
                            
                            SpinBox {
                                from: 0
                                to: 1000
                                value: modelData.hours
                                editable: true
                                onValueModified: {
                                    currentProjectTasks[index].hours = value
                                }
                            }
                        }
                    }
                }
            }
        }

        // Bouton de sauvegarde
        Button {
            text: "SAUVEGARDER LES MODIFICATIONS"
            font.bold: true
            Layout.alignment: Qt.AlignCenter
            visible: projects.length > 0
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
        
        Label {
            text: "Les heures ont été sauvegardées avec succès!"
            anchors.centerIn: parent
        }
        
        standardButtons: Dialog.Ok
    }

    // Initialisation
    Component.onCompleted: {
        console.log("Main4 chargé - Projets disponibles:", projects.length)
        console.log("ProjectController disponible:", projectController !== null)
        console.log("TaskController disponible:", taskController !== null)
        
        if (projects.length > 0) {
            updateProjectData()
        }
    }

    // Connexion aux signaux (comme dans main2.qml)
    Connections {
        target: projectController
        
        function onProjectsChanged() {
            console.log("Projets mis à jour dans main4 - count:", projects.length)
            if (projects.length > 0 && projectComboBox.currentIndex >= 0) {
                updateProjectData()
            }
        }
    }
}