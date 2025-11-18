using Microsoft.Data.SqlClient;
using System.Data;
using PhantomWatchUI.Models;

namespace PhantomWatchUI.DataDelegates
{
    public class UserSightingsDelegate
    {
        private readonly string _connectionString;

        public UserSightingsDelegate(IConfiguration config)
        {
            _connectionString = config.GetConnectionString("PhantomWatchDB");
        }

        public async Task<IEnumerable<UserSighting>> GetUserSightingsAsync()
        {   
            var results = new List<UserSighting>();

            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.UserSightings", conn);

            await conn.OpenAsync();

            using SqlDataReader reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                results.Add(new UserSighting
                {
                    SightingID = reader.GetInt32(reader.GetOrdinal("SightingID")),
                    UserID = reader.GetInt32(reader.GetOrdinal("UserID"))
                });
            }

            return results;
        }

        public async Task InsertUserSightingAsync(int sightingId, int userId)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd =
                new SqlCommand(@"INSERT INTO dbo.UserSightings (SightingID, UserID)
                                 VALUES (@SightingID, @UserID)", conn);

            cmd.Parameters.AddWithValue("@SightingID", sightingId);
            cmd.Parameters.AddWithValue("@UserID", userId);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }

        public async Task DeleteUserSightingAsync(int sightingId, int userId)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd =
                new SqlCommand(@"DELETE FROM dbo.UserSightings
                                 WHERE SightingID = @SightingID AND UserID = @UserID", conn);

            cmd.Parameters.AddWithValue("@SightingID", sightingId);
            cmd.Parameters.AddWithValue("@UserID", userId);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }
    }
}
