-- Procedures.sql - CIS560 - Group09

USE PhantomWatchDB;
GO

/******************************************************************************************
    1. Top Regions by Total Credibility Score
    Purpose:
      Returns regions grouped by total/avg credibility score within a date range.
******************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.TopRegionsByCredibility
    @StartDate DATETIME,
    @EndDate   DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.Region,
        SUM(s.CredibilityScore) AS TotalCredibilityScore,
        CAST(AVG(CAST(s.CredibilityScore AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS AverageCredibilityScore,
        COUNT(*) AS SightingCount
    FROM dbo.Sightings s
    INNER JOIN dbo.Cities c
        ON s.City = c.City AND s.State = c.State
    WHERE s.TimeObserved BETWEEN @StartDate AND @EndDate
    GROUP BY c.Region
    ORDER BY TotalCredibilityScore DESC;
END;
GO

/******************************************************************************************
    2. Regions with Entities Above a Given ScaryLevel
    Purpose:
      Lists regions that contain sightings of high-scariness entities.
******************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.RegionsWithHighScaryEntities
    @MinScaryLevel SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.Region,
        COUNT(DISTINCT e.EntityID) AS HighScaryEntityCount,
        CAST(AVG(CAST(e.ScaryLevel AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS AvgScaryLevel,
        MAX(e.ScaryLevel) AS MaxScaryLevel
    FROM dbo.Sightings s
    INNER JOIN dbo.Entities e
        ON s.EntityID = e.EntityID
    INNER JOIN dbo.Cities c
        ON s.City = c.City AND s.State = c.State
    WHERE e.ScaryLevel > @MinScaryLevel
    GROUP BY c.Region
    ORDER BY MaxScaryLevel DESC, HighScaryEntityCount DESC;
END;
GO

/******************************************************************************************
    3. Average Credibility Score by Reporter
    Purpose:
      Computes credibility score averages by user and filters by minimum number of reports.
******************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.AverageCredibilityByReporter
    @MinReports INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.UserID,
        u.Alias,
        CAST(AVG(CAST(s.CredibilityScore AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS AvgCredibilityScore,
        COUNT(*) AS ReportCount
    FROM dbo.UserSightings us
    INNER JOIN dbo.Users u
        ON u.UserID = us.UserID
    INNER JOIN dbo.Sightings s
        ON s.SightingID = us.SightingID
    GROUP BY u.UserID, u.Alias
    HAVING COUNT(*) >= @MinReports
    ORDER BY AvgCredibilityScore DESC;
END;
GO

/******************************************************************************************
    4. Repeat vs Single-Time Reporters
    Purpose:
      Categorizes reporters into 'S' (single) and 'R' (repeat) within a date window.
******************************************************************************************/
CREATE OR ALTER PROCEDURE dbo.RepeatVsSingleReporters
    @StartDate DATETIME,
    @EndDate   DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH SightingCounts AS
    (
        SELECT
            u.UserID,
            u.Alias,
            COUNT(s.SightingID) AS ReportCount
        FROM dbo.Users u
        LEFT JOIN dbo.UserSightings us
            ON u.UserID = us.UserID
        LEFT JOIN dbo.Sightings s
            ON s.SightingID = us.SightingID
           AND s.TimeObserved BETWEEN @StartDate AND @EndDate
        GROUP BY u.UserID, u.Alias
    )
    SELECT
        CASE 
            WHEN ReportCount = 1 THEN 'S'
            WHEN ReportCount > 1 THEN 'R'
        END AS ReporterCategory,
        COUNT(*) AS UserCount
    FROM SightingCounts
    WHERE ReportCount > 0
    GROUP BY 
        CASE 
            WHEN ReportCount = 1 THEN 'S'
            WHEN ReportCount > 1 THEN 'R'
        END;
END;
GO
