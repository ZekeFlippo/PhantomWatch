using Microsoft.Data.SqlClient;
using System.Data;
using PhantomWatchUI.Models;

namespace PhantomWatchUI.DataDelegates
{
    public class UsersDelegate
    {
        private readonly string _connectionString;

        public UsersDelegate(IConfiguration config)
        {
            _connectionString = config.GetConnectionString("PhantomWatchDB");
        }

        public async Task<IEnumerable<User>> GetUsersAsync()
        {
            var results = new List<User>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            using (SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.Users WHERE DeletedAt IS NULL", conn))
            {
                await conn.OpenAsync();

                using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        results.Add(new User
                        {
                            UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                            Email = reader.GetString(reader.GetOrdinal("Email")),
                            Alias = reader.GetString(reader.GetOrdinal("Alias")),
                            Name = reader.GetString(reader.GetOrdinal("Name")),
                            Age = reader.GetInt16(reader.GetOrdinal("Age")),
                            CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                            DeletedAt = reader.IsDBNull(reader.GetOrdinal("DeletedAt")) ? null : reader.GetDateTime(reader.GetOrdinal("DeletedAt")),
                            isAdmin = reader.GetBoolean(reader.GetOrdinal("isAdmin"))
                        });
                    }
                }
            }

            return results;
        }

        public async Task<User?> GetUserByIdAsync(int id)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.Users WHERE UserID = @id", conn);
            cmd.Parameters.AddWithValue("@id", id);

            await conn.OpenAsync();

            using SqlDataReader reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new User
                {
                    UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                    Email = reader.GetString(reader.GetOrdinal("Email")),
                    Alias = reader.GetString(reader.GetOrdinal("Alias")),
                    Name = reader.GetString(reader.GetOrdinal("Name")),
                    Age = reader.GetInt16(reader.GetOrdinal("Age")),
                    CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                    DeletedAt = reader.IsDBNull(reader.GetOrdinal("DeletedAt")) ? null : reader.GetDateTime(reader.GetOrdinal("DeletedAt")),
                    isAdmin = reader.GetBoolean(reader.GetOrdinal("isAdmin"))
                };
            }

            return null;
        }

        public async Task InsertUserAsync(User u)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd =
                new SqlCommand(@"INSERT INTO dbo.Users (Email, Alias, Name, Age, CreatedAt, isAdmin)
                                 VALUES (@Email, @Alias, @Name, @Age, SYSDATETIME(), @isAdmin)", conn);

            cmd.Parameters.AddWithValue("@Email", u.Email);
            cmd.Parameters.AddWithValue("@Alias", u.Alias);
            cmd.Parameters.AddWithValue("@Name", u.Name);
            cmd.Parameters.AddWithValue("@Age", u.Age);
            cmd.Parameters.AddWithValue("@isAdmin", u.isAdmin);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }

        public async Task UpdateUserAsync(User u)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd =
                new SqlCommand(@"UPDATE dbo.Users
                                 SET Email = @Email, Alias = @Alias, Name = @Name, Age = @Age, isAdmin = @isAdmin
                                 WHERE UserID = @UserID", conn);

            cmd.Parameters.AddWithValue("@UserID", u.UserID);
            cmd.Parameters.AddWithValue("@Email", u.Email);
            cmd.Parameters.AddWithValue("@Alias", u.Alias);
            cmd.Parameters.AddWithValue("@Name", u.Name);
            cmd.Parameters.AddWithValue("@Age", u.Age);
            cmd.Parameters.AddWithValue("@isAdmin", u.isAdmin);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }

        // SOFT DELETE
        public async Task SoftDeleteUserAsync(int id)
        {
            using SqlConnection conn = new SqlConnection(_connectionString);
            using SqlCommand cmd =
                new SqlCommand("UPDATE dbo.Users SET DeletedAt = SYSDATETIME() WHERE UserID = @id", conn);

            cmd.Parameters.AddWithValue("@id", id);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }
    }
}
