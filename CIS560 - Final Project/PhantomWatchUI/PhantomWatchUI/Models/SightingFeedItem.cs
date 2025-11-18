namespace PhantomWatchUI.Models
{
    public class SightingFeedItem
    {
        public int SightingID { get; set; }
        public DateTime TimeObserved { get; set; }

        public string City { get; set; } = "";
        public string State { get; set; } = "";

        public string EntityName { get; set; } = "";
        public string PostedByAlias { get; set; } = "";
        public List<string> Behaviors { get; set; } = new();
    }
}
