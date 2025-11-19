------------------------------------------------------------
-- FULL SETUP SCRIPT — PhantomWatchDB
-- (Tables + Staging Load + Fixes + New Features)
------------------------------------------------------------

------------------------------------------------------------
-- Step 1: Create Database (If Not Exists)
------------------------------------------------------------
IF DB_ID('PhantomWatchDB') IS NULL
BEGIN
    CREATE DATABASE PhantomWatchDB;
END
GO

USE PhantomWatchDB;
GO

------------------------------------------------------------
-- Step 2: Drop Tables in FK-Safe Order
------------------------------------------------------------
IF OBJECT_ID('dbo.UserVotes') IS NOT NULL DROP TABLE dbo.UserVotes;
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
    Behaviors    NVARCHAR(MAX) NULL,
    ScaryLevel   SMALLINT NOT NULL CHECK (ScaryLevel BETWEEN 1 AND 10)
);
GO

------------------------------------------------------------
-- Step 7: Sightings Table (CredibilityScore is now INT)
------------------------------------------------------------
CREATE TABLE dbo.Sightings
(
    SightingID       INT IDENTITY(1,1) PRIMARY KEY,
    EntityID         INT NOT NULL,
    TimeObserved     DATETIME NOT NULL,
    City             NVARCHAR(255) NOT NULL,
    State            NVARCHAR(50) NOT NULL,
    CredibilityScore INT NOT NULL,    -- UPDATED TYPE

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
-- Step 10: NEW TABLE — UserVotes
------------------------------------------------------------
CREATE TABLE dbo.UserVotes
(
    UserID INT NOT NULL,
    SightingID INT NOT NULL,
    VoteType CHAR(1) NOT NULL CHECK (VoteType IN ('U','D')),
    VotedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    PRIMARY KEY (UserID, SightingID),

    FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID),
    FOREIGN KEY (SightingID) REFERENCES dbo.Sightings(SightingID)
);
GO

PRINT 'All schema created successfully.';
GO



============================================================
=  DATA LOADING + CLEANUP + NORMALIZATION BELOW THIS LINE  =
============================================================

------------------------------------------------------------
-- Clear existing live data (safe for repeated dev loads)
------------------------------------------------------------
DELETE FROM dbo.SightingBehaviors;
DELETE FROM dbo.UserSightings;
DELETE FROM dbo.Sightings;
DELETE FROM dbo.Entities;
DELETE FROM dbo.Behaviors;
DELETE FROM dbo.Users;
DELETE FROM dbo.Cities;
GO

------------------------------------------------------------
-- Create temp staging tables
------------------------------------------------------------
CREATE TABLE #Cities_Staging (City NVARCHAR(255), State NVARCHAR(50), Region NVARCHAR(50));
CREATE TABLE #Users_Staging (UserID NVARCHAR(20), Email NVARCHAR(255), Alias NVARCHAR(100),
                             Name NVARCHAR(255), Age NVARCHAR(10), CreatedAt NVARCHAR(50),
                             DeletedAt NVARCHAR(50), isAdmin NVARCHAR(10));
CREATE TABLE #Behaviors_Staging (BehaviorName NVARCHAR(255), Description NVARCHAR(MAX));
CREATE TABLE #Entities_Staging (EntityID NVARCHAR(20), Name NVARCHAR(255), Behaviors NVARCHAR(MAX), ScaryLevel NVARCHAR(10));
CREATE TABLE #Sightings_Staging (SightingID NVARCHAR(20), EntityID NVARCHAR(20), TimeObserved NVARCHAR(50),
                                 City NVARCHAR(255), State NVARCHAR(50), CredibilityScore NVARCHAR(10));
CREATE TABLE #UserSightings_Staging (SightingID NVARCHAR(20), UserID NVARCHAR(20));
CREATE TABLE #SightingBehaviors_Staging (SightingID NVARCHAR(20), BehaviorName NVARCHAR(255));
GO


------------------------------------------------------------
-- BULK INSERTS
------------------------------------------------------------
-- Cities
BULK INSERT #Cities_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\CITIES_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', CODEPAGE='65001');

-- Users
BULK INSERT #Users_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\USERS_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', CODEPAGE='65001');

-- Behaviors
BULK INSERT #Behaviors_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\BEHAVIORS_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', CODEPAGE='65001');

-- Entities
BULK INSERT #Entities_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\ENTITIES_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', CODEPAGE='65001');

-- Sightings
BULK INSERT #Sightings_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\SIGHTINGS_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', CODEPAGE='65001');

-- UserSightings
BULK INSERT #UserSightings_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\USERSIGHTINGS_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', CODEPAGE='65001');

-- SightingBehaviors
BULK INSERT #SightingBehaviors_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\SIGHTINGBEHAVIORS_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', CODEPAGE='65001');
GO


------------------------------------------------------------
-- CLEANED LOAD INTO REAL TABLES
------------------------------------------------------------

-- Cities
INSERT INTO dbo.Cities (City, State, Region)
SELECT City, State, MIN(Region)
FROM #Cities_Staging
WHERE City IS NOT NULL AND State IS NOT NULL
GROUP BY City, State;


-- Users (force isAdmin = 0)
SET IDENTITY_INSERT dbo.Users ON;

INSERT INTO dbo.Users (UserID, Email, Alias, Name, Age, CreatedAt, DeletedAt, isAdmin)
SELECT DISTINCT
    CAST(UserID AS INT),
    Email,
    Alias,
    Name,
    TRY_CAST(Age AS SMALLINT),
    TRY_CONVERT(DATETIME, CreatedAt, 0),
    TRY_CONVERT(DATETIME, DeletedAt, 0),
    0   -- FORCE to 0
FROM #Users_Staging
WHERE UserID IS NOT NULL
  AND TRY_CAST(UserID AS INT) IS NOT NULL;

SET IDENTITY_INSERT dbo.Users OFF;


-- Behaviors
INSERT INTO dbo.Behaviors (BehaviorName, Description)
SELECT DISTINCT LTRIM(RTRIM(BehaviorName)), Description
FROM #Behaviors_Staging
WHERE BehaviorName IS NOT NULL;


-- Entities
SET IDENTITY_INSERT dbo.Entities ON;

INSERT INTO dbo.Entities (EntityID, Name, Behaviors, ScaryLevel)
SELECT DISTINCT
    CAST(EntityID AS INT),
    Name,
    Behaviors,
    TRY_CAST(ScaryLevel AS SMALLINT)
FROM #Entities_Staging
WHERE TRY_CAST(EntityID AS INT) IS NOT NULL
  AND TRY_CAST(ScaryLevel AS SMALLINT) BETWEEN 1 AND 10;

SET IDENTITY_INSERT dbo.Entities OFF;


-- Sightings (CredibilityScore loads as INT)
SET IDENTITY_INSERT dbo.Sightings ON;

INSERT INTO dbo.Sightings (SightingID, EntityID, TimeObserved, City, State, CredibilityScore)
SELECT DISTINCT
    CAST(SightingID AS INT),
    CAST(EntityID AS INT),
    TRY_CONVERT(DATETIME, TimeObserved, 0),
    City,
    State,
    TRY_CAST(CredibilityScore AS INT)
FROM #Sightings_Staging s
WHERE TRY_CAST(SightingID AS INT) IS NOT NULL
  AND TRY_CAST(EntityID AS INT) IS NOT NULL;

SET IDENTITY_INSERT dbo.Sightings OFF;


-- UserSightings
INSERT INTO dbo.UserSightings (SightingID, UserID)
SELECT DISTINCT
    CAST(SightingID AS INT),
    CAST(UserID AS INT)
FROM #UserSightings_Staging
WHERE TRY_CAST(SightingID AS INT) IS NOT NULL
  AND TRY_CAST(UserID AS INT) IS NOT NULL;


-- SightingBehaviors
INSERT INTO dbo.SightingBehaviors (SightingID, BehaviorName)
SELECT DISTINCT
    CAST(SightingID AS INT),
    LTRIM(RTRIM(BehaviorName))
FROM #SightingBehaviors_Staging
WHERE TRY_CAST(SightingID AS INT) IS NOT NULL;
GO


------------------------------------------------------------
-- Weighted Credibility Score Update (Final Step)
------------------------------------------------------------
UPDATE dbo.Sightings
SET CredibilityScore =
    CASE
        WHEN RAND(CHECKSUM(NEWID())) < 0.10 THEN
            CAST(RAND(CHECKSUM(NEWID())) * 2 AS INT)

        WHEN RAND(CHECKSUM(NEWID())) < 0.70 THEN
            2 + CAST(RAND(CHECKSUM(NEWID())) * 44 AS INT)

        ELSE
            46 + CAST(RAND(CHECKSUM(NEWID())) * 50 AS INT)
    END;
GO


PRINT '*** PhantomWatchDB Setup + Data Load Completed Successfully ***';
GO
