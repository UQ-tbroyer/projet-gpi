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
    
    // RECALCULER TOUS LES TOTAUX APRÈS LE CHARGEMENT
    recalculateAllTotals()
    
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
        var taskCount = 0
        var subTaskTotalCount = 0
        
        console.log("=== CHARGEMENT RÉCURSIF DES TÂCHES ===")
        
        // Charger toutes les tâches du projet
        var allTasks = taskController.getTasksForProject(main4Page.currentProjectId)
        
        if (!allTasks || allTasks.length === 0) {
            console.log("Aucune tâche trouvée pour ce projet")
            main4Page.currentProjectTasks = []
            return
        }
        
        // Identifier les tâches racines (niveau 0)
        var rootTasks = allTasks.filter(function(task) {
            return !task.idParentTache || task.idParentTache === 0
        })
        
        console.log("Tâches racines:", rootTasks.length)
        console.log("Tâches totales:", allTasks.length)
        
        // Fonction récursive pour organiser les tâches
        function organizeTasks(taskList, parentId = null, level = 0) {
            var tasks = []
            var indent = "  ".repeat(level)
            
            for (var i = 0; i < taskList.length; i++) {
                var task = taskList[i]
                
                // Si cette tâche appartient au parent courant
                if ((!parentId && !task.idParentTache) || 
                    (parentId && task.idParentTache === parentId)) {
                    
                    var taskObj = {
                        id: task.idTache || task.id,
                        parentId: task.idParentTache || null,
                        name: task.nomTache || task.nom,
                        level: level,
                        totalHours: 0,
                        originalHours: task.tempsTache ? task.tempsTache / 60.0 : 0,
                        assignedEmployeeId: task.memProcessigner,
                        assigneeName: task.assigneeName || "",
                        description: task.descTache || "",
                        state: task.etat || "",
                        hasChildren: false,
                        children: [],
                        isSubTask: level > 0
                    }
                    
                    // Rechercher récursivement les enfants
                    var children = organizeTasks(taskList, taskObj.id, level + 1)
                    if (children.length > 0) {
                        taskObj.children = children
                        taskObj.hasChildren = true
                        subTaskTotalCount += children.length
                    }
                    
                    tasks.push(taskObj)
                    taskCount++
                    
                    console.log(indent + (level === 0 ? "📁 " : "  └─ ") + taskObj.name + 
                              " (ID:" + taskObj.id + 
                              ", Niveau:" + level + 
                              ", Enfants:" + children.length + ")")
                }
            }
            return tasks
        }
        
        // Organiser les tâches hiérarchiquement
        main4Page.currentProjectTasks = organizeTasks(allTasks)
        
        // Créer une structure plate pour l'accès rapide
        main4Page.currentSubTasks = {}
        function flattenTasks(tasks, parentId = null) {
            for (var i = 0; i < tasks.length; i++) {
                var task = tasks[i]
                if (!main4Page.currentSubTasks[parentId]) {
                    main4Page.currentSubTasks[parentId] = []
                }
                main4Page.currentSubTasks[parentId].push(task)
                
                if (task.children && task.children.length > 0) {
                    flattenTasks(task.children, task.id)
                }
            }
        }
        flattenTasks(main4Page.currentProjectTasks, null)
        
        console.log("=== CHARGEMENT TERMINÉ ===")
        console.log(" Tâches chargées:", taskCount)
        console.log(" Sous-tâches totales:", subTaskTotalCount)
        console.log(" Niveaux de hiérarchie:", getMaxDepth(main4Page.currentProjectTasks))
        
    } catch (error) {
        console.error(" Erreur chargement récursif:", error)
        main4Page.currentProjectTasks = []
        main4Page.currentSubTasks = {}
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
    function getMaxDepth(tasks) {
    var maxDepth = 0
    function checkDepth(task, currentDepth) {
        maxDepth = Math.max(maxDepth, currentDepth)
        if (task.children && task.children.length > 0) {
            for (var i = 0; i < task.children.length; i++) {
                checkDepth(task.children[i], currentDepth + 1)
            }
        }
    }
    for (var i = 0; i < tasks.length; i++) {
        checkDepth(tasks[i], 0)
    }
    return maxDepth
}

    function loadProjectTasks() {
    try {
        if (main4Page.currentProjectId <= 0) return
        
        // Appeler la nouvelle fonction récursive
        loadSubTasksForAllTasks()
        
        // Filtrer selon le rôle (inchangé)
        if (isEmployeeRole()) {
            var currentUserId = getCurrentUserId()
            var filteredTasks = []
            
            function filterTasksByEmployee(tasks, employeeId) {
                var result = []
                for (var i = 0; i < tasks.length; i++) {
                    var task = tasks[i]
                    if (task.assignedEmployeeId && 
                        Number(task.assignedEmployeeId) === Number(employeeId)) {
                        // Copier la tâche avec ses enfants filtrés
                        var filteredTask = Object.assign({}, task)
                        if (task.children && task.children.length > 0) {
                            filteredTask.children = filterTasksByEmployee(task.children, employeeId)
                            filteredTask.hasChildren = filteredTask.children.length > 0
                        }
                        result.push(filteredTask)
                    }
                }
                return result
            }
            
            main4Page.currentProjectTasks = filterTasksByEmployee(main4Page.currentProjectTasks, currentUserId)
        }
        
        console.log("✓ Tâches chargées récursivement:", main4Page.currentProjectTasks.length)
        
    } catch (error) {
        console.error("Erreur chargement tâches récursif:", error)
        main4Page.currentProjectTasks = []
    }
}

function initializeEmployeeTaskHours() {
    main4Page.employeeTaskHours = {}
    main4Page.employeeSubTaskHours = {}
    
    console.log("=== INITIALISATION HEURES ===")
    console.log("Employés:", main4Page.currentProjectEmployees.length)
    console.log("Tâches totales (avec enfants):", countAllTasks(main4Page.currentProjectTasks))
    
    // Fonction pour compter toutes les tâches récursivement
    function countAllTasks(tasks) {
        var count = 0
        for (var i = 0; i < tasks.length; i++) {
            count++
            if (tasks[i].children && tasks[i].children.length > 0) {
                count += countAllTasks(tasks[i].children)
            }
        }
        return count
    }
    
    // Fonction récursive pour initialiser toutes les tâches
    function initTasksForEmployee(employeeId, tasks) {
        for (var i = 0; i < tasks.length; i++) {
            var task = tasks[i]
            
            // TÂCHE PRINCIPALE (sans parent) -> employeeTaskHours
            if (!task.parentId || task.parentId === 0) {
                if (!main4Page.employeeTaskHours[employeeId]) {
                    main4Page.employeeTaskHours[employeeId] = {}
                }
                main4Page.employeeTaskHours[employeeId][task.id] = 0
                console.log("  Tâche principale - Employé:", employeeId, "Tâche:", task.id)
            }
            // SOUS-TÂCHE (avec parent) -> employeeSubTaskHours
            else {
                if (!main4Page.employeeSubTaskHours[employeeId]) {
                    main4Page.employeeSubTaskHours[employeeId] = {}
                }
                if (!main4Page.employeeSubTaskHours[employeeId][task.parentId]) {
                    main4Page.employeeSubTaskHours[employeeId][task.parentId] = {}
                }
                main4Page.employeeSubTaskHours[employeeId][task.parentId][task.id] = 0
                console.log("  Sous-tâche - Employé:", employeeId, 
                          "Parent:", task.parentId, "Tâche:", task.id)
            }
            
            // Initialiser récursivement les enfants
            if (task.children && task.children.length > 0) {
                initTasksForEmployee(employeeId, task.children)
            }
        }
    }
    
    // Initialiser pour chaque employé
    for (var i = 0; i < main4Page.currentProjectEmployees.length; i++) {
        var employee = main4Page.currentProjectEmployees[i]
        if (employee && employee.id) {
            console.log("Initialisation pour employé:", employee.id, "-", employee.name)
            initTasksForEmployee(employee.id, main4Page.currentProjectTasks)
        }
    }
    
    console.log("✅ Structure heures initialisée")
}

function getEmployeeTaskHours(employeeId, taskId) {
    if (!employeeId || !taskId) return 0
    if (main4Page.employeeTaskHours[employeeId] && main4Page.employeeTaskHours[employeeId][taskId] !== undefined) {
        return main4Page.employeeTaskHours[employeeId][taskId]
    }
    return 0
}
function getEmployeeSubTaskHours(employeeId, parentTaskId, subTaskId) {
    // Convertir en nombres
    employeeId = Number(employeeId)
    parentTaskId = Number(parentTaskId) || 0
    subTaskId = Number(subTaskId)
    
    console.log("🔍 getEmployeeSubTaskHours -", {
        employeeId: employeeId,
        parentTaskId: parentTaskId,
        subTaskId: subTaskId
    })
    
    if (!employeeId || !subTaskId) {
        console.warn("⚠️ Paramètres invalides")
        return 0
    }
    
    // SI C'EST UNE TÂCHE PRINCIPALE (parentTaskId = 0), utiliser employeeTaskHours
    if (parentTaskId === 0) {
        if (main4Page.employeeTaskHours[employeeId] && 
            main4Page.employeeTaskHours[employeeId][subTaskId] !== undefined) {
            
            var hours = main4Page.employeeTaskHours[employeeId][subTaskId]
            console.log("✅ Tâche principale - Heures:", hours)
            return hours
        }
        return 0
    }
    
    // SINON, c'est une sous-tâche, utiliser employeeSubTaskHours
    if (main4Page.employeeSubTaskHours[employeeId] && 
        main4Page.employeeSubTaskHours[employeeId][parentTaskId] &&
        main4Page.employeeSubTaskHours[employeeId][parentTaskId][subTaskId] !== undefined) {
        
        var subHours = main4Page.employeeSubTaskHours[employeeId][parentTaskId][subTaskId]
        console.log("✅ Sous-tâche - Heures:", subHours)
        return subHours
    }
    
    console.log("❌ Aucune heure trouvée, retourne 0")
    return 0
}

function findTaskById(taskId, tasks) {
    for (var i = 0; i < tasks.length; i++) {
        var task = tasks[i]
        if (task.id === taskId) {
            return task
        }
        if (task.children && task.children.length > 0) {
            var found = findTaskById(taskId, task.children)
            if (found) return found
        }
    }
    return null
}

function setEmployeeSubTaskHours(employeeId, parentTaskId, subTaskId, hours) {
    if (!employeeId || !subTaskId) {
        console.error("setEmployeeSubTaskHours: paramètres manquants")
        return
    }
    
    console.log("=== SET HEURES ===")
    console.log("Employé:", employeeId, "Parent:", parentTaskId, "Tâche:", subTaskId, "Heures:", hours)
    
    // SI C'EST UNE TÂCHE PRINCIPALE (parentTaskId = 0)
    if (parentTaskId === 0) {
        // Utiliser employeeTaskHours pour les tâches principales
        if (!main4Page.employeeTaskHours[employeeId]) {
            main4Page.employeeTaskHours[employeeId] = {}
        }
        main4Page.employeeTaskHours[employeeId][subTaskId] = hours
        
        console.log("✅ Heures tâche principale sauvegardées")
    } 
    // SINON, c'est une sous-tâche
    else {
        // Utiliser employeeSubTaskHours pour les sous-tâches
        if (!main4Page.employeeSubTaskHours[employeeId]) {
            main4Page.employeeSubTaskHours[employeeId] = {}
        }
        if (!main4Page.employeeSubTaskHours[employeeId][parentTaskId]) {
            main4Page.employeeSubTaskHours[employeeId][parentTaskId] = {}
        }
        
        main4Page.employeeSubTaskHours[employeeId][parentTaskId][subTaskId] = hours
        
        console.log("✅ Heures sous-tâche sauvegardées")
    }
    
    // IMPORTANT: Mettre à jour le total de la tâche (incluant les sous-tâches)
    updateTaskTotalWithChildren(subTaskId)
    
    // Mettre à jour le total de l'employé
    updateEmployeeTotalHours(employeeId)
    
    // Recalculer le total du projet
    calculateProjectTotalHours()
    
    // Forcer la mise à jour
    main4Page.employeeSubTaskHoursChanged()
    main4Page.employeeTaskHoursChanged()
    main4Page.currentProjectTasksChanged()
}
function recalculateAllTotals() {
    console.log("=== RECALCUL DE TOUS LES TOTAUX ===")
    
    // Réinitialiser tous les totaux
    main4Page.projectTotalHours = 0
    
    // Recalculer le total de chaque tâche
    function recalcTaskTotals(tasks) {
        for (var i = 0; i < tasks.length; i++) {
            updateTaskTotalWithChildren(tasks[i].id)
            if (tasks[i].children && tasks[i].children.length > 0) {
                recalcTaskTotals(tasks[i].children)
            }
        }
    }
    
    recalcTaskTotals(main4Page.currentProjectTasks)
    
    // Recalculer le total de chaque employé
    for (var j = 0; j < main4Page.currentProjectEmployees.length; j++) {
        updateEmployeeTotalHours(main4Page.currentProjectEmployees[j].id)
    }
    
    // Recalculer le total du projet
    calculateProjectTotalHours()
    
    console.log("✅ Tous les totaux recalculés")
}
function updateTaskTotalWithChildren(taskId) {
    console.log("📊 Mise à jour total avec enfants pour tâche:", taskId)
    
    var task = findTaskById(taskId, main4Page.currentProjectTasks)
    if (!task) {
        console.log("Tâche non trouvée:", taskId)
        return
    }
    
    var total = 0
    
    // 1. Ajouter les heures DIRECTES de cette tâche (tous les employés)
    // Pour les tâches principales (parentId = 0) -> employeeTaskHours
    if (!task.parentId || task.parentId === 0) {
        for (var employeeId in main4Page.employeeTaskHours) {
            if (main4Page.employeeTaskHours[employeeId][taskId]) {
                total += main4Page.employeeTaskHours[employeeId][taskId]
                console.log("  Heures directes - Employé:", employeeId, 
                          "Tâche:", taskId, "Heures:", main4Page.employeeTaskHours[employeeId][taskId])
            }
        }
    }
    // Pour les sous-tâches -> employeeSubTaskHours
    else {
        for (var empId in main4Page.employeeSubTaskHours) {
            if (main4Page.employeeSubTaskHours[empId][task.parentId] &&
                main4Page.employeeSubTaskHours[empId][task.parentId][taskId]) {
                total += main4Page.employeeSubTaskHours[empId][task.parentId][taskId]
                console.log("  Heures sous-tâche - Employé:", empId, 
                          "Parent:", task.parentId, "Tâche:", taskId, 
                          "Heures:", main4Page.employeeSubTaskHours[empId][task.parentId][taskId])
            }
        }
    }
    
    // 2. Ajouter les heures de TOUTES les sous-tâches (récursivement)
    function addChildrenHours(childTask) {
        if (!childTask.children || childTask.children.length === 0) return
        
        for (var i = 0; i < childTask.children.length; i++) {
            var grandChild = childTask.children[i]
            
            // Ajouter les heures de cette sous-tâche
            for (var empId in main4Page.employeeSubTaskHours) {
                if (main4Page.employeeSubTaskHours[empId][grandChild.parentId] &&
                    main4Page.employeeSubTaskHours[empId][grandChild.parentId][grandChild.id]) {
                    total += main4Page.employeeSubTaskHours[empId][grandChild.parentId][grandChild.id]
                    console.log("  Heures enfant - Employé:", empId, 
                              "Parent:", grandChild.parentId, "Tâche:", grandChild.id, 
                              "Heures:", main4Page.employeeSubTaskHours[empId][grandChild.parentId][grandChild.id])
                }
            }
            
            // Ajouter récursivement les heures des enfants de cet enfant
            addChildrenHours(grandChild)
        }
    }
    
    // Démarrer le calcul récursif
    addChildrenHours(task)
    
    // Mettre à jour le total de la tâche
    task.totalHours = total
    console.log("✅ Total pour", task.name + ":", total.toFixed(1), "h")
    
    // Si cette tâche a un parent, mettre à jour aussi le parent
    if (task.parentId && task.parentId > 0) {
        updateTaskTotalWithChildren(task.parentId)
    }
    
    // Forcer la mise à jour de l'interface
    main4Page.currentProjectTasksChanged()
    
    // Mettre à jour aussi le total de la tâche dans currentSubTasks
    updateTaskInSubTasks(task.parentId || 0, task.id, total)
}

// Fonction auxiliaire pour mettre à jour currentSubTasks
function updateTaskInSubTasks(parentId, taskId, total) {
    if (main4Page.currentSubTasks[parentId]) {
        for (var i = 0; i < main4Page.currentSubTasks[parentId].length; i++) {
            if (main4Page.currentSubTasks[parentId][i].id === taskId) {
                main4Page.currentSubTasks[parentId][i].totalHours = total
                break
            }
        }
    }
}
function updateTaskTotalRecursive(taskId) {
    console.log("Mise à jour total récursif pour tâche:", taskId)
    
    var task = findTaskById(taskId, main4Page.currentProjectTasks)
    if (!task) {
        console.log("Tâche non trouvée:", taskId)
        return
    }
    
    // Calculer le total pour cette tâche
    var total = 0
    
    // Ajouter les heures de tous les employés pour cette tâche
    for (var employeeId in main4Page.employeeTaskHours) {
        if (main4Page.employeeTaskHours[employeeId][taskId]) {
            total += main4Page.employeeTaskHours[employeeId][taskId]
        }
    }
    
    // Ajouter les heures de la structure hiérarchique
    for (var empId in main4Page.employeeSubTaskHours) {
        for (var parentId in main4Page.employeeSubTaskHours[empId]) {
            if (main4Page.employeeSubTaskHours[empId][parentId][taskId]) {
                total += main4Page.employeeSubTaskHours[empId][parentId][taskId]
            }
        }
    }
    
    // Mettre à jour la tâche
    task.totalHours = total
    console.log("Total pour", task.name + ":", total.toFixed(1))
    
    // Mettre à jour récursivement les parents
    if (task.parentId && task.parentId > 0) {
        updateTaskTotalRecursive(task.parentId)
    }
    
    // Forcer la mise à jour de l'interface
    main4Page.currentProjectTasksChanged()
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
    
    console.log("=== CHARGEMENT COMPLET DES HEURES EXISTANTES ===")
    
    try {
        // Pour chaque employé
        for (var i = 0; i < main4Page.currentProjectEmployees.length; i++) {
            var employee = main4Page.currentProjectEmployees[i]
            console.log("Chargement pour employé:", employee.id, "-", employee.name)
            
            // Fonction récursive pour charger les heures de toutes les tâches
            function loadHoursForTask(task, empId) {
                console.log("  Vérification tâche:", task.id, "-", task.name)
                
                // Charger les heures de cette tâche
                var existingHours = taskController.getEmployeeTaskHours(
                    parseInt(main4Page.currentProjectId),
                    parseInt(empId),
                    parseInt(task.id)
                )
                
                if (existingHours > 0) {
                    console.log("    ✓ Heures trouvées:", existingHours)
                    
                    // Déterminer si c'est une tâche principale ou une sous-tâche
                    if (!task.parentId || task.parentId === 0) {
                        // Tâche principale
                        setEmployeeTaskHours(empId, task.id, existingHours)
                    } else {
                        // Sous-tâche
                        setEmployeeSubTaskHours(empId, task.parentId, task.id, existingHours)
                    }
                }
                
                // Charger récursivement les enfants
                if (task.children && task.children.length > 0) {
                    for (var j = 0; j < task.children.length; j++) {
                        loadHoursForTask(task.children[j], empId)
                    }
                }
            }
            
            // Parcourir toutes les tâches racines
            for (var j = 0; j < main4Page.currentProjectTasks.length; j++) {
                var task = main4Page.currentProjectTasks[j]
                loadHoursForTask(task, employee.id)
            }
        }
        
        console.log("✅ Chargement des heures terminé")
        
        // Recalculer tous les totaux après le chargement
        Qt.callLater(function() {
            recalculateAllTotals()
        })
        
    } catch (error) {
        console.error("❌ Erreur lors du chargement des heures:", error)
    }
}

   function calculateProjectTotalHours() {
    var total = 0
    var originalTotal = 0
    
    console.log("=== CALCUL TOTAL PROJET ===")
    
    // Ajouter les heures des tâches principales
    for (var employeeId in main4Page.employeeTaskHours) {
        for (var taskId in main4Page.employeeTaskHours[employeeId]) {
            var hours = main4Page.employeeTaskHours[employeeId][taskId]
            if (hours > 0) {
                console.log("Heures tâche principale - Employé:", employeeId, "Tâche:", taskId, "Heures:", hours)
            }
            total += hours
        }
    }
    
    // Ajouter les heures des sous-tâches
    for (var empId in main4Page.employeeSubTaskHours) {
        for (var parentTaskId in main4Page.employeeSubTaskHours[empId]) {
            for (var subTaskId in main4Page.employeeSubTaskHours[empId][parentTaskId]) {
                var subHours = main4Page.employeeSubTaskHours[empId][parentTaskId][subTaskId]
                if (subHours > 0) {
                    console.log("Heures sous-tâche - Employé:", empId, "Sous-tâche:", subTaskId, "Heures:", subHours)
                }
                total += subHours
            }
        }
    }
    
    // Calculer le total des heures originales
    for (var i = 0; i < main4Page.currentProjectTasks.length; i++) {
        var task = main4Page.currentProjectTasks[i]
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
    
    console.log("Total projet - Heures saisies:", total.toFixed(1), 
                "Heures originales:", originalTotal.toFixed(1))
    
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
    
    // Mettre à jour le total des heures de l'employé
    updateEmployeeTotalHours(employeeId)
    
    // Mettre à jour le total des heures de la tâche
    updateTaskTotalHours(taskId)
    
    // RECALCULER LE TOTAL DU PROJET
    calculateProjectTotalHours()
    
    // Forcer la mise à jour de l'interface
    main4Page.currentProjectEmployeesChanged()
    main4Page.currentProjectTasksChanged()
    }

   function updateEmployeeTotalHours(employeeId) {
    var total = 0
    
    // 1. Ajouter les heures des tâches principales
    if (main4Page.employeeTaskHours[employeeId]) {
        for (var taskId in main4Page.employeeTaskHours[employeeId]) {
            total += main4Page.employeeTaskHours[employeeId][taskId]
        }
    }
    
    // 2. Ajouter les heures des sous-tâches
    if (main4Page.employeeSubTaskHours[employeeId]) {
        for (var parentId in main4Page.employeeSubTaskHours[employeeId]) {
            for (var subTaskId in main4Page.employeeSubTaskHours[employeeId][parentId]) {
                total += main4Page.employeeSubTaskHours[employeeId][parentId][subTaskId]
            }
        }
    }
    
    console.log("📊 Total employé", employeeId + ":", total.toFixed(1), "h")
    
    // Mettre à jour l'employé dans la liste
    for (var i = 0; i < main4Page.currentProjectEmployees.length; i++) {
        if (main4Page.currentProjectEmployees[i].id === employeeId) {
            main4Page.currentProjectEmployees[i].totalHours = total
            break
        }
    }
    
    // Forcer la mise à jour
    main4Page.currentProjectEmployeesChanged()
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
    
    console.log("=== DÉBUT SAUVEGARDE COMPLÈTE RÉCURSIVE ===")
    console.log("Projet ID:", main4Page.currentProjectId)
    
    var successCount = 0
    var errorCount = 0
    var entriesToSave = []
    
    // 1. Collecter TOUTES les heures à sauvegarder
    console.log("📊 Collecte des heures...")
    
    // a) Heures des tâches principales
    for (var employeeId in main4Page.employeeTaskHours) {
        for (var taskId in main4Page.employeeTaskHours[employeeId]) {
            var hours = main4Page.employeeTaskHours[employeeId][taskId]
            if (hours > 0) {
                entriesToSave.push({
                    type: "main",
                    employeeId: parseInt(employeeId),
                    taskId: parseInt(taskId),
                    hours: hours
                })
                console.log("  Tâche principale - Emp:", employeeId, "Task:", taskId, "Hours:", hours)
            }
        }
    }
    
    // b) Heures des sous-tâches
    for (var empId in main4Page.employeeSubTaskHours) {
        for (var parentTaskId in main4Page.employeeSubTaskHours[empId]) {
            for (var subTaskId in main4Page.employeeSubTaskHours[empId][parentTaskId]) {
                var subHours = main4Page.employeeSubTaskHours[empId][parentTaskId][subTaskId]
                if (subHours > 0) {
                    entriesToSave.push({
                        type: "sub",
                        employeeId: parseInt(empId),
                        taskId: parseInt(subTaskId),
                        hours: subHours
                    })
                    console.log("  Sous-tâche - Emp:", empId, "Task:", subTaskId, "Hours:", subHours)
                }
            }
        }
    }
    
    console.log("📋 Total des entrées à sauvegarder:", entriesToSave.length)
    
    // 2. Sauvegarder chaque entrée
    for (var i = 0; i < entriesToSave.length; i++) {
        var entry = entriesToSave[i]
        
        console.log("💾 Sauvegarde #" + (i+1) + " - Emp:" + entry.employeeId + 
                   " Task:" + entry.taskId + " Hours:" + entry.hours)
        
        try {
            var success = taskController.saveEmployeeTaskHours(
                parseInt(main4Page.currentProjectId),
                entry.employeeId,
                entry.taskId,
                entry.hours
            )
            
            if (success) {
                successCount++
                console.log("  ✅ Succès")
            } else {
                errorCount++
                console.log("  ❌ Échec")
            }
        } catch (error) {
            errorCount++
            console.error("  💥 Exception:", error)
        }
        
        // Petite pause pour éviter de surcharger
        if (i < entriesToSave.length - 1) {
            // Attendre 10ms entre chaque sauvegarde
            var waitTime = Date.now() + 10
            while (Date.now() < waitTime) {}
        }
    }
    
    // 3. Afficher le résultat
    console.log("=== RÉSULTAT ===")
    console.log("  Total entrées:", entriesToSave.length)
    console.log("  Succès:", successCount)
    console.log("  Échecs:", errorCount)
    console.log("=== FIN SAUVEGARDE ===")
    
    if (errorCount === 0 && successCount > 0) {
        saveConfirmationDialog.text = 
            successCount + " entrée(s) sauvegardée(s) avec succès!"
        saveConfirmationDialog.open()
    } else if (errorCount > 0) {
        showError(successCount + " réussite(s), " + errorCount + " échec(s)")
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
            }}
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
Component {
    id: recursiveTaskComponent
    
    ColumnLayout {
        id: taskContainer
        // Déclarez les propriétés avec des valeurs par défaut
        property var taskData: ({})
        property var employeeData: ({})
        property int indentLevel: 0
        
        // Assurez-vous que les données sont définies
        Component.onCompleted: {
            console.log("Composant créé - Task:", taskData ? taskData.name : "undefined", 
                      "Employee:", employeeData ? employeeData.name : "undefined",
                      "Level:", indentLevel)
        }
        
        // TÂCHE COURANTE
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: indentLevel * 25
            spacing: 8
            
            // Indentation
            Rectangle {
                width: indentLevel > 0 ? 15 : 0
                height: 1
                color: "#cccccc"
                visible: indentLevel > 0
            }
            
            // Icône
            Text {
                text: {
                    if (indentLevel === 0) {
                        return taskData && taskData.hasChildren ? "📁" : "•"
                    } else {
                        if (taskData && taskData.hasChildren) return "├─ 📁"
                        else return "└─ •"
                    }
                }
                font.pixelSize: 12
                color: "#7f8c8d"
                width: 40
                visible: taskData && taskData.name
            }
            
            // Nom de la tâche
            Label {
                text: taskData ? taskData.name || "Sans nom" : "Tâche non définie"
                Layout.preferredWidth: Math.max(120, 180 - indentLevel * 15)
                elide: Text.ElideRight
                font.bold: indentLevel === 0
                font.pixelSize: indentLevel === 0 ? 13 : 11
                color: indentLevel === 0 ? "#2c3e50" : "#7f8c8d"
                visible: taskData
            }
            
            // Bouton -
            Button {
                text: "−"
                width: 28
                height: 28
                font.pixelSize: 14
                font.bold: true
                // Vérifiez explicitement que les données existent
                enabled: taskData && employeeData && taskData.id && employeeData.id
                
                background: Rectangle {
                    color: parent.enabled ? "#e74c3c" : "#ecf0f1"
                    radius: 4
                    border.color: parent.enabled ? "#c0392b" : "#bdc3c7"
                    border.width: 1
                }
                
                contentItem: Text {
                    text: parent.text
                    color: parent.enabled ? "white" : "#95a5a6"
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    console.log("=== BOUTON - CLICK ===")
                    console.log("TaskData:", taskData)
                    console.log("EmployeeData:", employeeData)
                    
                    if (!taskData || !employeeData) {
                        console.error("❌ Données manquantes")
                        return
                    }
                    
                    // Utilisez des variables locales pour éviter les problèmes de scope
                    var empId = employeeData.id
                    var taskId = taskData.id
                    var parentId = taskData.parentId || 0
                    
                    console.log("Params:", {
                        employeeId: empId,
                        parentTaskId: parentId,
                        taskId: taskId
                    })
                    
                    var hours = main4Page.getEmployeeSubTaskHours(empId, parentId, taskId)
                    console.log("Heures actuelles:", hours)
                    
                    if (hours > 0) {
                        var newHours = Math.max(0, hours - 0.5)
                        console.log("Nouvelles heures:", newHours)
                        main4Page.setEmployeeSubTaskHours(empId, parentId, taskId, newHours)
                    }
                }
            }
            
            // Affichage des heures
            Rectangle {
                width: 60
                height: 28
                radius: 4
                border.color: "#3498db"
                border.width: 1
                color: "#e8f4fd"
                
                Label {
                    anchors.centerIn: parent
                    text: {
                        if (!taskData || !employeeData) return "0.0 h"
                        
                        var hours = main4Page.getEmployeeSubTaskHours(
                            employeeData.id, 
                            taskData.parentId || 0, 
                            taskData.id
                        )
                        return hours.toFixed(1) + " h"
                    }
                    font.bold: true
                    font.pixelSize: 11
                    color: "#2c3e50"
                }
            }
            
            // Bouton +
            Button {
                text: "+"
                width: 28
                height: 28
                font.pixelSize: 14
                font.bold: true
                enabled: taskData && employeeData && taskData.id && employeeData.id
                
                background: Rectangle {
                    color: parent.enabled ? "#2ecc71" : "#ecf0f1"
                    radius: 4
                    border.color: parent.enabled ? "#27ae60" : "#bdc3c7"
                    border.width: 1
                }
                
                contentItem: Text {
                    text: parent.text
                    color: parent.enabled ? "white" : "#95a5a6"
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    console.log("=== BOUTON + CLICK ===")
                    console.log("TaskData:", taskData)
                    console.log("EmployeeData:", employeeData)
                    
                    if (!taskData || !employeeData) {
                        console.error("❌ Données manquantes")
                        return
                    }
                    
                    var empId = employeeData.id
                    var taskId = taskData.id
                    var parentId = taskData.parentId || 0
                    
                    console.log("Params:", {
                        employeeId: empId,
                        parentTaskId: parentId,
                        taskId: taskId
                    })
                    
                    var hours = main4Page.getEmployeeSubTaskHours(empId, parentId, taskId)
                    console.log("Heures actuelles:", hours)
                    
                    var newHours = hours + 0.5
                    console.log("Nouvelles heures:", newHours)
                    main4Page.setEmployeeSubTaskHours(empId, parentId, taskId, newHours)
                }
            }
            
            // Total de la tâche
            Label {
                text: "Total: " + (taskData && taskData.totalHours ? taskData.totalHours.toFixed(1) : "0.0") + " h"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                color: "#7f8c8d"
                font.pixelSize: 10
                font.italic: true
            }
        }
        
        // ENFANTS RÉCURSIFS - CORRIGEZ la transmission des données
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5
            visible: taskData && taskData.children && taskData.children.length > 0
            
            Repeater {
                model: taskData && taskData.children ? taskData.children : []
                
                Loader {
                    id: childLoader
                    Layout.fillWidth: true
                    sourceComponent: recursiveTaskComponent
                    
                    // Définir les propriétés explicitement lors du chargement
                    onLoaded: {
                        if (item) {
                            console.log("Chargement enfant:", modelData.name)
                            item.taskData = modelData
                            item.employeeData = taskContainer.employeeData  // Important: transmettre l'employé
                            item.indentLevel = taskContainer.indentLevel + 1
                        }
                    }
                    
                    // Assurez-vous que le Loader a une hauteur
                    Layout.minimumHeight: 40
                }
            }
        }
    }
}

// Section DÉTAIL DES HEURES PAR TÂCHE (style original corrigé)
ColumnLayout {
    spacing: 10
    Layout.fillWidth: true
    Layout.fillHeight: true
    visible: main4Page.projects.length > 0 && 
             main4Page.currentProjectEmployees.length > 0 && 
             main4Page.currentProjectTasks.length > 0

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

    // Conteneur avec slider - STYLE ORIGINAL
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
            
            // FORCER LES SCROLLBARS À ÊTRE VISIBLES
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            
            // Largeur du contenu adaptative
            contentWidth: Math.max(parent.width - 20, employeeTasksColumn.implicitWidth)
            
            ColumnLayout {
                id: employeeTasksColumn
                width: Math.max(parent.parent.width - 20, implicitWidth)
                spacing: 15

                // Pour chaque employé - STYLE ORIGINAL
                Repeater {
                    model: main4Page.currentProjectEmployees
                    
                    Rectangle {
                        id: employeeCard
                        Layout.fillWidth: true
                        Layout.minimumHeight: childrenRect.height + 20
                        border.color: "#d0d0d0"
                        border.width: 1
                        radius: 5
                        
                        property var currentEmployee: modelData
                        
                        ColumnLayout {
                            width: parent.width - 20
                            anchors.centerIn: parent
                            spacing: 10
                            
                            // En-tête de l'employé
                            Label {
                                text: {
                                    if (isEmployeeRole()) {
                                        return "MES HEURES PAR TÂCHE:"
                                    } else {
                                        return currentEmployee.name + " - Heures par tâche:"
                                    }
                                }
                                font.bold: true
                                font.pixelSize: 14
                                color: "#2c3e50"
                                Layout.topMargin: 10
                            }
                            
                            // CONTENEUR pour toutes les tâches de cet employé
                            ColumnLayout {
                                id: tasksColumn
                                Layout.fillWidth: true
                                spacing: 8
                                
                                // Fonction pour créer les tâches récursivement
                                function createTaskItems(tasks, employee, level = 0) {
                                    for (var i = 0; i < tasks.length; i++) {
                                        var task = tasks[i]
                                        
                                        // Créer la ligne de tâche
                                        var taskItem = taskRowComponent.createObject(tasksColumn, {
                                            taskData: task,
                                            employeeData: employee,
                                            indentLevel: level,
                                            width: tasksColumn.width
                                        })
                                        
                                        // Ajouter les enfants récursivement
                                        if (task.children && task.children.length > 0) {
                                            createTaskItems(task.children, employee, level + 1)
                                        }
                                    }
                                }
                                
                                Component.onCompleted: {
                                    createTaskItems(main4Page.currentProjectTasks, currentEmployee)
                                }
                            }
                            
                            // Total de l'employé - STYLE ORIGINAL
                            Rectangle {
                                Layout.fillWidth: true
                                height: 30
                                color: "#f8f9fa"
                                border.color: "#e0e0e0"
                                border.width: 1
                                radius: 3
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    
                                    Label {
                                        text: "Total " + currentEmployee.name + ":"
                                        font.bold: true
                                        color: "#2c3e50"
                                    }
                                    
                                    Label {
                                        text: currentEmployee.totalHours.toFixed(1) + " h"
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignRight
                                        font.bold: true
                                        font.pixelSize: 14
                                        color: "#e74c3c"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// COMPOSANT pour une ligne de tâche - STYLE ORIGINAL CORRIGÉ
Component {
    id: taskRowComponent
    
    RowLayout {
        id: taskRow
        property var taskData
        property var employeeData
        property int indentLevel: 0
        
        Layout.fillWidth: true
        Layout.leftMargin: indentLevel * 20  // INDENTATION CORRECTE
        spacing: 10
        height: 35
        
        // Indentation visuelle
        Rectangle {
            width: indentLevel > 0 ? 15 : 0
            height: 1
            color: "#cccccc"
            visible: indentLevel > 0
        }
        
        // Icône selon le niveau - STYLE ORIGINAL
        Text {
            text: {
                if (indentLevel === 0) {
                    return taskData.hasChildren ? "📁" : "•"
                } else {
                    if (taskData.hasChildren) return "├─ 📁"
                    else return "└─ •"
                }
            }
            font.pixelSize: 12
            color: "#7f8c8d"
            width: 30
        }
        
        // Nom de la tâche - STYLE ORIGINAL
        Label {
            text: taskData.name
            Layout.preferredWidth: Math.max(120, 180 - indentLevel * 15)
            elide: Text.ElideRight
            font.bold: indentLevel === 0
            font.pixelSize: indentLevel === 0 ? 13 : 11
            color: indentLevel === 0 ? "#2c3e50" : "#7f8c8d"
        }
        
        // Bouton - - STYLE ORIGINAL
        Button {
            text: "−"
            width: 25
            height: 25
            font.pixelSize: 12
            enabled: taskData && employeeData
            
            onClicked: {
                console.log("➖ Bouton - cliqué")
                console.log("Task ID:", taskData.id, "Employee ID:", employeeData.id)
                
                if (!taskData || !employeeData) return
                
                var hours = main4Page.getEmployeeSubTaskHours(
                    employeeData.id, 
                    taskData.parentId || 0, 
                    taskData.id
                )
                
                if (hours > 0) {
                    main4Page.setEmployeeSubTaskHours(
                        employeeData.id,
                        taskData.parentId || 0,
                        taskData.id,
                        hours - 0.5
                    )
                }
            }
        }
        
        // Affichage heures - STYLE ORIGINAL
        Rectangle {
            width: 60
            height: 25
            radius: 3
            border.color: "#3498db"
            border.width: 1
            color: "#e8f4fd"
            
            Label {
                anchors.centerIn: parent
                text: {
                    if (!taskData || !employeeData) return "0.0 h"
                    var hours = main4Page.getEmployeeSubTaskHours(
                        employeeData.id,
                        taskData.parentId || 0,
                        taskData.id
                    )
                    return hours.toFixed(1) + " h"
                }
                font.bold: true
                font.pixelSize: 11
            }
        }
        
        // Bouton + - STYLE ORIGINAL
        Button {
            text: "+"
            width: 25
            height: 25
            font.pixelSize: 12
            enabled: taskData && employeeData
            
            onClicked: {
                console.log("➕ Bouton + cliqué")
                console.log("Task ID:", taskData.id, "Employee ID:", employeeData.id)
                
                if (!taskData || !employeeData) return
                
                var hours = main4Page.getEmployeeSubTaskHours(
                    employeeData.id,
                    taskData.parentId || 0,
                    taskData.id
                )
                
                main4Page.setEmployeeSubTaskHours(
                    employeeData.id,
                    taskData.parentId || 0,
                    taskData.id,
                    hours + 0.5
                )
            }
        }
        
        // Total tâche - STYLE ORIGINAL
        Label {
            text: "Total: " + (taskData.totalHours || 0).toFixed(1) + " h"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            color: "gray"
            font.pixelSize: 10
        }
    }
}
// Ajoutez cette fonction dans votre JavaScript (dans les fonctions de main4Page)
function createTaskDisplay(tasksContainer, tasks, employee, level = 0) {
    console.log("Création affichage tâches - Niveau:", level, "Nombre tâches:", tasks.length)
    
    for (var i = 0; i < tasks.length; i++) {
        var task = tasks[i]
        
        // Créer la tâche avec le Component
        var taskItem = Qt.createComponent("TaskRow.qml")
        if (taskItem.status === Component.Ready) {
            var taskObject = taskItem.createObject(tasksContainer, {
                taskData: task,
                employeeData: employee,
                indentLevel: level
            })
            
            // Ajouter les enfants
            if (task.children && task.children.length > 0) {
                createTaskDisplay(tasksContainer, task.children, employee, level + 1)
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
