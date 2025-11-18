namespace PhantomWatchUI.Models
{
    public class RegionCredibility
    {
        public string Region { get; set; } = string.Empty;
        public int TotalCredibilityScore { get; set; }
        public double AverageCredibilityScore { get; set; }
        public int SightingCount { get; set; }
    }
}
