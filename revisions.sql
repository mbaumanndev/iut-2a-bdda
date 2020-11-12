-- On vérifie que la base n'existe pas
IF (DB_ID(N'DUT2_Demo') IS NULL)
    CREATE DATABASE [DUT2_Demo]

GO

-- On s epositionne sur la base
USE [DUT2_Demo]

GO

-- On créée la table si elle n'existe pas
IF NOT EXISTS (
    SELECT  [name]
    FROM    [sysobjects]
    WHERE   [name] = 'Post_PST'
            AND [xtype] = 'U'
)
    CREATE TABLE [dbo].[Post_PST] (
        [Id] INT IDENTITY(1, 1) PRIMARY KEY, -- Identité -> Auto incrément
        [Titre] NVARCHAR(255) NOT NULL,
        [Contenu] NVARCHAR(MAX),
        [Publication] DATETIME2 NOT NULL,
        [Revision] DATETIME2
    )

GO

-- Si on n'a pas de données, on en insère
IF NOT EXISTS (
    SELECT TOP 1 [Id]
    FROM [dbo].[Post_PST]
)
BEGIN
    INSERT INTO [DUT2_Demo].[dbo].[Post_PST] ([Titre], [Contenu], [Publication])
    VALUES  (N'Mon titre', N'Mon contenu', GETDATE()),
            (N'Autre titre', N'Autre contenu', DATEADD(hh, 1, GETDATE()))

    DELETE FROM [dbo].[Post_PST]
    WHERE       [Id] = 1;

    UPDATE  [dbo].[Post_PST]
    SET     [Revision] = DATEADD(hh, -1, GETDATE())
    WHERE   [Revision] IS NULL AND [Id] % 2 = 0
END
GO

IF NOT EXISTS (
    SELECT  [name]
    FROM    [sysobjects]
    WHERE   [name] = 'Auteur_AUR'
            AND [xtype] = 'U'
)
BEGIN
    -- Table Auteur_AUR
    -- Id UNIQUE IDENTIFIER
    -- Nom
    -- Prénom

    -- Insérer des auteurs
    -- Modifier Post pour ajouter FK vers Auteur_AUR
    CREATE TABLE [dbo].[Auteur_AUR] (
        [Id] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        [Nom] NVARCHAR(255) NOT NULL,
        [Prenom] NVARCHAR(255) NOT NULL
    )

    INSERT INTO [dbo].[Auteur_AUR] ([Id], [Nom], [Prenom])
    VALUES      ('af249160-c073-4bf5-a646-31c83c8c5a0e', N'BAUMANN', N'Maxime'),
                (null, N'DELPECH', N'Nicolas');
    
    DECLARE @AuteurId UNIQUEIDENTIFIER

    SELECT TOP 1 @AuteurId = [Id]
    FROM [dbo].[Auteur_AUR]

    ALTER TABLE [dbo].[Post_PST]
    ADD [Auteur_Id] UNIQUEIDENTIFIER NOT NULL
    CONSTRAINT AuteurDefaut DEFAULT 'af249160-c073-4bf5-a646-31c83c8c5a0e'
    
    ALTER TABLE [dbo].[Post_PST]
    ADD CONSTRAINT FK_PST_AUR FOREIGN KEY ([Auteur_Id])
    REFERENCES [dbo].[Auteur_AUR] ([Id])

    SELECT * FROM [dbo].[Post_PST] AS [PST]
    INNER JOIN [dbo].[Auteur_AUR] AS [AUR] ON [AUR].[Id] = [PST].[Auteur_Id]

    SELECT [AUR].* FROM [dbo].[Post_PST] AS [PST]
    RIGHT JOIN [dbo].[Auteur_AUR] AS [AUR]
        ON [AUR].[Id] = [PST].[Auteur_Id]
    WHERE [PST].[Id] IS NULL
END

GO

CREATE OR ALTER VIEW [dbo].[VuesDerniersArticles]
AS
    SELECT [PST].[Id], [PST].[Titre], [PST].[Publication], [AUR].[Nom]
    FROM [dbo].[Post_PST] AS [PST] (NOLOCK)
    INNER JOIN [dbo].[Auteur_AUR] AS [AUR] (NOLOCK)
        ON [PST].[Auteur_Id] = [AUR].[Id]
    WHERE DATEADD(hh, -48, GETDATE()) < [PST].[Publication] /* Moins 48h */
    OR DATEADD(hh, -12, GETDATE()) < [PST].[Revision] /* Moins 12h */

GO

/* Fonctions utilisateur (UDF -> User Defined Functions) */
CREATE OR ALTER FUNCTION [dbo].[RecupereNbAuteurs](@NbAuteur INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP(@NbAuteur) [Nom], [Prenom]
    FROM [dbo].[Auteur_AUR] (NOLOCK)
)

GO

CREATE OR ALTER FUNCTION [dbo].[CompteAuteurs]()
RETURNS BIGINT
AS
BEGIN
    DECLARE @Resultat BIGINT

    SELECT @Resultat = COUNT(*)
    FROM [dbo].[Auteur_AUR] (NOLOCK)

    RETURN(@Resultat)
END

GO

-- Triggers et curseurs

CREATE OR ALTER TRIGGER [dbo].[trig_UpdateRevisionPost]
    ON [dbo].[Post_PST] -- On attache le trigger à une table
    AFTER UPDATE -- On attache le trigger à un événement (insert, update, delete)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PstId INT
    DECLARE @NbItems INT

    SELECT @NbItems = COUNT(*) FROM INSERTED -- Les enregistrements concernés par le trigger sont enregistrés dans une sorte de table

    -- Les curseurs sont coûteux en ressources, on évite d'en créer un pour un seul élément
    IF @NbItems > 1
    BEGIN
        DECLARE curs CURSOR FOR SELECT [Id] FROM INSERTED -- Le curseur est une variable "pointant" sur une requête

        OPEN curs -- On ouvre le curseur pour charger les résultats

        FETCH NEXT FROM curs INTO @PstId
        WHILE (@@FETCH_STATUS = 0) -- Tant qu'on peut itérer
        BEGIN
            UPDATE [dbo].[Post_PST]
            SET [Revision] = GETDATE()
            WHERE [Id] = @PstId

            FETCH NEXT FROM curs INTO @PstId
        END

        -- Important ! On ferme le curseur et on libère sa mémoire
        CLOSE curs
        DEALLOCATE curs
    END
    ELSE
    BEGIN
        SELECT TOP 1 @PostId = [Id] FROM INSERTED

        UPDATE [dbo].[Post_PST]
        SET [Revision] = GETDATE()
        WHERE [Id] = @PstId
    END
END

GO

-- Transactions

BEGIN TRANSACTION MA_TRANSACTION --On nomme la transaction
BEGIN TRY
    INSERT INTO [dbo].[Auteur_AUR] ([Nom], [Prenom])
    VALUES      (N'DURAND', N'David')

    INSERT INTO [dbo].[Auteur_AUR] ([Id], [Nom], [Prenom])
    VALUES      ('af249160-c073-4bf5-a646-31c83c8c5a0e', N'BAUMANN', N'Maxime')

    INSERT INTO [dbo].[Auteur_AUR] ([Nom], [Prenom])
    VALUES      (N'CLERENTIN', N'Arnaud')

    COMMIT TRANSACTION MA_TRANSACTION -- Commit persiste les écritures en BDD, si on arrive jusque là
END TRY
BEGIN CATCH
    -- Le rollback va annuler l'ensemble des modifications effectuées dans la transaction
    ROLLBACK TRANSACTION MA_TRANSACTION

    -- On peut récupérer des informations sur l'erreur qui est survenue
    SELECT ERROR_NUMBER(), ERROR_MESSAGE()
END CATCH

GO

-- Procédures stockées

CREATE OR ALTER PROCEDURE [dbo].[prc_CreationPost]
    @AuteurId UNIQUEIDENTIFIER,
    @Titre NVARCHAR(255),
    @Content NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION CreaPst
    BEGIN TRY
        IF NOT EXISTS (
            SELECT  [Id]
            FROM    [dbo].[Auteur_AUR]
            WHERE   [Id] = @AuteurId)
            THROW 51000, 'L''auteur n''existe pas', 1

        INSERT INTO [dbo].[Post_PST] ([Titre], [Contenu])
        VALUES (@Titre, @Content)

        COMMIT TRANSACTION CreaPst

        SELECT 0 AS [Number], N'' AS [Message]
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION CreaPst

        SELECT ERROR_NUMBER() AS [Number], ERROR_MESSAGE() AS [Message]
    END CATCH
END;

GO

-- Cette procédure utilise une variable de type Table
-- Ces variables sont créées en mémoire et ne peuvent pas être utilisée dans des transactions
-- Elles peuvent servir de paramètre pour des procédures et fonctions
-- On ne peut également s'en servir qu'entre deux "GO"
-- /!\ Ce ne sont pas des tables temporaires
CREATE OR ALTER PROCEDURE [dbo].[prc_InsAuteurs]
    @Auteurs NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AuteurTable AS TABLE (
        [Nom] NVARCHAR(255),
        [Prenom] NVARCHAR(255)
    )

    INSERT INTO @AuteurTable([Nom], [Prenom])
    SELECT	PARSENAME(REPLACE([value], ';', '.'), 2) AS [Prenom],
            PARSENAME(REPLACE([value], ';', '.'), 1) AS [Nom]
    FROM    STRING_SPLIT(@Auteurs, '|')
    
    INSERT INTO [dbo].[Auteur_AUR] ([Nom], [Prenom])
    SELECT [Nom], [Prenom]
    FROM @AuteurTable
END

GO

-- Cette procédure utilise une "WITH COMMON_TABLE_EXPRESSION"
-- Elles expirent après la première instruction qui n'est pas une "WITH COMMON_TABLE_EXPRESSION"
-- Elles doivent forcément être précédées par un point-virgule
CREATE OR ALTER PROCEDURE [dbo].[prc_InsAuteurs]
    @Auteurs NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION InsAut
    BEGIN TRY
        ;WITH Auteurs AS (
            SELECT	CAST(PARSENAME(REPLACE([value], ';', '.'), 2), NVARCHAR(255)) AS [Prenom],
                    CAST(PARSENAME(REPLACE([value], ';', '.'), 1), NVARCHAR(255)) AS [Nom]
            FROM    STRING_SPLIT(@Auteurs, '|')
        )

        INSERT INTO [dbo].[Auteur_AUR] ([Nom], [Prenom])
        SELECT [Nom], [Prenom]
        FROM Auteurs

        COMMIT TRANSACTION InsAut

        SELECT 0 AS [Number], N'' AS [Message]
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION InsAut

        SELECT ERROR_NUMBER() AS [Number], ERROR_MESSAGE() AS [Message]
    END CATCH
END

GO

DECLARE @Table TABLE (
    [Number] INT,
    [Message] NVARCHAR(MAX)
)

INSERT INTO @Table
EXEC [dbo].[prc_InsAuteurs] @Auteurs = N'Prénom;NOM|Prénom1;NOM1|Prénom2;Nom2'

SELECT * FROM @Table

GO

