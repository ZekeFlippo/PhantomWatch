USE PhantomWatchDB;
GO

/******************************************************************************************
    1. Top Regions by Total Credibility Score
    Rubric:
      - Parameters: StartDate (datetime), EndDate (datetime)
      - Result: Region, TotalCredibilityScore, AverageCredibilityScore, SightingCount
      - Logic: Sightings grouped by Region, filtered by TimeObserved in date range
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
    Rubric:
      - Parameter: MinScaryLevel (smallint)
      - Result: Region, HighScaryEntityCount, AvgScaryLevel, MaxScaryLevel
      - Logic: Sightings → Entities → Cities, filter ScaryLevel > MinScaryLevel, group by Region
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
    3. Average Credibility Score by Reporter (User)
    Rubric:
      - Parameter: MinReports (int)
      - Result: UserID, Alias, AvgCredibilityScore, ReportCount
      - Logic: UserSightings → Sightings → Users, average per reporter, filter by MinReports
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
    Rubric:
      - Parameters: StartDate (datetime), EndDate (datetime)
      - Result: ReporterCategory (R vs S), UserCount
      - Logic: Count reports per user in date window, then bucket into:
               'S' = Single-time reporter (exactly 1 sighting in range)
               'R' = Repeat reporter (more than 1 sighting in range)
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
            WHEN ReportCount = 1 THEN 'S'     -- Single-time reporter
            WHEN ReportCount > 1 THEN 'R'     -- Repeat reporter
        END AS ReporterCategory,
        COUNT(*) AS UserCount
    FROM SightingCounts
    WHERE ReportCount > 0          -- only actual reporters
    GROUP BY 
        CASE 
            WHEN ReportCount = 1 THEN 'S'
            WHEN ReportCount > 1 THEN 'R'
        END;
END;
GO
