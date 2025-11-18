using Microsoft.Data.SqlClient;
using System.Data;
using PhantomWatchUI.Models;

namespace PhantomWatchUI.DataDelegates
{
    public class BehaviorsDelegate
    {
        private readonly string _connectionString;

        public BehaviorsDelegate(IConfiguration config)
        {
            _connectionString = config.GetConnectionString("PhantomWatchDB");
        }

        public async Task<IEnumerable<Behavior>> GetBehaviorsAsync()
        {
            var results = new List<Behavior>();

            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.Behaviors", conn);

            await conn.OpenAsync();

            using SqlDataReader reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                results.Add(new Behavior
                {
                    BehaviorName = reader.GetString(reader.GetOrdinal("BehaviorName")),
                    Description = reader.GetString(reader.GetOrdinal("Description"))
                });
            }

            return results;
        }

        public async Task InsertBehaviorAsync(Behavior b)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd =
                new SqlCommand(@"INSERT INTO dbo.Behaviors (BehaviorName, Description)
                                 VALUES (@BehaviorName, @Description)", conn);

            cmd.Parameters.AddWithValue("@BehaviorName", b.BehaviorName);
            cmd.Parameters.AddWithValue("@Description", b.Description);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }

        public async Task DeleteBehaviorAsync(string behaviorName)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd =
                new SqlCommand("DELETE FROM dbo.Behaviors WHERE BehaviorName = @name", conn);

            cmd.Parameters.AddWithValue("@name", behaviorName);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }
    }
}
