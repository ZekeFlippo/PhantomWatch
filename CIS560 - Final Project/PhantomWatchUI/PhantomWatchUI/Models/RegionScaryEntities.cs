namespace PhantomWatchUI.Models
{
    public class RegionScaryEntities
    {
        public string Region { get; set; } = string.Empty;
        public int HighScaryEntityCount { get; set; }
        public double AvgScaryLevel { get; set; }
        public short MaxScaryLevel { get; set; }
    }
}
