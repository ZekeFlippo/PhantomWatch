USE PhantomWatchDB;
GO

PRINT '--- Clearing existing data (if any) ---';
------------------------------------------------------------
-- Clear real tables in FK-safe order
------------------------------------------------------------
IF OBJECT_ID('dbo.SightingBehaviors', 'U') IS NOT NULL DELETE FROM dbo.SightingBehaviors;
IF OBJECT_ID('dbo.UserSightings', 'U')      IS NOT NULL DELETE FROM dbo.UserSightings;
IF OBJECT_ID('dbo.Sightings', 'U')          IS NOT NULL DELETE FROM dbo.Sightings;
IF OBJECT_ID('dbo.Entities', 'U')           IS NOT NULL DELETE FROM dbo.Entities;
IF OBJECT_ID('dbo.Behaviors', 'U')          IS NOT NULL DELETE FROM dbo.Behaviors;
IF OBJECT_ID('dbo.Users', 'U')              IS NOT NULL DELETE FROM dbo.Users;
IF OBJECT_ID('dbo.Cities', 'U')             IS NOT NULL DELETE FROM dbo.Cities;
GO


PRINT '--- Creating temporary staging tables (session only) ---';
------------------------------------------------------------
-- NO real tables are created. These exist only for this script.
------------------------------------------------------------

CREATE TABLE #Cities_Staging
(
    City   NVARCHAR(255) NULL,
    State  NVARCHAR(50)  NULL,
    Region NVARCHAR(50)  NULL
);

CREATE TABLE #Users_Staging
(
    UserID     NVARCHAR(20)  NULL,
    Email      NVARCHAR(255) NULL,
    Alias      NVARCHAR(100) NULL,
    Name       NVARCHAR(255) NULL,
    Age        NVARCHAR(10)  NULL,
    CreatedAt  NVARCHAR(50)  NULL,
    DeletedAt  NVARCHAR(50)  NULL,
    isAdmin    NVARCHAR(10)  NULL
);

CREATE TABLE #Behaviors_Staging
(
    BehaviorName NVARCHAR(255) NULL,
    Description  NVARCHAR(MAX) NULL
);

CREATE TABLE #Entities_Staging
(
    EntityID    NVARCHAR(20)  NULL,
    Name        NVARCHAR(255) NULL,
    Behaviors   NVARCHAR(MAX) NULL,
    ScaryLevel  NVARCHAR(10)  NULL
);

CREATE TABLE #Sightings_Staging
(
    SightingID       NVARCHAR(20)  NULL,
    EntityID         NVARCHAR(20)  NULL,
    TimeObserved     NVARCHAR(50)  NULL,
    City             NVARCHAR(255) NULL,
    State            NVARCHAR(50)  NULL,
    CredibilityScore NVARCHAR(10)  NULL
);

CREATE TABLE #UserSightings_Staging
(
    SightingID NVARCHAR(20) NULL,
    UserID     NVARCHAR(20) NULL
);

CREATE TABLE #SightingBehaviors_Staging
(
    SightingID   NVARCHAR(20)  NULL,
    BehaviorName NVARCHAR(255) NULL
);
GO


PRINT '--- Bulk inserting into temp staging tables ---';
------------------------------------------------------------

-- 1. Cities
BULK INSERT #Cities_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\CITIES_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK, CODEPAGE='65001');

-- 2. Users
BULK INSERT #Users_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\USERS_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK, CODEPAGE='65001');

-- 3. Behaviors
BULK INSERT #Behaviors_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\BEHAVIORS_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK, CODEPAGE='65001');

-- 4. Entities
BULK INSERT #Entities_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\ENTITIES_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK, CODEPAGE='65001');

-- 5. Sightings
BULK INSERT #Sightings_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\SIGHTINGS_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK, CODEPAGE='65001');

-- 6. UserSightings
BULK INSERT #UserSightings_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\USERSIGHTINGS_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK, CODEPAGE='65001');

-- 7. SightingBehaviors
BULK INSERT #SightingBehaviors_Staging
FROM 'C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\SIGHTINGBEHAVIORS_MOCK.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK, CODEPAGE='65001');
GO


PRINT '--- Moving cleaned data from temporary staging into real tables ---';
------------------------------------------------------------

-- 1. Cities
INSERT INTO dbo.Cities (City, State, Region)
SELECT City, State, MIN(LTRIM(RTRIM(Region)))
FROM #Cities_Staging
WHERE City IS NOT NULL AND State IS NOT NULL
GROUP BY City, State;
GO

-- 2. Users
SET IDENTITY_INSERT dbo.Users ON;

INSERT INTO dbo.Users (UserID, Email, Alias, Name, Age, CreatedAt, DeletedAt, isAdmin)
SELECT DISTINCT
    CAST(UserID AS INT),
    Email,
    Alias,
    Name,
    TRY_CAST(Age AS SMALLINT),
    COALESCE(
        TRY_CONVERT(DATETIME, CreatedAt, 101),
        TRY_CONVERT(DATETIME, CreatedAt, 0)
    ),
    CASE WHEN NULLIF(LTRIM(RTRIM(DeletedAt)), '') IS NULL
         THEN NULL
         ELSE TRY_CONVERT(DATETIME, DeletedAt, 0)
    END,
    CASE UPPER(LTRIM(RTRIM(isAdmin)))
         WHEN 'TRUE'  THEN 1
         WHEN 'FALSE' THEN 0
         ELSE 0 END
FROM #Users_Staging
WHERE UserID IS NOT NULL
  AND TRY_CAST(UserID AS INT) IS NOT NULL
  AND Email IS NOT NULL;

SET IDENTITY_INSERT dbo.Users OFF;
GO

-- 3. Behaviors
INSERT INTO dbo.Behaviors (BehaviorName, Description)
SELECT LTRIM(RTRIM(BehaviorName)), Description
FROM #Behaviors_Staging
WHERE BehaviorName IS NOT NULL
GROUP BY LTRIM(RTRIM(BehaviorName)), Description;
GO

-- 4. Entities
SET IDENTITY_INSERT dbo.Entities ON;

INSERT INTO dbo.Entities (EntityID, Name, Behaviors, ScaryLevel)
SELECT DISTINCT
    CAST(EntityID AS INT),
    Name,
    Behaviors,
    TRY_CAST(ScaryLevel AS SMALLINT)
FROM #Entities_Staging
WHERE EntityID IS NOT NULL
  AND TRY_CAST(EntityID AS INT) IS NOT NULL
  AND TRY_CAST(ScaryLevel AS SMALLINT) BETWEEN 1 AND 10;

SET IDENTITY_INSERT dbo.Entities OFF;
GO

-- 5. Sightings
SET IDENTITY_INSERT dbo.Sightings ON;

INSERT INTO dbo.Sightings (SightingID, EntityID, TimeObserved, City, State, CredibilityScore)
SELECT DISTINCT
    CAST(SightingID AS INT),
    CAST(EntityID AS INT),
    COALESCE(
        TRY_CONVERT(DATETIME, TimeObserved, 101),
        TRY_CONVERT(DATETIME, TimeObserved, 0)
    ),
    City,
    State,
    TRY_CAST(CredibilityScore AS SMALLINT)
FROM #Sightings_Staging s
WHERE
    TRY_CAST(SightingID AS INT) IS NOT NULL
    AND TRY_CAST(EntityID AS INT) IS NOT NULL
    AND TRY_CAST(CredibilityScore AS SMALLINT) BETWEEN 1 AND 10
    AND EXISTS (SELECT 1 FROM dbo.Entities e WHERE e.EntityID = CAST(s.EntityID AS INT))
    AND EXISTS (SELECT 1 FROM dbo.Cities c WHERE c.City = s.City AND c.State = s.State);

SET IDENTITY_INSERT dbo.Sightings OFF;
GO

-- 6. UserSightings
INSERT INTO dbo.UserSightings (SightingID, UserID)
SELECT DISTINCT
    CAST(SightingID AS INT),
    CAST(UserID AS INT)
FROM #UserSightings_Staging us
WHERE
    TRY_CAST(SightingID AS INT) IS NOT NULL
    AND TRY_CAST(UserID AS INT)    IS NOT NULL
    AND EXISTS (SELECT 1 FROM dbo.Sightings s WHERE s.SightingID = CAST(us.SightingID AS INT))
    AND EXISTS (SELECT 1 FROM dbo.Users     u WHERE u.UserID     = CAST(us.UserID     AS INT));
GO

-- 7. SightingBehaviors
INSERT INTO dbo.SightingBehaviors (SightingID, BehaviorName)
SELECT DISTINCT
    CAST(SightingID AS INT),
    LTRIM(RTRIM(BehaviorName))
FROM #SightingBehaviors_Staging sb
WHERE
    TRY_CAST(SightingID AS INT) IS NOT NULL
    AND EXISTS (SELECT 1 FROM dbo.Sightings  s WHERE s.SightingID  = CAST(sb.SightingID AS INT))
    AND EXISTS (SELECT 1 FROM dbo.Behaviors b WHERE b.BehaviorName = LTRIM(RTRIM(sb.BehaviorName)));
GO

PRINT '--- Data load completed successfully (cleaned + deduped) ---';
