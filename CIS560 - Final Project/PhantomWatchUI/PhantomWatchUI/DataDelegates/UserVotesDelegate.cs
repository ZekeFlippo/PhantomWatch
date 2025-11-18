using Microsoft.Data.SqlClient;
using PhantomWatchUI.Models;

namespace PhantomWatchUI.DataDelegates
{
    public class UserVotesDelegate
    {
        private readonly string _connectionString;

        public UserVotesDelegate(IConfiguration config)
        {
            _connectionString = config.GetConnectionString("PhantomWatchDB");
        }

        public async Task<bool> HasUserVotedAsync(int userId, int sightingId)
        {
            using var conn = new SqlConnection(_connectionString);
            using var cmd = new SqlCommand(
                @"SELECT COUNT(*) 
                  FROM dbo.UserVotes 
                  WHERE UserID = @uid AND SightingID = @sid", conn);

            cmd.Parameters.AddWithValue("@uid", userId);
            cmd.Parameters.AddWithValue("@sid", sightingId);

            await conn.OpenAsync();
            return (int)await cmd.ExecuteScalarAsync() > 0;
        }

        public async Task InsertVoteAsync(int userId, int sightingId, char voteType)
        {
            using var conn = new SqlConnection(_connectionString);
            using var cmd = new SqlCommand(
                @"INSERT INTO dbo.UserVotes (UserID, SightingID, VoteType)
                  VALUES (@uid, @sid, @type)", conn);

            cmd.Parameters.AddWithValue("@uid", userId);
            cmd.Parameters.AddWithValue("@sid", sightingId);
            cmd.Parameters.AddWithValue("@type", voteType);

            await conn.OpenAsync();
            await cmd.ExecuteNonQueryAsync();
        }
    }
}
