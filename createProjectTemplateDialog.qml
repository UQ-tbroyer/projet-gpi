import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 6.5

Dialog {
    id: createTemplateProjectDialog
    title: "Créer un projet à partir d'un template"
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel
    anchors.centerIn: parent
    width: 500

    property var projectController

    onAboutToShow: {
        templateProjectNameField.text = ""
        templateRepositoryField.text = ""
        templateCostField.text = "0.0"
        
        // Load clients
        var clients = projectController.getClients()
        templateClientCombo.model = clients
        templateClientCombo.currentIndex = -1
    }

    onAccepted: {
        if (!templateProjectNameField.text) {
            return
        }

        var clientId = -1
        if (templateClientCombo.currentIndex >= 0) {
            var clients = projectController.getClients()
            if (clients && clients.length > templateClientCombo.currentIndex) {
                clientId = clients[templateClientCombo.currentIndex].idClient
            }
        }

        var success = projectController.createProjectFromTemplate(
            templateProjectNameField.text,
            clientId,
            templateRepositoryField.text,
            parseFloat(templateCostField.text) || 0.0,
            ""
        )

        if (success) {
            console.log("Template project created successfully")
        }
    }

    contentItem: ColumnLayout {
        spacing: 15

        Label {
            text: "Créer un nouveau projet avec un template prédéfini"
            font.bold: true
            font.pixelSize: 16
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#e0e0e0"
        }

        Label {
            text: "Le template inclura 4 tâches prédéfinies:"
            font.bold: true
            Layout.fillWidth: true
        }

        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true

            Label {
                text: "• Planification et analyse des besoins (2 jours)"
                color: "gray"
            }
            Label {
                text: "• Conception et architecture (3 jours)" 
                color: "gray"
            }
            Label {
                text: "• Développement et implémentation (5 jours)"
                color: "gray"
            }
            Label {
                text: "• Tests et livraison finale (4 jours)"
                color: "gray"
            }
        }

        Label {
            text: "Durée totale: 2 semaines"
            font.italic: true
            color: "green"
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#e0e0e0"
        }

        GridLayout {
            columns: 2
            columnSpacing: 10
            rowSpacing: 10
            Layout.fillWidth: true

            Label { 
                text: "Nom du projet:" 
                Layout.alignment: Qt.AlignRight
            }
            TextField {
                id: templateProjectNameField
                placeholderText: "Nom du nouveau projet"
                Layout.fillWidth: true
            }

            Label { 
                text: "Client:" 
                Layout.alignment: Qt.AlignRight
            }
            ComboBox {
                id: templateClientCombo
                Layout.fillWidth: true
                textRole: "nomClient"
                displayText: currentIndex === -1 ? "Sélectionnez un client" : currentText
            }

            Label { 
                text: "Repository:" 
                Layout.alignment: Qt.AlignRight
            }
            TextField {
                id: templateRepositoryField
                placeholderText: "URL ou chemin du repository"
                Layout.fillWidth: true
            }

            Label { 
                text: "Coût du service:" 
                Layout.alignment: Qt.AlignRight
            }
            TextField {
                id: templateCostField
                placeholderText: "0.0"
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }
        }
    }
}