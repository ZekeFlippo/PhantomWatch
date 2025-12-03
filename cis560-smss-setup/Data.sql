-- Data.sql - CIS560 - Group09

USE PhantomWatchDB;
GO

-- Clear existing data
DELETE FROM dbo.SightingBehaviors;
DELETE FROM dbo.UserSightings;
DELETE FROM dbo.Sightings;
DELETE FROM dbo.Entities;
DELETE FROM dbo.Behaviors;
DELETE FROM dbo.Users;
DELETE FROM dbo.Cities;
GO

-- Create staging tables
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

-- BULK INSERTS
BULK INSERT #Cities_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\CITIES_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', CODEPAGE='65001');

BULK INSERT #Users_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\USERS_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', CODEPAGE='65001');

BULK INSERT #Behaviors_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\BEHAVIORS_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', CODEPAGE='65001');

BULK INSERT #Entities_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\ENTITIES_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', CODEPAGE='65001');

BULK INSERT #Sightings_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\SIGHTINGS_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', CODEPAGE='65001');

BULK INSERT #UserSightings_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\USERSIGHTINGS_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', CODEPAGE='65001');

BULK INSERT #SightingBehaviors_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\SIGHTINGBEHAVIORS_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', CODEPAGE='65001');
GO

-- Load into real tables
INSERT INTO dbo.Cities (City, State, Region)
SELECT City, State, MIN(Region)
FROM #Cities_Staging
WHERE City IS NOT NULL AND State IS NOT NULL
GROUP BY City, State;

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
    0
FROM #Users_Staging
WHERE TRY_CAST(UserID AS INT) IS NOT NULL;

SET IDENTITY_INSERT dbo.Users OFF;

INSERT INTO dbo.Behaviors (BehaviorName, Description)
SELECT DISTINCT LTRIM(RTRIM(BehaviorName)), Description
FROM #Behaviors_Staging
WHERE BehaviorName IS NOT NULL;

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

SET IDENTITY_INSERT dbo.Sightings ON;

INSERT INTO dbo.Sightings (SightingID, EntityID, TimeObserved, City, State, CredibilityScore)
SELECT DISTINCT
    CAST(SightingID AS INT),
    CAST(EntityID AS INT),
    TRY_CONVERT(DATETIME, TimeObserved, 0),
    City,
    State,
    TRY_CAST(CredibilityScore AS INT)
FROM #Sightings_Staging
WHERE TRY_CAST(SightingID AS INT) IS NOT NULL
  AND TRY_CAST(EntityID AS INT) IS NOT NULL;

SET IDENTITY_INSERT dbo.Sightings OFF;

INSERT INTO dbo.UserSightings (SightingID, UserID)
SELECT DISTINCT
    CAST(SightingID AS INT),
    CAST(UserID AS INT)
FROM #UserSightings_Staging
WHERE TRY_CAST(SightingID AS INT) IS NOT NULL
  AND TRY_CAST(UserID AS INT) IS NOT NULL;

INSERT INTO dbo.SightingBehaviors (SightingID, BehaviorName)
SELECT DISTINCT
    CAST(SightingID AS INT),
    LTRIM(RTRIM(BehaviorName))
FROM #SightingBehaviors_Staging
WHERE TRY_CAST(SightingID AS INT) IS NOT NULL;
GO

-- Weighted Credibility Score Update
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

PRINT '*** PhantomWatchDB Data Load Completed Successfully!!! ***';
GO
