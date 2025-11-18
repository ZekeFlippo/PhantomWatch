namespace PhantomWatchUI.Models
{
    public class Entity
    {
        public int EntityID { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Behaviors { get; set; } = string.Empty;
        public short ScaryLevel { get; set; }
    }
}
