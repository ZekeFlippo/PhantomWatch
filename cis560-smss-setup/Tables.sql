-- Tables.sql - CIS560 Group 09


IF DB_ID('PhantomWatchDB') IS NULL
BEGIN
    CREATE DATABASE PhantomWatchDB;
END
GO

USE PhantomWatchDB;
GO

-- Drop Tables in FK-Safe Order (Development Only)

IF OBJECT_ID('dbo.UserVotes') IS NOT NULL DROP TABLE dbo.UserVotes;
IF OBJECT_ID('dbo.SightingBehaviors') IS NOT NULL DROP TABLE dbo.SightingBehaviors;
IF OBJECT_ID('dbo.UserSightings') IS NOT NULL DROP TABLE dbo.UserSightings;
IF OBJECT_ID('dbo.Sightings') IS NOT NULL DROP TABLE dbo.Sightings;
IF OBJECT_ID('dbo.Entities') IS NOT NULL DROP TABLE dbo.Entities;
IF OBJECT_ID('dbo.Behaviors') IS NOT NULL DROP TABLE dbo.Behaviors;
IF OBJECT_ID('dbo.Cities') IS NOT NULL DROP TABLE dbo.Cities;
IF OBJECT_ID('dbo.Users') IS NOT NULL DROP TABLE dbo.Users;
GO

-- Users Table
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

-- Cities Table
CREATE TABLE dbo.Cities
(
    City   NVARCHAR(255) NOT NULL,
    State  NVARCHAR(50) NOT NULL,
    Region NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Cities PRIMARY KEY (City, State)
);
GO

-- Behaviors Table
CREATE TABLE dbo.Behaviors
(
    BehaviorName NVARCHAR(255) NOT NULL PRIMARY KEY,
    Description  NVARCHAR(MAX) NULL
);
GO

-- Entities Table
CREATE TABLE dbo.Entities
(
    EntityID     INT IDENTITY(1,1) PRIMARY KEY,
    Name         NVARCHAR(255) NOT NULL UNIQUE,
    Behaviors    NVARCHAR(MAX) NULL,
    ScaryLevel   SMALLINT NOT NULL CHECK (ScaryLevel BETWEEN 1 AND 10)
);
GO

-- Sightings Table
CREATE TABLE dbo.Sightings
(
    SightingID       INT IDENTITY(1,1) PRIMARY KEY,
    EntityID         INT NOT NULL,
    TimeObserved     DATETIME NOT NULL,
    City             NVARCHAR(255) NOT NULL,
    State            NVARCHAR(50) NOT NULL,
    CredibilityScore INT NOT NULL,

    CONSTRAINT FK_Sightings_Entities FOREIGN KEY (EntityID)
        REFERENCES dbo.Entities(EntityID),

    CONSTRAINT FK_Sightings_Cities FOREIGN KEY (City, State)
        REFERENCES dbo.Cities(City, State)
);
GO

-- UserSightings Table
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

-- SightingBehaviors Table
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

-- UserVotes Table
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
