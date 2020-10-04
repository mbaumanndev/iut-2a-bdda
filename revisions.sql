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
