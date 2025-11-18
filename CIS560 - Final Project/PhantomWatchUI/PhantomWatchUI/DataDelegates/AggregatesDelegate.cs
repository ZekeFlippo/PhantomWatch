using Microsoft.Data.SqlClient;
using PhantomWatchUI.Models;
using System.Data;

public class AggregatesDelegate
{
    private readonly string _connectionString;

    public AggregatesDelegate(IConfiguration config)
    {
        _connectionString = config.GetConnectionString("PhantomWatchDB");

        if (string.IsNullOrWhiteSpace(_connectionString))
        {
            throw new InvalidOperationException(
                "ERROR: Missing connection string 'PhantomWatchDB' in appsettings.json.");
        }
    }

    /***********************************************
     * 1. Top Regions by Credibility
     *    RETURNS: Region, TotalCredibilityScore, AverageCredibilityScore, SightingCount
     ***********************************************/
    public async Task<IEnumerable<RegionCredibility>> GetTopRegionsByCredibilityAsync(
        DateTime startDate, DateTime endDate)
    {
        var list = new List<RegionCredibility>();

        using var conn = new SqlConnection(_connectionString);
        using var cmd = new SqlCommand("dbo.TopRegionsByCredibility", conn)
        {
            CommandType = CommandType.StoredProcedure
        };

        cmd.Parameters.AddWithValue("@StartDate", startDate);
        cmd.Parameters.AddWithValue("@EndDate", endDate);

        await conn.OpenAsync();
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            list.Add(new RegionCredibility
            {
                Region = reader.GetString(0),
                TotalCredibilityScore = reader.GetInt32(1),

                // SQL returns DECIMAL(10,2). Use double.
                AverageCredibilityScore = Convert.ToDouble(reader.GetValue(2)),

                SightingCount = reader.GetInt32(3)
            });
        }

        return list;
    }



    /***********************************************
     * 2. Regions With High Scary Entities
     *    RETURNS: Region, HighScaryEntityCount, AvgScaryLevel, MaxScaryLevel
     ***********************************************/
    public async Task<IEnumerable<RegionScaryEntities>> GetRegionsWithHighScaryEntitiesAsync(short minLevel)
    {
        var list = new List<RegionScaryEntities>();

        using var conn = new SqlConnection(_connectionString);
        using var cmd = new SqlCommand("dbo.RegionsWithHighScaryEntities", conn)
        {
            CommandType = CommandType.StoredProcedure
        };

        cmd.Parameters.AddWithValue("@MinScaryLevel", minLevel);

        await conn.OpenAsync();
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            list.Add(new RegionScaryEntities
            {
                Region = reader.GetString(0),
                HighScaryEntityCount = reader.GetInt32(1),
                AvgScaryLevel = Convert.ToDouble(reader.GetValue(2)),
                MaxScaryLevel = reader.GetInt16(3)
            });
        }

        return list;
    }



    /***********************************************
     * 3. Average Credibility by Reporter
     *    RETURNS: UserID, Alias, AvgCredibilityScore, ReportCount
     ***********************************************/
    public async Task<IEnumerable<UserCredibilityStats>> GetAverageCredibilityByReporterAsync(int minReports)
    {
        var list = new List<UserCredibilityStats>();

        using var conn = new SqlConnection(_connectionString);
        using var cmd = new SqlCommand("dbo.AverageCredibilityByReporter", conn)
        {
            CommandType = CommandType.StoredProcedure
        };

        cmd.Parameters.AddWithValue("@MinReports", minReports);

        await conn.OpenAsync();
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            list.Add(new UserCredibilityStats
            {
                UserID = reader.GetInt32(0),
                Alias = reader.GetString(1),
                AvgCredibilityScore = Convert.ToDouble(reader.GetValue(2)),
                ReportCount = reader.GetInt32(3)
            });
        }

        return list;
    }



    /***********************************************
     * 4. Repeat vs Single Reporters
     *    RETURNS: ReporterCategory, UserCount
     ***********************************************/
    public async Task<IEnumerable<ReporterSummary>> GetRepeatVsSingleReportersAsync(
        DateTime startDate, DateTime endDate)
    {
        var list = new List<ReporterSummary>();

        using var conn = new SqlConnection(_connectionString);
        using var cmd = new SqlCommand("dbo.RepeatVsSingleReporters", conn)
        {
            CommandType = CommandType.StoredProcedure
        };

        cmd.Parameters.AddWithValue("@StartDate", startDate);
        cmd.Parameters.AddWithValue("@EndDate", endDate);

        await conn.OpenAsync();
        using var reader = await cmd.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            list.Add(new ReporterSummary
            {
                ReporterCategory = reader.GetString(0),
                UserCount = reader.GetInt32(1)
            });
        }

        return list;
    }
}
