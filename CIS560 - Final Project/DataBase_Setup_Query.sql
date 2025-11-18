------------------------------------------------------------
-- Step 1: Create Database
------------------------------------------------------------
IF DB_ID('PhantomWatchDB') IS NULL
BEGIN
    CREATE DATABASE PhantomWatchDB;
END
GO

USE PhantomWatchDB;
GO

------------------------------------------------------------
-- Step 2: Drop Tables in Correct Order (Development Only)
------------------------------------------------------------
IF OBJECT_ID('dbo.SightingBehaviors') IS NOT NULL DROP TABLE dbo.SightingBehaviors;
IF OBJECT_ID('dbo.UserSightings') IS NOT NULL DROP TABLE dbo.UserSightings;
IF OBJECT_ID('dbo.Sightings') IS NOT NULL DROP TABLE dbo.Sightings;
IF OBJECT_ID('dbo.Entities') IS NOT NULL DROP TABLE dbo.Entities;
IF OBJECT_ID('dbo.Behaviors') IS NOT NULL DROP TABLE dbo.Behaviors;
IF OBJECT_ID('dbo.Cities') IS NOT NULL DROP TABLE dbo.Cities;
IF OBJECT_ID('dbo.Users') IS NOT NULL DROP TABLE dbo.Users;
GO


------------------------------------------------------------
-- Step 3: Users Table
------------------------------------------------------------
CREATE TABLE dbo.Users
(
    UserID        INT IDENTITY(1,1) PRIMARY KEY,
    Email         NVARCHAR(255) NOT NULL UNIQUE,
    Alias         NVARCHAR(100) NOT NULL,
    Name          NVARCHAR(255) NOT NULL,
    Age           SMALLINT CHECK (Age >= 0 AND Age <= 130),
    CreatedAt     DATETIME NOT NULL DEFAULT(GETDATE()),
    DeletedAt     DATETIME NULL,
    isAdmin       BIT NOT NULL DEFAULT(0)
);
GO


------------------------------------------------------------
-- Step 4: Cities Table
-- Functional Dependency: (City, State) → Region
------------------------------------------------------------
CREATE TABLE dbo.Cities
(
    City   NVARCHAR(255) NOT NULL,
    State  NVARCHAR(50) NOT NULL,
    Region NVARCHAR(50) NOT NULL,

    CONSTRAINT PK_Cities PRIMARY KEY (City, State)
);
GO


------------------------------------------------------------
-- Step 5: Behaviors Table
------------------------------------------------------------
CREATE TABLE dbo.Behaviors
(
    BehaviorName NVARCHAR(255) NOT NULL PRIMARY KEY,
    Description  NVARCHAR(MAX) NULL
);
GO


------------------------------------------------------------
-- Step 6: Entities Table
------------------------------------------------------------
CREATE TABLE dbo.Entities
(
    EntityID     INT IDENTITY(1,1) PRIMARY KEY,
    Name         NVARCHAR(255) NOT NULL UNIQUE,
    Behaviors    NVARCHAR(MAX) NULL,        -- text description only
    ScaryLevel   SMALLINT NOT NULL CHECK (ScaryLevel BETWEEN 1 AND 10)
);
GO


------------------------------------------------------------
-- Step 7: Sightings Table
------------------------------------------------------------
CREATE TABLE dbo.Sightings
(
    SightingID       INT IDENTITY(1,1) PRIMARY KEY,
    EntityID         INT NOT NULL,
    TimeObserved     DATETIME NOT NULL,
    City             NVARCHAR(255) NOT NULL,
    State            NVARCHAR(50) NOT NULL,
    CredibilityScore SMALLINT NOT NULL CHECK (CredibilityScore BETWEEN 1 AND 10),

    -- Foreign Keys
    CONSTRAINT FK_Sightings_Entities FOREIGN KEY (EntityID)
        REFERENCES dbo.Entities(EntityID),

    CONSTRAINT FK_Sightings_Cities FOREIGN KEY (City, State)
        REFERENCES dbo.Cities(City, State)
);
GO


------------------------------------------------------------
-- Step 8: UserSightings (M:N)
------------------------------------------------------------
CREATE TABLE dbo.UserSightings
(
    SightingID INT NOT NULL,
    UserID     INT NOT NULL,

    CONSTRAINT PK_UserSightings PRIMARY KEY (SightingID, UserID),

    CONSTRAINT FK_UserSightings_Sightings FOREIGN KEY (SightingID)
        REFERENCES dbo.Sightings(SightingID),

    CONSTRAINT FK_UserSightings_Users FOREIGN KEY (UserID)
        REFERENCES dbo.Users(UserID)
);
GO


------------------------------------------------------------
-- Step 9: SightingBehaviors (M:N)
------------------------------------------------------------
CREATE TABLE dbo.SightingBehaviors
(
    SightingID   INT NOT NULL,
    BehaviorName NVARCHAR(255) NOT NULL,

    CONSTRAINT PK_SightingBehaviors PRIMARY KEY (SightingID, BehaviorName),

    CONSTRAINT FK_SightingBehaviors_Sightings FOREIGN KEY (SightingID)
        REFERENCES dbo.Sightings(SightingID),

    CONSTRAINT FK_SightingBehaviors_Behaviors FOREIGN KEY (BehaviorName)
        REFERENCES dbo.Behaviors(BehaviorName)
);
GO

------------------------------------------------------------
-- ALL TABLES SUCCESSFULLY CREATED
------------------------------------------------------------
PRINT 'PhantomWatchDB schema successfully created.';
GO
