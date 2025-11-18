namespace PhantomWatchUI.Models
{
    public class Sighting
    {
        public int SightingID { get; set; }
        public int EntityID { get; set; }
        public DateTime TimeObserved { get; set; }

        public string CityName { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;

        public int CredibilityScore { get; set; }
    }
}
