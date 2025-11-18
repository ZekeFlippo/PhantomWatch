namespace PhantomWatchUI.Models
{
    public class UserCredibilityStats
    {
        public int UserID { get; set; }
        public string Alias { get; set; } = string.Empty;
        public double AvgCredibilityScore { get; set; }
        public int ReportCount { get; set; }
    }
}
