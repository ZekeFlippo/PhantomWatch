namespace PhantomWatchUI.Models
{
    public class User
    {
        public int UserID { get; set; }
        public string Email { get; set; } = string.Empty;
        public string Alias { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public short Age { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? DeletedAt { get; set; }
        public bool isAdmin { get; set; }
    }
}
