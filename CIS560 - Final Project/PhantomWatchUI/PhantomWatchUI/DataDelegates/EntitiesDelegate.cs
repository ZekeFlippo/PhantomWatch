using Microsoft.Data.SqlClient;
using System.Data;
using PhantomWatchUI.Models;

namespace PhantomWatchUI.DataDelegates
{
    public class EntitiesDelegate
    {
        private readonly string _connectionString;

        public EntitiesDelegate(IConfiguration config)
        {
            _connectionString = config.GetConnectionString("PhantomWatchDB");
        }

        public async Task<IEnumerable<Entity>> GetEntitiesAsync()
        {
            var results = new List<Entity>();

            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.Entities", conn);

            await conn.OpenAsync();

            using SqlDataReader reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                results.Add(new Entity
                {
                    EntityID = reader.GetInt32(reader.GetOrdinal("EntityID")),
                    Name = reader.GetString(reader.GetOrdinal("Name")),
                    Behaviors = reader.GetString(reader.GetOrdinal("Behaviors")),
                    ScaryLevel = reader.GetInt16(reader.GetOrdinal("ScaryLevel"))
                });
            }

            return results;
        }

        public async Task<Entity?> GetEntityByIdAsync(int id)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.Entities WHERE EntityID = @id", conn);
            cmd.Parameters.AddWithValue("@id", id);

            await conn.OpenAsync();

            using SqlDataReader reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new Entity
                {
                    EntityID = reader.GetInt32(reader.GetOrdinal("EntityID")),
                    Name = reader.GetString(reader.GetOrdinal("Name")),
                    Behaviors = reader.GetString(reader.GetOrdinal("Behaviors")),
                    ScaryLevel = reader.GetInt16(reader.GetOrdinal("ScaryLevel"))
                };
            }

            return null;
        }

        public async Task InsertEntityAsync(Entity e)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd =
                new SqlCommand(@"INSERT INTO dbo.Entities (Name, Behaviors, ScaryLevel)
                                 VALUES (@Name, @Behaviors, @ScaryLevel)", conn);

            cmd.Parameters.AddWithValue("@Name", e.Name);
            cmd.Parameters.AddWithValue("@Behaviors", e.Behaviors);
            cmd.Parameters.AddWithValue("@ScaryLevel", e.ScaryLevel);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }

        public async Task UpdateEntityAsync(Entity e)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd =
                new SqlCommand(@"UPDATE dbo.Entities
                                 SET Name = @Name, Behaviors = @Behaviors, ScaryLevel = @ScaryLevel
                                 WHERE EntityID = @EntityID", conn);

            cmd.Parameters.AddWithValue("@EntityID", e.EntityID);
            cmd.Parameters.AddWithValue("@Name", e.Name);
            cmd.Parameters.AddWithValue("@Behaviors", e.Behaviors);
            cmd.Parameters.AddWithValue("@ScaryLevel", e.ScaryLevel);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }

        public async Task DeleteEntityAsync(int id)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd =
                new SqlCommand("DELETE FROM dbo.Entities WHERE EntityID = @id", conn);

            cmd.Parameters.AddWithValue("@id", id);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }
    }
}
