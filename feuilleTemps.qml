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
    property var currentSubTasks: ({}) // Stocke les sous-tâches par tâche parente
    property var employeeTaskHours: ({}) // Stocke les heures par employé par tâche
    property var employeeSubTaskHours: ({}) // Stocke les heures par employé par sous-tâche

    // Propriétés pour les totaux
    property real projectTotalHours: 0
    property real projectOriginalHours: 0 // Total des heures originales des tâches

    function updateProjectData() {
        if (main4Page.projects.length > 0 && projectComboBox && projectComboBox.currentIndex >= 0) {
            main4Page.currentProjectIndex = projectComboBox.currentIndex
            loadProjectDetails()
        } else {
            console.warn("Impossible de mettre à jour les données: projets=" + main4Page.projects.length + 
                        ", comboBox=" + (projectComboBox ? "disponible" : "indisponible") +
                        ", index=" + (projectComboBox ? projectComboBox.currentIndex : "N/A"))
        }
    }

    function loadProjectDetails() {
        if (main4Page.projects.length === 0) return
        
        main4Page.currentProjectId = main4Page.projects[main4Page.currentProjectIndex].idProject
        var projectName = main4Page.projects[main4Page.currentProjectIndex].nomProject
        console.log("Chargement des détails pour le projet:", projectName, "ID:", main4Page.currentProjectId)
        
        // Réinitialiser les totaux
        main4Page.projectTotalHours = 0
        main4Page.projectOriginalHours = 0
        
        // Charger les employés disponibles
        loadAvailableEmployees()
        
        // Charger les tâches du projet
        loadProjectTasks()
        
        // Initialiser la structure des heures par employé par tâche
        initializeEmployeeTaskHours()
        
        // CHARGER LES HEURES EXISTANTES depuis la base de données
        loadExistingHours()
        
        // CALCULER LE TOTAL INITIAL DU PROJET
        calculateProjectTotalHours()
    }

    function isEmployeeRole() {
        if (!main4Page.projectController || !main4Page.projectController.getUserRole) return false
        return main4Page.projectController.getUserRole() === "Employe"
    }

    function getCurrentUserId() {
        if (!main4Page.projectController || !main4Page.projectController.getCurrentUserId) return -1
        return main4Page.projectController.getCurrentUserId()
    }

    function loadSubTasksForAllTasks() {
        try {
            main4Page.currentSubTasks = {}
            var subTaskCount = 0
            
            console.log("=== CHARGEMENT DES SOUS-TÂCHES RÉELLES ===")
            
            for (var i = 0; i < main4Page.currentProjectTasks.length; i++) {
                var parentTask = main4Page.currentProjectTasks[i]
                
                console.log("Recherche sous-tâches pour:", parentTask.name, "ID:", parentTask.id)
                
                // Vérifier que la méthode existe
                if (typeof taskController.getSubTasksByTask !== 'function') {
                    console.error("❌ La méthode getSubTasksByTask n'existe pas dans TaskController")
                    return
                }
                
                try {
                    var subTasks = taskController.getSubTasksByTask(parentTask.id)
                    
                    console.log("Résultat getSubTasksByTask pour", parentTask.id + ":", subTasks.length, "sous-tâches")
                    
                    if (subTasks && subTasks.length > 0) {
                        console.log("✅ Sous-tâches trouvées pour", parentTask.name + ":", subTasks.length)
                        
                        main4Page.currentSubTasks[parentTask.id] = subTasks.map(function(subTask) {
                            return {
                                id: subTask.idTache || subTask.id,
                                parentId: parentTask.id,
                                name: subTask.nomTache || subTask.nom,
                                totalHours: 0, // Initialisé à 0
                                originalHours: subTask.tempsTache ? subTask.tempsTache / 60.0 : 0,
                                assignedEmployeeId: subTask.memProcessigner,
                                assigneeName: subTask.assigneeName || "",
                                description: subTask.descTache || "",
                                state: subTask.etat || "",
                                isSubTask: true
                            }
                        })
                        
                        parentTask.hasSubTasks = true
                        subTaskCount += subTasks.length
                        
                        // Debug détaillé des sous-tâches
                        console.log("Détail des sous-tâches pour", parentTask.name + ":")
                        for (var j = 0; j < main4Page.currentSubTasks[parentTask.id].length; j++) {
                            var st = main4Page.currentSubTasks[parentTask.id][j]
                            console.log("  -", st.name, 
                                      "ID:", st.id, 
                                      "Employé:", st.assignedEmployeeId,
                                      "Heures prévues:", st.originalHours + "h")
                        }
                    } else {
                        console.log("❌ Aucune sous-tâche pour", parentTask.name)
                        parentTask.hasSubTasks = false
                    }
                } catch (error) {
                    console.error("💥 Erreur lors du chargement des sous-tâches pour", parentTask.name + ":", error)
                    parentTask.hasSubTasks = false
                }
            }
            
            console.log("=== CHARGEMENT SOUS-TÂCHES TERMINÉ ===")
            console.log("📊 Sous-tâches chargées:", subTaskCount, "pour", Object.keys(main4Page.currentSubTasks).length, "tâches parentes")
            
            // Debug final
            if (subTaskCount === 0) {
                console.warn("⚠️ Aucune sous-tâche n'a été chargée. Vérifiez:")
                console.warn("  1. La méthode getSubTasksByTask dans TaskController")
                console.warn("  2. Les données dans la table tache (colonnes idParentTache)")
                console.warn("  3. Les IDs des tâches parentes")
            }
            
        } catch (error) {
            console.error("💥 Erreur générale chargement sous-tâches:", error)
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
                
                if (currentUserId > 0) {
                    var allEmployees = taskController.getAvailableEmployees()
                    console.log("Tous les employés disponibles:", allEmployees.length)
                    
                    // Rechercher l'employé courant
                    var currentEmployee = allEmployees.find(function(employee) {
                        var empId = employee.idEmploye || employee.id
                        return empId == currentUserId
                    })
                    
                    if (currentEmployee) {
                        employees = [currentEmployee]
                        console.log("✓ Employé courant trouvé:", currentEmployee.prenom + " " + currentEmployee.nom)
                    } else {
                        console.error("✗ Employé courant NON trouvé avec ID:", currentUserId)
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
            
            var allTasks = taskController.getTasksForProject(main4Page.currentProjectId)
            
            if (!allTasks || allTasks.length === 0) {
                console.log("Aucune tâche trouvée pour ce projet")
                main4Page.currentProjectTasks = []
                return
            }
            
            console.log("=== CHARGEMENT TÂCHES ===")
            console.log("Projet ID:", main4Page.currentProjectId)
            console.log("Rôle:", isEmployeeRole() ? "Employé" : "Gestionnaire")
            console.log("Tâches totales:", allTasks.length)
            
            var filteredTasks = []
            var currentUserId = getCurrentUserId()
            
            if (isEmployeeRole()) {
                console.log("=== FILTRAGE POUR EMPLOYÉ ===")
                console.log("ID employé courant:", currentUserId)
                
                // Filtrer par memProcessigner
                filteredTasks = allTasks.filter(function(task) {
                    var assignedId = task.memProcessigner
                    var isAssigned = assignedId !== undefined && assignedId !== null && 
                                   Number(assignedId) === Number(currentUserId)
                    
                    if (isAssigned) {
                        console.log("✓ Tâche assignée:", task.nomTache || task.nom)
                    }
                    return isAssigned
                })
                
                console.log("Tâches assignées trouvées:", filteredTasks.length)
                
                if (filteredTasks.length === 0) {
                    console.log("Aucune tâche assignée, utilisation du fallback")
                    filteredTasks = allTasks
                }
                
            } else {
                filteredTasks = allTasks
            }
            
            main4Page.currentProjectTasks = filteredTasks.map(function(task) {
                return {
                    id: task.idTache || task.id,
                    name: task.nomTache || task.nom,
                    totalHours: task.tempsTache ? task.tempsTache / 60.0 : 0,
                    originalHours: task.tempsTache ? task.tempsTache / 60.0 : 0,
                    assignedEmployeeId: task.memProcessigner,
                    hasSubTasks: false // Sera mis à jour après le chargement des sous-tâches
                }
            })
            
            console.log("✓ Tâches chargées:", main4Page.currentProjectTasks.length)
            
            // CHARGER LES SOUS-TÂCHES pour chaque tâche
            loadSubTasksForAllTasks()
            
        } catch (error) {
            console.error("Erreur chargement tâches:", error)
            main4Page.currentProjectTasks = []
        }
    }

    function initializeEmployeeTaskHours() {
        main4Page.employeeTaskHours = {}
        main4Page.employeeSubTaskHours = {}
        
        console.log("Initialisation des structures heures...")
        console.log("Employés:", main4Page.currentProjectEmployees.length)
        console.log("Tâches:", main4Page.currentProjectTasks.length)
        
        for (var i = 0; i < main4Page.currentProjectEmployees.length; i++) {
            var employee = main4Page.currentProjectEmployees[i]
            main4Page.employeeTaskHours[employee.id] = {}
            main4Page.employeeSubTaskHours[employee.id] = {}
            
            // Initialiser les heures pour les tâches principales
            for (var j = 0; j < main4Page.currentProjectTasks.length; j++) {
                var task = main4Page.currentProjectTasks[j]
                main4Page.employeeTaskHours[employee.id][task.id] = 0
                
                // Initialiser les heures pour les sous-tâches de cette tâche
                if (main4Page.currentSubTasks[task.id]) {
                    for (var k = 0; k < main4Page.currentSubTasks[task.id].length; k++) {
                        var subTask = main4Page.currentSubTasks[task.id][k]
                        if (!main4Page.employeeSubTaskHours[employee.id][task.id]) {
                            main4Page.employeeSubTaskHours[employee.id][task.id] = {}
                        }
                        main4Page.employeeSubTaskHours[employee.id][task.id][subTask.id] = 0
                    }
                }
            }
        }
        console.log("Structure heures employé-tâche-sous-tâche initialisée")
    }

    function getEmployeeTaskHours(employeeId, taskId) {
        if (!employeeId || !taskId) return 0
        if (main4Page.employeeTaskHours[employeeId] && main4Page.employeeTaskHours[employeeId][taskId] !== undefined) {
            return main4Page.employeeTaskHours[employeeId][taskId]
        }
        return 0
    }

    function getEmployeeSubTaskHours(employeeId, parentTaskId, subTaskId) {
        if (!employeeId || !parentTaskId || !subTaskId) return 0
        
        if (main4Page.employeeSubTaskHours[employeeId] && 
            main4Page.employeeSubTaskHours[employeeId][parentTaskId] &&
            main4Page.employeeSubTaskHours[employeeId][parentTaskId][subTaskId] !== undefined) {
            return main4Page.employeeSubTaskHours[employeeId][parentTaskId][subTaskId]
        }
        return 0
    }

    function setEmployeeSubTaskHours(employeeId, parentTaskId, subTaskId, hours) {
        if (!employeeId || !parentTaskId || !subTaskId) {
            console.error("setEmployeeSubTaskHours: paramètres manquants")
            return
        }
    
        console.log("=== SET HEURES SOUS-TÂCHE ===")
        console.log("Employé:", employeeId, "Parent:", parentTaskId, "Sous-tâche:", subTaskId, "Heures:", hours)
    
        if (!main4Page.employeeSubTaskHours[employeeId]) {
            main4Page.employeeSubTaskHours[employeeId] = {}
        }
        if (!main4Page.employeeSubTaskHours[employeeId][parentTaskId]) {
            main4Page.employeeSubTaskHours[employeeId][parentTaskId] = {}
        }
    
        main4Page.employeeSubTaskHours[employeeId][parentTaskId][subTaskId] = hours
    
        // Mettre à jour le total de la sous-tâche
        updateSubTaskTotalHours(parentTaskId, subTaskId)
    
        // Mettre à jour le total de la tâche parente
        updateTaskTotalHours(parentTaskId)
    
        // RECALCULER LE TOTAL DU PROJET
        calculateProjectTotalHours()
    
        // FORCER LA MISE À JOUR DE L'INTERFACE
        main4Page.employeeSubTaskHoursChanged()
        main4Page.currentProjectTasksChanged()
        main4Page.currentSubTasksChanged()
    
        // Forcer spécifiquement la mise à jour de la tâche parente
        refreshTaskInList(parentTaskId)
    }

    function updateSubTaskTotalHours(parentTaskId, subTaskId) {
        var total = 0
        for (var employeeId in main4Page.employeeSubTaskHours) {
            if (main4Page.employeeSubTaskHours[employeeId][parentTaskId] &&
                main4Page.employeeSubTaskHours[employeeId][parentTaskId][subTaskId]) {
                total += main4Page.employeeSubTaskHours[employeeId][parentTaskId][subTaskId]
            }
        }
        
        console.log("Mise à jour total sous-tâche - Parent:", parentTaskId, 
                    "Sous-tâche:", subTaskId, 
                    "Total:", total)
        
        // Mettre à jour la sous-tâche dans la liste
        if (main4Page.currentSubTasks[parentTaskId]) {
            for (var i = 0; i < main4Page.currentSubTasks[parentTaskId].length; i++) {
                if (main4Page.currentSubTasks[parentTaskId][i].id === subTaskId) {
                    main4Page.currentSubTasks[parentTaskId][i].totalHours = total
                    break
                }
            }
        }
    }

    function loadExistingHours() {
        if (main4Page.currentProjectId <= 0) return
        
        console.log("Chargement des heures existantes pour le projet:", main4Page.currentProjectId)
        
        try {
            for (var i = 0; i < main4Page.currentProjectEmployees.length; i++) {
                var employee = main4Page.currentProjectEmployees[i]
                
                // Charger les heures des tâches principales
                for (var j = 0; j < main4Page.currentProjectTasks.length; j++) {
                    var task = main4Page.currentProjectTasks[j]
                    
                    if (isEmployeeRole()) {
                        var currentUserId = getCurrentUserId()
                        if (task.assignedEmployeeId && Number(task.assignedEmployeeId) !== Number(currentUserId)) {
                            continue
                        }
                    }
                    
                    var existingHours = taskController.getEmployeeTaskHours(
                        parseInt(main4Page.currentProjectId),
                        parseInt(employee.id),
                        parseInt(task.id)
                    )
                    
                    if (existingHours > 0) {
                        console.log("Heures trouvées - Employé:", employee.id, "Tâche:", task.id, "Heures:", existingHours)
                        setEmployeeTaskHours(employee.id, task.id, existingHours)
                    }
                    
                    // Charger les heures des sous-tâches
                    if (main4Page.currentSubTasks[task.id]) {
                        for (var k = 0; k < main4Page.currentSubTasks[task.id].length; k++) {
                            var subTask = main4Page.currentSubTasks[task.id][k]
                            
                            var existingSubTaskHours = taskController.getEmployeeTaskHours(
                                parseInt(main4Page.currentProjectId),
                                parseInt(employee.id),
                                parseInt(subTask.id)
                            )
                            
                            if (existingSubTaskHours > 0) {
                                console.log("Heures sous-tâche trouvées - Employé:", employee.id, "Sous-tâche:", subTask.id, "Heures:", existingSubTaskHours)
                                setEmployeeSubTaskHours(employee.id, task.id, subTask.id, existingSubTaskHours)
                            }
                        }
                    }
                }
            }
            console.log("Chargement des heures existantes terminé")
        } catch (error) {
            console.error("Erreur lors du chargement des heures existantes:", error)
        }
    }

    function calculateProjectTotalHours() {
        var total = 0
        var originalTotal = 0
        
        console.log("=== CALCUL TOTAL PROJET (OPTIMISÉ) ===")
        
        // Utiliser les totaux déjà calculés pour chaque tâche
        for (var i = 0; i < main4Page.currentProjectTasks.length; i++) {
            var task = main4Page.currentProjectTasks[i]
            
            // Ajouter le total de la tâche (qui inclut déjà les sous-tâches)
            total += task.totalHours
            
            // Ajouter les heures originales
            if (task.originalHours) {
                originalTotal += task.originalHours
            }
            
            // Ajouter les heures originales des sous-tâches
            if (main4Page.currentSubTasks[task.id]) {
                for (var j = 0; j < main4Page.currentSubTasks[task.id].length; j++) {
                    var subTask = main4Page.currentSubTasks[task.id][j]
                    if (subTask.originalHours) {
                        originalTotal += subTask.originalHours
                    }
                }
            }
        }
        
        main4Page.projectTotalHours = total
        main4Page.projectOriginalHours = originalTotal
        
        console.log("📊 Total projet calculé:", total.toFixed(1) + "h")
        console.log("📊 Heures originales:", originalTotal.toFixed(1) + "h")
        
        // Forcer la mise à jour des bindings
        main4Page.projectTotalHoursChanged()
        
        return total
    }

    function setEmployeeTaskHours(employeeId, taskId, hours) {
        if (!employeeId || !taskId) {
            console.error("setEmployeeTaskHours: employeeId ou taskId undefined")
            return
        }
    
        if (!main4Page.employeeTaskHours[employeeId]) {
            main4Page.employeeTaskHours[employeeId] = {}
        }
        main4Page.employeeTaskHours[employeeId][taskId] = hours
    
        console.log("Heures mises à jour - Employé:", employeeId, "Tâche:", taskId, "Heures:", hours)
    
        // Mettre à jour le total des heures de l'employé
        updateEmployeeTotalHours(employeeId)
    
        // Mettre à jour le total des heures de la tâche
        updateTaskTotalHours(taskId)
    
        // RECALCULER LE TOTAL DU PROJET
        calculateProjectTotalHours()
    
        // Forcer la mise à jour de l'interface
        main4Page.currentProjectEmployeesChanged()
        main4Page.currentProjectTasksChanged()
    
        // Forcer spécifiquement la mise à jour de cette tâche
        refreshTaskInList(taskId)
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

    function refreshTaskInList(taskId) {
        // Cette fonction crée une nouvelle référence pour forcer la mise à jour du binding
        for (var i = 0; i < main4Page.currentProjectTasks.length; i++) {
            if (main4Page.currentProjectTasks[i].id === taskId) {
                var task = main4Page.currentProjectTasks[i]
                // Créer une copie complète avec toutes les propriétés
                var taskCopy = {
                    id: task.id,
                    name: task.name,
                    totalHours: task.totalHours,
                    originalHours: task.originalHours,
                    assignedEmployeeId: task.assignedEmployeeId,
                    hasSubTasks: task.hasSubTasks
                }
                main4Page.currentProjectTasks[i] = taskCopy
                break
            }
        }
        // Forcer la mise à jour de toute la liste
        main4Page.currentProjectTasksChanged()
        main4Page.currentProjectTasks = main4Page.currentProjectTasks.slice()
    }

    function updateTaskTotalHours(taskId) {
        var total = 0
    
        console.log("=== MISE À JOUR TOTAL TÂCHE ===")
        console.log("Tâche ID:", taskId)
    
        // 1. Ajouter les heures DIRECTES de la tâche principale
        for (var employeeId in main4Page.employeeTaskHours) {
            if (main4Page.employeeTaskHours[employeeId][taskId]) {
                var directHours = main4Page.employeeTaskHours[employeeId][taskId]
                if (directHours > 0) {
                    console.log("Heures directes - Employé:", employeeId, "Heures:", directHours)
                    total += directHours
                }
            }
        }
    
        // 2. Ajouter les heures des SOUS-TÂCHES
        for (var empId in main4Page.employeeSubTaskHours) {
            if (main4Page.employeeSubTaskHours[empId][taskId]) {
                for (var subTaskId in main4Page.employeeSubTaskHours[empId][taskId]) {
                    var subHours = main4Page.employeeSubTaskHours[empId][taskId][subTaskId]
                    if (subHours > 0) {
                        console.log("Heures sous-tâche - Employé:", empId, 
                                  "Sous-tâche:", subTaskId, "Heures:", subHours)
                        total += subHours
                    }
                }
            }
        }
    
        console.log("Total final tâche", taskId + ":", total.toFixed(1) + "h")
    
        // Mettre à jour la tâche dans la liste
        for (var i = 0; i < main4Page.currentProjectTasks.length; i++) {
            if (main4Page.currentProjectTasks[i].id === taskId) {
                main4Page.currentProjectTasks[i].totalHours = total
                console.log("Total mis à jour pour:", main4Page.currentProjectTasks[i].name, 
                           "Nouveau total:", total.toFixed(1) + "h")
                break
            }
        }
    
        // FORCER la mise à jour du binding
        refreshTaskInList(taskId)
    
        return total
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
        
        // Sauvegarder les heures des tâches principales
        for (var employeeId in main4Page.employeeTaskHours) {
            for (var taskId in main4Page.employeeTaskHours[employeeId]) {
                var hours = main4Page.employeeTaskHours[employeeId][taskId]
                if (hours > 0) {
                    console.log("💾 Sauvegarde tâche principale - Projet:", main4Page.currentProjectId, 
                              "Employé:", employeeId, "Tâche:", taskId, "Heures:", hours)
                    
                    try {
                        var success = taskController.saveEmployeeTaskHours(
                            parseInt(main4Page.currentProjectId),
                            parseInt(employeeId),
                            parseInt(taskId),
                            hours
                        )
                        
                        if (success) {
                            console.log("✅ Tâche principale sauvegardée")
                            successCount++
                            hasChanges = true
                        } else {
                            console.error("❌ Échec tâche principale")
                            errorCount++
                        }
                    } catch (error) {
                        console.error("💥 Erreur tâche principale:", error)
                        errorCount++
                    }
                }
            }
        }
        
        // Sauvegarder les heures des sous-tâches
        for (var empId in main4Page.employeeSubTaskHours) {
            for (var parentTaskId in main4Page.employeeSubTaskHours[empId]) {
                for (var subTaskId in main4Page.employeeSubTaskHours[empId][parentTaskId]) {
                    var subTaskHours = main4Page.employeeSubTaskHours[empId][parentTaskId][subTaskId]
                    if (subTaskHours > 0) {
                        console.log("💾 Sauvegarde sous-tâche - Projet:", main4Page.currentProjectId, 
                                  "Employé:", empId, "Sous-tâche:", subTaskId, "Heures:", subTaskHours)
                        
                        try {
                            var subTaskSuccess = taskController.saveEmployeeTaskHours(
                                parseInt(main4Page.currentProjectId),
                                parseInt(empId),
                                parseInt(subTaskId),
                                subTaskHours
                            )
                            
                            if (subTaskSuccess) {
                                console.log("✅ Sous-tâche sauvegardée")
                                successCount++
                                hasChanges = true
                            } else {
                                console.error("❌ Échec sous-tâche")
                                errorCount++
                            }
                        } catch (error) {
                            console.error("💥 Erreur sous-tâche:", error)
                            errorCount++
                        }
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
                currentIndex: main4Page.projects.length > 0 ? 0 : -1
    
                Component.onCompleted: {
                    console.log("ComboBox créé, projets:", main4Page.projects.length, "index:", currentIndex)
                    if (main4Page.projects.length > 0 && currentIndex >= 0) {
                        Qt.callLater(updateProjectData)
                    }
                }
    
                onCurrentIndexChanged: {
                    console.log("Index ComboBox changé:", currentIndex, "projets:", main4Page.projects.length)
                    if (currentIndex >= 0 && main4Page.projects.length > 0) {
                        Qt.callLater(updateProjectData)
                    }
                }
            }
        }

        // Section TOTAL DU PROJET (version compacte)
        ColumnLayout {
            spacing: 8
            Layout.fillWidth: true
            visible: main4Page.projects.length > 0 && main4Page.currentProjectId > 0 && !isEmployeeRole()

            Label {
                text: 'TOTAL DU PROJET'
                font.bold: true
                font.pixelSize: 16
                color: "#2c3e50"
            }

            Rectangle {
                Layout.fillWidth: true
                height: 60
                border.color: "#bdc3c7"
                border.width: 1
                radius: 6
                color: "#f8f9fa"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 20

                    // Heures saisies
                    ColumnLayout {
                        spacing: 2
                        Layout.alignment: Qt.AlignVCenter

                        Label {
                            text: "Heures saisies"
                            font.pixelSize: 11
                            color: "#7f8c8d"
                        }

                        Label {
                            text: main4Page.projectTotalHours.toFixed(1) + " h"
                            font.bold: true
                            font.pixelSize: 16
                            color: "#e74c3c"
                        }
                    }
                }
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
                                        text: {
                                            if (isEmployeeRole()) {
                                                return "MES HEURES PAR TÂCHE:"
                                            } else if (employeeCard.currentEmployee && employeeCard.currentEmployee.name) {
                                                return employeeCard.currentEmployee.name + " - Heures par tâche:"
                                            } else {
                                                return "Heures par tâche:"
                                            }
                                        }
                                        font.bold: true
                                        font.pixelSize: 14
                                        color: "#2c3e50"
                                        Layout.topMargin: 10
                                        Layout.leftMargin: 10
                                    }
                                    
                                    // Répéteur pour les tâches de cet employé
                                    Repeater {
                                        model: main4Page.currentProjectTasks
                                        
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            Layout.leftMargin: 20
                                            Layout.rightMargin: 20
                                            spacing: 5
                                            
                                            property var currentTask: modelData
                                            property var currentEmployee: employeeCard.currentEmployee
                                            
                                            // TÂCHE PRINCIPALE
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 10
                                                
                                                Label {
                                                    text: {
                                                        if (currentTask && currentTask.name) {
                                                            return currentTask.name + (currentTask.hasSubTasks ? " 🗂️" : "")
                                                        } else {
                                                            return "Tâche sans nom"
                                                        }
                                                    }
                                                    Layout.preferredWidth: 200
                                                    elide: Text.ElideRight
                                                    font.bold: true
                                                }
                                                
                                                // Bouton -
                                                Button {
                                                    text: "-"
                                                    width: 30
                                                    height: 30
                                                    enabled: currentEmployee && currentTask
                                                    onClicked: {
                                                        if (!currentEmployee || !currentTask) return
                                                        var currentHours = getEmployeeTaskHours(currentEmployee.id, currentTask.id)
                                                        if (currentHours > 0) {
                                                            var newHours = currentHours - 0.5
                                                            setEmployeeTaskHours(currentEmployee.id, currentTask.id, Math.max(0, newHours))
                                                        }
                                                    }
                                                }
                                                
                                                // Affichage des heures
                                                Label {
                                                    text: {
                                                        if (currentEmployee && currentTask) {
                                                            return getEmployeeTaskHours(currentEmployee.id, currentTask.id).toFixed(1) + " h"
                                                        } else {
                                                            return "0.0 h"
                                                        }
                                                    }
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
                                                    enabled: currentEmployee && currentTask
                                                    onClicked: {
                                                        if (!currentEmployee || !currentTask) return
                                                        var currentHours = getEmployeeTaskHours(currentEmployee.id, currentTask.id)
                                                        var newHours = currentHours + 0.5
                                                        setEmployeeTaskHours(currentEmployee.id, currentTask.id, newHours)
                                                    }
                                                }
                                                
                                                // Total de la tâche
                                                Label {
                                                    text: {
                                                        if (currentTask && currentTask.totalHours !== undefined) {
                                                            return "Total: " + currentTask.totalHours.toFixed(1) + " h"
                                                        } else {
                                                            return "Total: 0.0 h"
                                                        }
                                                    }
                                                    Layout.fillWidth: true
                                                    horizontalAlignment: Text.AlignRight
                                                    color: "gray"
                                                    font.pixelSize: 12
                                                }
                                            }
                                            
                                            // SOUS-TÂCHES 
                                            ColumnLayout {
                                                id: subTasksSection
                                                Layout.fillWidth: true
                                                Layout.leftMargin: 20
                                                spacing: 5

                                                // Condition de visibilité améliorée
                                                visible: {
                                                    var hasSubTasks = currentTask.hasSubTasks
                                                    var hasSubTasksData = main4Page.currentSubTasks && main4Page.currentSubTasks[currentTask.id]
                                                    var subTasksCount = hasSubTasksData ? main4Page.currentSubTasks[currentTask.id].length : 0

                                                    return hasSubTasks && hasSubTasksData && subTasksCount > 0
                                                }

                                                Repeater {
                                                    model: {
                                                        var subTasks = main4Page.currentSubTasks && main4Page.currentSubTasks[currentTask.id] ? main4Page.currentSubTasks[currentTask.id] : []
                                                        return subTasks
                                                    }

                                                    RowLayout {
                                                        id: subTaskRow
                                                        Layout.fillWidth: true
                                                        spacing: 8

                                                        // Stocker les références explicitement
                                                        property var subTaskData: modelData
                                                        property var theEmployee: currentEmployee
                                                        property var theParentTask: currentTask

                                                        Component.onCompleted: {
                                                            console.log("Sous-tâche créée:", subTaskData ? subTaskData.name : "undefined", 
                                                                        "Employé:", theEmployee ? theEmployee.name : "undefined",
                                                                        "Tâche parente:", theParentTask ? theParentTask.name : "undefined")
                                                        }

                                                        Label {
                                                            text: "  └─ " + (subTaskData.name || "Sous-tâche")
                                                            Layout.preferredWidth: 180
                                                            elide: Text.ElideRight
                                                            font.pixelSize: 12
                                                            color: "#7f8c8d"
                                                        }

                                                        // Bouton - SIMPLIFIÉ
                                                        Button {
                                                            text: "-"
                                                            width: 25
                                                            height: 25
                                                            font.pixelSize: 10
                                                            font.bold: true

                                                            onClicked: {
                                                                console.log("Bouton - cliqué pour:", subTaskData.name)
                                                                if (theEmployee && theParentTask && subTaskData) {
                                                                    var hours = getEmployeeSubTaskHours(theEmployee.id, theParentTask.id, subTaskData.id)
                                                                    console.log("Heures avant:", hours)
                                                                    if (hours > 0) {
                                                                        setEmployeeSubTaskHours(theEmployee.id, theParentTask.id, subTaskData.id, hours - 0.5)
                                                                    }
                                                                } else {
                                                                    console.error("❌ Références manquantes dans bouton -")
                                                                }
                                                            }
                                                        }

                                                        Label {
                                                            id: hoursDisplay
                                                            text: {
                                                                var hours = 0
                                                                if (theEmployee && theParentTask && subTaskData) {
                                                                    hours = getEmployeeSubTaskHours(theEmployee.id, theParentTask.id, subTaskData.id)
                                                                }
                                                                return hours.toFixed(1) + " h"
                                                            }
                                                            Layout.preferredWidth: 50
                                                            horizontalAlignment: Text.AlignHCenter
                                                            font.bold: true
                                                            font.pixelSize: 11
                                                            background: Rectangle {
                                                                color: "#f0f8ff"
                                                                border.color: "#85c1e9"
                                                                border.width: 1
                                                                radius: 2
                                                            }
                                                            padding: 3
                                                        }

                                                        // Bouton + SIMPLIFIÉ
                                                        Button {
                                                            text: "+"
                                                            width: 25
                                                            height: 25
                                                            font.pixelSize: 10
                                                            font.bold: true

                                                            onClicked: {
                                                                console.log("Bouton + cliqué pour:", subTaskData.name)
                                                                if (theEmployee && theParentTask && subTaskData) {
                                                                    var hours = getEmployeeSubTaskHours(theEmployee.id, theParentTask.id, subTaskData.id)
                                                                    console.log("Heures avant:", hours)
                                                                    setEmployeeSubTaskHours(theEmployee.id, theParentTask.id, subTaskData.id, hours + 0.5)
                                                                } else {
                                                                    console.error("❌ Références manquantes dans bouton +")
                                                                }
                                                            }
                                                        }

                                                        Label {
                                                            text: "Sous-total: " + (subTaskData.totalHours || 0).toFixed(1) + " h"
                                                            Layout.fillWidth: true
                                                            horizontalAlignment: Text.AlignRight
                                                            color: "gray"
                                                            font.pixelSize: 10
                                                        }
                                                    }
                                                }
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
        
        // Attendre que l'interface soit complètement chargée
        Qt.callLater(function() {
            if (main4Page.projects.length > 0) {
                updateProjectData()
            }
        })
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