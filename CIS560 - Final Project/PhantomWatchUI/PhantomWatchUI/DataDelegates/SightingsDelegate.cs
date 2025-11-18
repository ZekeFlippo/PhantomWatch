using Microsoft.Data.SqlClient;
using System.Data;
using PhantomWatchUI.Models;

namespace PhantomWatchUI.DataDelegates
{
    public class SightingsDelegate
    {
        private readonly string _connectionString;

        public SightingsDelegate(IConfiguration config)
        {
            _connectionString = config.GetConnectionString("PhantomWatchDB");
        }

        public async Task<IEnumerable<Sighting>> GetSightingsAsync()
        {
            var results = new List<Sighting>();

            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.Sightings", conn);

            await conn.OpenAsync();

            using SqlDataReader reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                results.Add(new Sighting
                {
                    SightingID = reader.GetInt32(reader.GetOrdinal("SightingID")),
                    EntityID = reader.GetInt32(reader.GetOrdinal("EntityID")),
                    TimeObserved = reader.GetDateTime(reader.GetOrdinal("TimeObserved")),
                    CityName = reader.GetString(reader.GetOrdinal("City")),
                    State = reader.GetString(reader.GetOrdinal("State")),

                    // UPDATED: DB column is now INT, not smallint
                    CredibilityScore = reader.GetInt32(reader.GetOrdinal("CredibilityScore"))
                });
            }

            return results;
        }

        public async Task InsertSightingAsync(Sighting s)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd =
                new SqlCommand(@"INSERT INTO dbo.Sightings 
                                 (EntityID, TimeObserved, City, State, CredibilityScore)
                                 VALUES (@EntityID, @TimeObserved, @City, @State, @CredibilityScore)", conn);

            cmd.Parameters.AddWithValue("@EntityID", s.EntityID);
            cmd.Parameters.AddWithValue("@TimeObserved", s.TimeObserved);
            cmd.Parameters.AddWithValue("@City", s.CityName);
            cmd.Parameters.AddWithValue("@State", s.State);
            cmd.Parameters.AddWithValue("@CredibilityScore", s.CredibilityScore);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }

        public async Task UpdateSightingAsync(Sighting s)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd =
                new SqlCommand(@"UPDATE dbo.Sightings
                                 SET EntityID = @EntityID, TimeObserved = @TimeObserved,
                                     City = @City, State = @State, CredibilityScore = @CredibilityScore
                                 WHERE SightingID = @SightingID", conn);

            cmd.Parameters.AddWithValue("@SightingID", s.SightingID);
            cmd.Parameters.AddWithValue("@EntityID", s.EntityID);
            cmd.Parameters.AddWithValue("@TimeObserved", s.TimeObserved);
            cmd.Parameters.AddWithValue("@City", s.CityName);
            cmd.Parameters.AddWithValue("@State", s.State);
            cmd.Parameters.AddWithValue("@CredibilityScore", s.CredibilityScore);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }

        // UPDATED: no more 1–10 clamping
        public async Task UpvoteAsync(int sightingId)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd = new SqlCommand(
                @"UPDATE dbo.Sightings
                  SET CredibilityScore = CredibilityScore + 1
                  WHERE SightingID = @id", conn);

            cmd.Parameters.AddWithValue("@id", sightingId);
            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }

        // UPDATED: no lower bound of 1
        public async Task DownvoteAsync(int sightingId)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd = new SqlCommand(
                @"UPDATE dbo.Sightings
                  SET CredibilityScore = CredibilityScore - 1
                  WHERE SightingID = @id", conn);

            cmd.Parameters.AddWithValue("@id", sightingId);
            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }
    }
}
