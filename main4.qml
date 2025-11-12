import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    width: 800
    height: 800
    title: "Feuille de temps"
    visible: true

    // Données des projets |devra venir de la BD IG
    property var projects: [
        {
            name: "Projet 1 : Refonte du site web",
            employees: [
                { name: "EMPLOYÉ 1", hours: 12 },
                { name: "EMPLOYÉ 2", hours: 16 },
                { name: "EMPLOYÉ 3", hours: 8 }
            ],
            tasks: [
                { name: "Implémentation Frontend", hours: 17 },
                { name: "Intégration Backend", hours: 5 },
                { name: "Maquettes Design", hours: 10 }
            ]
        },
        {
            name: "Projet 2 : Développement d'application mobile",
            employees: [
                { name: "EMPLOYÉ 1", hours: 20 },
                { name: "EMPLOYÉ 2", hours: 14 },
                { name: "EMPLOYÉ 3", hours: 12 },
                { name: "EMPLOYÉ 4", hours: 8 }
            ],
            tasks: [
                { name: "Développement iOS", hours: 25 },
                { name: "Développement Android", hours: 18 },
                { name: "API Mobile", hours: 11 }
            ]
        },
        {
            name: "Projet 3 : Refactorisation de l'API backend",
            employees: [
                { name: "EMPLOYÉ 1", hours: 32 },
                { name: "EMPLOYÉ 2", hours: 24 }
            ],
            tasks: [
                { name: "Refactorisation API", hours: 40 },
                { name: "Tests unitaires", hours: 12 },
                { name: "Documentation", hours: 4 }
            ]
        }
    ]

    property int currentProjectIndex: 0

    function updateProjectData() {
        currentProjectIndex = projectComboBox.currentIndex
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

        // Section SÉLECTIONNER LE PROJET
        ColumnLayout {
            spacing: 10
            Layout.fillWidth: true

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

            // Liste déroulante des projets
            ComboBox {
                id: projectComboBox
                Layout.fillWidth: true
                model: projects.map(project => project.name)
                currentIndex: 0
                onCurrentIndexChanged: updateProjectData()
            }
        }

        // Section HEURES PAR EMPLOYÉ
        ColumnLayout {
            spacing: 10
            Layout.fillWidth: true

            Label {
                text: 'HEURES PAR EMPLOYÉ SUR "' + projects[currentProjectIndex].name.toUpperCase() + '"'
                font.bold: true
                font.pixelSize: 16
                wrapMode: Text.WordWrap
            }

            // Tableau des employés
            Rectangle {
                Layout.fillWidth: true
                height: Math.max(140, projects[currentProjectIndex].employees.length * 40 + 40)
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
                        model: projects[currentProjectIndex].employees
                        
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
                                    // Met à jour les données du projet
                                    projects[currentProjectIndex].employees[index].hours = value
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

            Label {
                text: 'HEURES PAR TÂCHE SUR "' + projects[currentProjectIndex].name.toUpperCase() + '"'
                font.bold: true
                font.pixelSize: 16
                wrapMode: Text.WordWrap
            }

            // Tableau des tâches
            Rectangle {
                Layout.fillWidth: true
                height: Math.max(140, projects[currentProjectIndex].tasks.length * 40 + 40)
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
                        model: projects[currentProjectIndex].tasks
                        
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
                                    // Met à jour les données du projet
                                    projects[currentProjectIndex].tasks[index].hours = value
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
            onClicked: {
                console.log("=== SAUVEGARDE DU PROJET ===")
                console.log("Projet:", projects[currentProjectIndex].name)
                console.log("--- Employés ---")
                for (let i = 0; i < projects[currentProjectIndex].employees.length; i++) {
                    console.log(projects[currentProjectIndex].employees[i].name + ":", 
                              projects[currentProjectIndex].employees[i].hours + " heures")
                }
                console.log("--- Tâches ---")
                for (let i = 0; i < projects[currentProjectIndex].tasks.length; i++) {
                    console.log(projects[currentProjectIndex].tasks[i].name + ":", 
                              projects[currentProjectIndex].tasks[i].hours + " heures")
                }
            }
        }

        // Espace vide
        Item {
            Layout.fillHeight: true
        }
    }
}
