using Microsoft.Data.SqlClient;
using System.Data;
using PhantomWatchUI.Models;

namespace PhantomWatchUI.DataDelegates
{
    public class SightingBehaviorsDelegate
    {
        private readonly string _connectionString;

        public SightingBehaviorsDelegate(IConfiguration config)
        {
            _connectionString = config.GetConnectionString("PhantomWatchDB");
        }

        public async Task<IEnumerable<SightingBehavior>> GetSightingBehaviorsAsync()
        {
            var results = new List<SightingBehavior>();

            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.SightingBehaviors", conn);

            await conn.OpenAsync();

            using SqlDataReader reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                results.Add(new SightingBehavior
                {
                    SightingID = reader.GetInt32(reader.GetOrdinal("SightingID")),
                    BehaviorName = reader.GetString(reader.GetOrdinal("BehaviorName"))
                });
            }

            return results;
        }

        public async Task InsertSightingBehaviorAsync(int sightingId, string behaviorName)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd =
                new SqlCommand(@"INSERT INTO dbo.SightingBehaviors (SightingID, BehaviorName)
                                 VALUES (@SightingID, @BehaviorName)", conn);

            cmd.Parameters.AddWithValue("@SightingID", sightingId);
            cmd.Parameters.AddWithValue("@BehaviorName", behaviorName);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }

        public async Task DeleteSightingBehaviorAsync(int sightingId, string behaviorName)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd =
                new SqlCommand(@"DELETE FROM dbo.SightingBehaviors
                                 WHERE SightingID = @SightingID AND BehaviorName = @BehaviorName", conn);

            cmd.Parameters.AddWithValue("@SightingID", sightingId);
            cmd.Parameters.AddWithValue("@BehaviorName", behaviorName);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }
    }
}
