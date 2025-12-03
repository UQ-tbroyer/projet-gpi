CREATE DATABASE  crococode3;
USE crococode3;

-- -----------------------------------------------------
-- CREATION DES TABLES 
-- -----------------------------------------------------

CREATE TABLE `client` (
  `idClient` int NOT NULL AUTO_INCREMENT,
  `nomClient` varchar(100) NOT NULL,
  `statusClient` enum('active','inactive') DEFAULT 'active',
  PRIMARY KEY (`idClient`)
);

CREATE TABLE `departement` (
  `idDepartement` int NOT NULL AUTO_INCREMENT,
  `nomDepartement` varchar(100) NOT NULL,
  PRIMARY KEY (`idDepartement`)
);

CREATE TABLE `droit` (
  `idDroit` int NOT NULL AUTO_INCREMENT,
  `nomDroit` varchar(50) NOT NULL,
  `descDroit` text,
  PRIMARY KEY (`idDroit`)
);

CREATE TABLE `role` (
  `idRole` int NOT NULL AUTO_INCREMENT,
  `idDroit` int DEFAULT NULL,
  PRIMARY KEY (`idRole`),
  KEY `idDroit` (`idDroit`),
  CONSTRAINT `role_ibfk_1` FOREIGN KEY (`idDroit`) REFERENCES `droit` (`idDroit`)
);

-- Table de jointure RoleDroit (AJOUT CRITIQUE POUR LES PERMISSIONS)
CREATE TABLE RoleDroit (
    idRole INT NOT NULL,
    idDroit INT NOT NULL,
    PRIMARY KEY (idRole, idDroit),
    FOREIGN KEY (idRole) REFERENCES role(idRole),
    FOREIGN KEY (idDroit) REFERENCES droit(idDroit)
);

CREATE TABLE `employe` (
  `idEmploye` int NOT NULL AUTO_INCREMENT,
  `idDepartement` int DEFAULT NULL,
  `idRole` int DEFAULT NULL,
  `nomEmploye` varchar(100) NOT NULL,
  `prenomEmploye` varchar(100) DEFAULT NULL,
  `adresseMail` varchar(100) DEFAULT NULL,
  `motDePasse` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`idEmploye`),
  KEY `idDepartement` (`idDepartement`),
  KEY `idRole` (`idRole`),
  CONSTRAINT `employe_ibfk_1` FOREIGN KEY (`idDepartement`) REFERENCES `departement` (`idDepartement`),
  CONSTRAINT `employe_ibfk_2` FOREIGN KEY (`idRole`) REFERENCES `role` (`idRole`)
);


CREATE TABLE `equipe` (
  `idEquipe` int NOT NULL AUTO_INCREMENT,
  `etatEquipe` VARCHAR(255),
  PRIMARY KEY (`idEquipe`)
);

CREATE TABLE `employeequipe` (
  `idEmploye` int NOT NULL,
  `idEquipe` int NOT NULL,
  PRIMARY KEY (`idEmploye`,`idEquipe`),
  KEY `idEquipe` (`idEquipe`),
  CONSTRAINT `employeequipe_ibfk_1` FOREIGN KEY (`idEmploye`) REFERENCES `employe` (`idEmploye`),
  CONSTRAINT `employeequipe_ibfk_2` FOREIGN KEY (`idEquipe`) REFERENCES `equipe` (`idEquipe`)
);


CREATE TABLE `project` (
  `idProject` int NOT NULL AUTO_INCREMENT,
  `idClient` int DEFAULT NULL,
  `idDepartement` int DEFAULT NULL,
  `dataProject` date DEFAULT NULL,
  `tempRepository` varchar(255) DEFAULT NULL,
  `nomProject` varchar(100) DEFAULT NULL,
  `coutService` decimal(10,2) DEFAULT NULL,
  `tempsProject` DOUBLE,
  `etatProject` VARCHAR(50),
  `estTemplate` BOOLEAN,
  PRIMARY KEY (`idProject`),
  KEY `idClient` (`idClient`),
  KEY `idDepartement` (`idDepartement`),
  CONSTRAINT `project_ibfk_1` FOREIGN KEY (`idClient`) REFERENCES `client` (`idClient`),
  CONSTRAINT `project_ibfk_2` FOREIGN KEY (`idDepartement`) REFERENCES `departement` (`idDepartement`)
);

CREATE TABLE `tache` (
  `idTache` int NOT NULL AUTO_INCREMENT,
  `idProject` int DEFAULT NULL,
  `idEmploye` int DEFAULT NULL,
  `idParentTache` int DEFAULT NULL,
  `nomTache` varchar(100) DEFAULT NULL,
  `descTache` text,
  `heuresEstimees` DOUBLE,
  `heuresUtilisees` DOUBLE DEFAULT 0,
  `dateDebut` date DEFAULT NULL,
  `dateFin` date DEFAULT NULL,
  `etatTache` ENUM('A faire', 'En cours', 'A Tester', 'Termine') DEFAULT 'A faire',
  PRIMARY KEY (`idTache`),
  KEY `idProject` (`idProject`),
  KEY `idEmploye` (`idEmploye`),
  KEY `idParentTache` (`idParentTache`),
  CONSTRAINT `tache_ibfk_1` FOREIGN KEY (`idProject`) REFERENCES `project` (`idProject`),
  CONSTRAINT `tache_ibfk_2` FOREIGN KEY (`idEmploye`) REFERENCES `employe` (`idEmploye`),
  CONSTRAINT `tache_ibfk_3` FOREIGN KEY (`idParentTache`) REFERENCES `tache` (`idTache`) ON DELETE CASCADE
);

CREATE TABLE `soustache` (
  `idSousTache` int NOT NULL AUTO_INCREMENT,
  `idTache` int DEFAULT NULL,
  `dataSousTache` date DEFAULT NULL,
  `tempSousTache` time DEFAULT NULL,
  `nomSousTache` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`idSousTache`),
  KEY `idTache` (`idTache`),
  CONSTRAINT `soustache_ibfk_1` FOREIGN KEY (`idTache`) REFERENCES `tache` (`idTache`)
);



CREATE TABLE Template (
	idTemplate INT PRIMARY KEY AUTO_INCREMENT,
    tempTemplate TIME,
    coutTemplate DECIMAL(10,2),
    descTemplate TEXT,
    normTemplate VARCHAR(100)
);
-- -----------------------------------------------------
-- Table `crococode`.`TEMPLATETACHE`
-- -----------------------------------------------------
CREATE TABLE TemplateTache (
    idTemplateTache INT PRIMARY KEY AUTO_INCREMENT,
    idTemplate INT,
    descTemplateTache TEXT,
    tempTemplateTache TIME,
    nomTemplateTache VARCHAR(100),
    FOREIGN KEY (idTemplate) REFERENCES Template(idTemplate)
);

-- -----------------------------------------------------
-- Table `crococode`.`TEMPLATESOUSTACHE`
-- -----------------------------------------------------
CREATE TABLE TemplateSousTache (
    idTemplateSousTache INT PRIMARY KEY AUTO_INCREMENT,
    idTemplateTache INT,
    descTemplateSousTache TEXT,
    tempSousTache TIME,
    nomTemplateSousTache VARCHAR(100),
    FOREIGN KEY (idTemplateTache) REFERENCES TemplateTache(idTemplateTache)
);
-- -----------------------------------------------------
-- Table `crococode`.`FEUILLETEMPS`
-- -----------------------------------------------------
CREATE TABLE FeuilleTemps (
    idFeuilleTemps INT PRIMARY KEY,
    dateSemaine DATE,
    heuresTotal DOUBLE,
    statusApprobation VARCHAR(50),
    dateApprobation DATE,
    idEmploye INT,
    FOREIGN KEY (idEmploye) REFERENCES Employe(idEmploye)
);
-- -----------------------------------------------------
-- Table `crococode`.`SAISIETEMPS`
-- -----------------------------------------------------
CREATE TABLE SaisieTemps (
    idSaisieTemps INT PRIMARY KEY,
    dateSaisie DATE,
    heures DOUBLE,
    description TEXT,
    idFeuilleTemps INT,
    FOREIGN KEY (idFeuilleTemps) REFERENCES FeuilleTemps(idFeuilleTemps)
);

-- -----------------------------------------------------
-- Table `crococode`.`SUIVITEMPS`
-- ----------------------------------------------------
CREATE TABLE SuiviTemps (
    idSuiviTemps INT PRIMARY KEY AUTO_INCREMENT,
    idEmploye INT,
    idTache INT,
    dateTravail DATE NOT NULL,
    heureDebut TIME NOT NULL,
    heureFin TIME NOT NULL,
    description TEXT,
    statut ENUM('En attente', 'Validé', 'Rejeté') DEFAULT 'En attente',
    idFeuilleTemps INT,
    FOREIGN KEY (idEmploye) REFERENCES Employe(idEmploye),
    FOREIGN KEY (idTache) REFERENCES Tache(idTache),
    FOREIGN KEY (idFeuilleTemps) REFERENCES FeuilleTemps(idFeuilleTemps)
);

-- -----------------------------------------------------
-- PROCEDURES STOCKÉES 
-- -----------------------------------------------------

-- ----------------------------------------------------
-- Stored Procedure pour créer un projet
-- ----------------------------------------------------
DELIMITER //

CREATE PROCEDURE CreateProject (
    IN p_idClient INT,
    IN p_idDepartement INT,
    IN p_dataProject DATE,
    IN p_tempRepository VARCHAR(255),
    IN p_nomProject VARCHAR(100),
    IN p_coutService DECIMAL(10,2)
)
BEGIN
    INSERT INTO Project (
        idClient,
        idDepartement,
        dataProject,
        tempRepository,
        nomProject,
        coutService
    )
    VALUES (
        p_idClient,
        p_idDepartement,
        p_dataProject,
        p_tempRepository,
        p_nomProject,
        p_coutService
    );
END //

DELIMITER ;

-- ----------------------------------------------------
-- Stored Procedure pour récupérer tous les projets
-- ----------------------------------------------------
DELIMITER //

CREATE PROCEDURE GetAllProjects ()
BEGIN
    SELECT
        P.idProject,
        P.nomProject,
        P.dataProject,
        C.nomClient,
        D.nomDepartement,
        P.coutService
    FROM
        Project P
    JOIN
        Client C ON P.idClient = C.idClient
    JOIN
        Departement D ON P.idDepartement = D.idDepartement
    ORDER BY
        P.dataProject DESC;
END //

DELIMITER ;

-- ----------------------------------------------------
-- Stored Procedure pour créer une tâche 
-- Colonne 'tempsTache' remplacée par 'heuresEstimees'
-- ----------------------------------------------------
DELIMITER //
CREATE PROCEDURE CreateTache (
    IN p_idProject INT,
    IN p_nomTache VARCHAR(100),
    IN p_descTache TEXT,
    IN p_heuresEstimees DOUBLE, 
    IN p_idEmploye INT
)
BEGIN
    INSERT INTO Tache (idProject, nomTache, descTache, heuresEstimees, idEmploye) 
    VALUES (p_idProject, p_nomTache, p_descTache, p_heuresEstimees, p_idEmploye);
END //
DELIMITER ;

-- -----------------------------------------------------------------------
-- Stored Procedure pour récupérer les tâches d'un projet 
-- -----------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE GetTachesByProject (
    IN p_idProject INT
)
BEGIN
    SELECT
        T.idTache,
        T.nomTache,
        T.descTache,
        T.dateDebut, 
        T.heuresEstimees, 
        CONCAT(E.prenomEmploye, ' ', E.nomEmploye) AS Assignee
    FROM
        Tache T
    LEFT JOIN
        Employe E ON T.idEmploye = E.idEmploye 
    WHERE
        T.idProject = p_idProject
    ORDER BY
        T.dateDebut ASC; 
END //

DELIMITER ;

-- ----------------------------------------------------
-- Stored Procedure pour créer un nouvel employé 
-- ----------------------------------------------------
DELIMITER //
CREATE PROCEDURE CreateEmploye (
    IN p_idDepartement INT, 
    IN p_idRole INT,
    IN p_nomEmploye VARCHAR(100),
    IN p_prenomEmploye VARCHAR(100),
    IN p_adresseMail VARCHAR(100),
    IN p_motDePasse VARCHAR(255)
)
BEGIN
    INSERT INTO Employe (idDepartement, idRole, nomEmploye, prenomEmploye, adresseMail, motDePasse) 
    VALUES (p_idDepartement, p_idRole, p_nomEmploye, p_prenomEmploye, p_adresseMail, p_motDePasse);
END //
DELIMITER ;


-- --------------------------------------------------------------------
-- Stored Procedure pour récupérer un employé pour la connexion
-- ---------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE AuthenticateEmploye (
    IN p_adresseMail VARCHAR(100),
    IN p_motDePasse VARCHAR(255)
)
BEGIN
    SELECT
        E.idEmploye,
        E.nomEmploye,
        E.prenomEmploye,
        E.adresseMail,
        R.idRole,
        D.nomDroit
    FROM
        Employe E
    JOIN
        Role R ON E.idRole = R.idRole
    JOIN
        Droit D ON R.idDroit = D.idDroit
    WHERE
        E.adresseMail = p_adresseMail AND E.motDePasse = p_motDePasse;
END //

DELIMITER ;

-- -----------------------------------------------------------
-- Stored Procedure pour assigner ou réassigner une tâche 
-- -----------------------------------------------------------
DELIMITER //

CREATE PROCEDURE AssignTacheToEmploye (
    IN p_idTache INT,
    IN p_idEmploye INT -- NULL pour désassigner
)
BEGIN
    UPDATE Tache
    SET idEmploye = p_idEmploye 
    WHERE idTache = p_idTache;
END //

DELIMITER ;
-- ----------------------------------------------------
-- Stored Procedure pour enregistrer le temps 
-- ----------------------------------------------------
DELIMITER //
CREATE PROCEDURE LogTime (
    IN p_idEmploye INT,
    IN p_idTache INT,
    IN p_dateTravail DATE,
    IN p_heureDebut TIME,
    IN p_heureFin TIME,
    IN p_description TEXT,
    IN p_idFeuilleTemps INT
)
BEGIN
    DECLARE v_duree DOUBLE;
    -- Calcul de la durée en heures
    SET v_duree = TIMESTAMPDIFF(MINUTE, p_heureDebut, p_heureFin) / 60;

    INSERT INTO SuiviTemps (idEmploye, idTache, dateTravail, heureDebut, heureFin, description, idFeuilleTemps)
    VALUES (p_idEmploye, p_idTache, p_dateTravail, p_heureDebut, p_heureFin, p_description, p_idFeuilleTemps);

    UPDATE Tache
    SET heuresUtilisees = heuresUtilisees + v_duree
    WHERE idTache = p_idTache;
END //
DELIMITER ;


-- -----------------------------------------------------------------
-- Stored Procedure pour récupérer le temps total par tâche 
-- Colonne 'tempsTotal' calculée
-- -----------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE GetTotalTimeForTache (
    IN p_idTache INT
)
BEGIN
    SELECT
        SEC_TO_TIME(SUM(TIMESTAMPDIFF(SECOND, heureDebut, heureFin))) AS TempsCumule 
    FROM
        SuiviTemps
    WHERE
        idTache = p_idTache;
END //

DELIMITER ;

-- --------------------------------------------------------------------------
-- Stored Procedure pour créer un nouveau rôle et l'associer à un droit
-- --------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE CreateRole (
    IN p_idDroit INT
)
BEGIN
    INSERT INTO Role (
        idDroit
    )
    VALUES (
        p_idDroit
    );
END //

DELIMITER ;
-- ----------------------------------------------------
-- Stored Procedure pour créer les permissions
-- ----------------------------------------------------
DELIMITER //

CREATE PROCEDURE CreateDroit (
    IN p_nomDroit VARCHAR(50),
    IN p_descDroit TEXT
)
BEGIN
    INSERT INTO Droit (
        nomDroit,
        descDroit
    )
    VALUES (
        p_nomDroit,
        p_descDroit
    );
END //

DELIMITER ;
-- -------------------------------------------------------------------
-- Stored Procedure pour récupérer tous les rôles et leurs droits
-- -------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE GetAllRolesWithDroits ()
BEGIN
    SELECT
        R.idRole,
        D.idDroit,
        D.nomDroit,
        D.descDroit
    FROM
        Role R
    JOIN
        Droit D ON R.idDroit = D.idDroit
    ORDER BY
        R.idRole;
END //

DELIMITER ;

-- la Gestion des Permissions--
-- -------------------------------------------------------------------
-- Stored Procedure: Assigner un Droit à un Rôle (AssignDroitToRole)
-- -------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE AssignDroitToRole (
    IN p_idRole INT,
    IN p_idDroit INT
)
BEGIN
    -- Utilisation de la table RoleDroit
    INSERT INTO RoleDroit (idRole, idDroit)
    VALUES (p_idRole, p_idDroit);
END //

DELIMITER ;

-- ------------------------------------------------------------------------------
-- Stored Procedure: Vérifier la Permission d'un Employé (CheckEmployePermission)
-- -------------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE CheckEmployePermission (
    IN p_idEmploye INT,
    IN p_nomDroit VARCHAR(50)
)
BEGIN
    SELECT
        COUNT(*) > 0 AS HasPermission
    FROM
        Employe E
    JOIN
        Role R ON E.idRole = R.idRole
    JOIN
        RoleDroit RD ON R.idRole = RD.idRole 
    JOIN
        Droit D ON RD.idDroit = D.idDroit
    WHERE
        E.idEmploye = p_idEmploye AND D.nomDroit = p_nomDroit;
END //

DELIMITER ;
-- --------------------------------------------------------------
-- Stored Procedures pour la Personnalisation (Templates)
-- ----------------------------------------------------------------
-- Stored Procedure: Créer un Modèle de Tâches (CreateTemplate)

DELIMITER //

CREATE PROCEDURE CreateTemplate (
    IN p_tempTemplate TIME,
    IN p_coutTemplate DECIMAL(10,2),
    IN p_descTemplate TEXT,
    IN p_normTemplate VARCHAR(100)
)
BEGIN
    INSERT INTO Template (
        tempTemplate,
        coutTemplate,
        descTemplate,
        normTemplate
    )
    VALUES (
        p_tempTemplate,
        p_coutTemplate,
        p_descTemplate,
        p_normTemplate
    );
END //

DELIMITER ;

-- --------------------------------------------------------------------
-- Stored Procedure: Ajouter une Tâche au Modèle (AddTacheToTemplate)
-- --------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE AddTacheToTemplate (
    IN p_idTemplate INT,
    IN p_nomTemplateTache VARCHAR(100),
    IN p_descTemplateTache TEXT,
    IN p_tempTemplateTache TIME
)
BEGIN
    INSERT INTO TemplateTache (
        idTemplate,
        nomTemplateTache,
        descTemplateTache,
        tempTemplateTache
    )
    VALUES (
        p_idTemplate,
        p_nomTemplateTache,
        p_descTemplateTache,
        p_tempTemplateTache
    );
END //

DELIMITER ;

-- ---------------------------------------------------------------------------
-- Stored Procedure: Appliquer un Modèle à un Projet (ApplyTemplateToProject) 
-- ----------------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE ApplyTemplateToProject (
    IN p_idProject INT,
    IN p_idTemplate INT
)
BEGIN
    -- Insère les tâches (TemplateTache) dans la table Tache
    INSERT INTO Tache (
        idProject,
        dateDebut, 
        idEmploye, 
        nomTache,
        descTache,
        heuresEstimees 
    )
    SELECT
        p_idProject, -- Le projet cible
        CURDATE(),   -- Date du jour par défaut
        NULL,        -- Non assigné
        TT.nomTemplateTache,
        TT.descTemplateTache,
        TIME_TO_SEC(TT.tempTemplateTache) / 3600 -- Conversion de TIME en DOUBLE (heures)
    FROM
        TemplateTache TT
    WHERE
        TT.idTemplate = p_idTemplate;
END //

DELIMITER ;

-- ------------------------------------------------------------------
-- SPRINT 4 : Sous-tâches et Permissions Avancées
-- ------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE CreateSousTache (
    IN p_idTache INT,
    IN p_nomSousTache VARCHAR(255),
    IN p_descSousTache TEXT,
    IN p_tempsSousTache DOUBLE
)
BEGIN
    
    INSERT INTO SousTache (idTache, nomSousTache, descSousTache, tempSousTache)
    VALUES (p_idTache, p_nomSousTache, p_descSousTache, p_tempsSousTache);
END //
DELIMITER ;

-- ------------------------------------------------------------------
-- SPRINT 5 : Création de projet à partir de templates
-- ------------------------------------------------------------------
DELIMITER //

CREATE PROCEDURE CreateProjectFromTemplate (
    IN p_idTemplate INT,
    IN p_idClient INT,
    IN p_idDepartement INT,
    IN p_dataProject DATE,
    IN p_tempRepository VARCHAR(255),
    IN p_nomProject VARCHAR(100),
    OUT p_newProjectId INT
)
BEGIN
    DECLARE v_tempTemplate TIME;
    DECLARE v_coutTemplate DECIMAL(10,2);
    DECLARE v_descTemplate TEXT;
    DECLARE v_normTemplate VARCHAR(100);

    -- Récupérer les informations du template
    SELECT
        tempTemplate,
        coutTemplate,
        descTemplate,
        normTemplate
    INTO
        v_tempTemplate,
        v_coutTemplate,
        v_descTemplate,
        v_normTemplate
    FROM Template
    WHERE idTemplate = p_idTemplate;

    -- Créer le projet à partir du template
    INSERT INTO Project (
        idClient,
        idDepartement,
        dataProject,
        tempRepository,
        nomProject,
        coutService,
        tempsProject,
        etatProject,
        estTemplate
    )
    VALUES (
        p_idClient,
        p_idDepartement,
        p_dataProject,
        p_tempRepository,
        p_nomProject,
        v_coutTemplate,
        TIME_TO_SEC(v_tempTemplate)/3600, -- Convertir TIME en heures
        'En cours',
        FALSE
    );

    -- Retourner l'ID du nouveau projet
    SET p_newProjectId = LAST_INSERT_ID();
END //

DELIMITER ;

-- ----------------------------------------------------------------------------
-- SCRIPT DE MODIFICATION DES CONTRAINTES POUR LA SUPPRESSION EN CASCADE
-- ----------------------------------------------------------------------------

--  Désactive temporairement la vérification des clés étrangères.
SET FOREIGN_KEY_CHECKS = 0;

-- Suppression de la contrainte Projet-Tâche  
ALTER TABLE Tache DROP FOREIGN KEY  fk_project_tache; 

-- Suppression de la contrainte Tâche-Parent 
ALTER TABLE Tache DROP FOREIGN KEY  fk_parent_tache;

-- Ajoute la contrainte Project -> Tache avec ON DELETE CASCADE
-- Désormais, la suppression d'un Project entraîne la suppression de toutes ses Taches.
ALTER TABLE Tache
ADD CONSTRAINT fk_project_tache
FOREIGN KEY (idProject)
REFERENCES Project(idProject)
ON DELETE CASCADE;

-- Ajoute la contrainte Tache -> Tache (Parent) avec ON DELETE CASCADE
-- Désormais, la suppression d'une Tache parente entraîne la suppression récursive de toutes ses sous-Taches.
ALTER TABLE Tache
ADD CONSTRAINT fk_parent_tache
FOREIGN KEY (idParentTache)
REFERENCES Tache(idTache)
ON DELETE CASCADE;

-- Réactive la vérification des clés étrangères.
SET FOREIGN_KEY_CHECKS = 1;
