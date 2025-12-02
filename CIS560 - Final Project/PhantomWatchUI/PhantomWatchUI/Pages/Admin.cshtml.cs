using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using PhantomWatchUI.DataDelegates;
using PhantomWatchUI.Models;

namespace PhantomWatchUI.Pages
{
    public class AdminModel : PageModel
    {

        private readonly UsersDelegate _users;
        private readonly SightingsDelegate _sightings;
        private readonly EntitiesDelegate _entities;
        private readonly UserSightingsDelegate _userSightings;

        public AdminModel(
            UsersDelegate users,
            SightingsDelegate sightings,
            EntitiesDelegate entities,
            UserSightingsDelegate userSightings)
        {
            _users = users;
            _sightings = sightings;
            _entities = entities;
            _userSightings = userSightings;
        }

        public int TotalUsers { get; set; }
        public List<User> RepeatReporters { get; set; } = new();
        public List<User> OneTimeReporters { get; set; } = new();
        public List<ReporterStat> ReporterStats { get; set; } = new();
        public List<SightingDisplay> SortedSightings { get; set; } = new();
        public List<LocationScore> TopLocations { get; set; } = new();
        public List<SightingDisplay> FilteredByScary { get; set; } = new();



        [BindProperty(SupportsGet = true)]
        public string SortBy { get; set; } = "Reporter";

        [BindProperty(SupportsGet = true)]
        public int MinScaryLevel { get; set; } = 1;



        public async Task OnGetAsync()
        {
            var users = (await _users.GetUsersAsync()).ToList();
            var sightings = (await _sightings.GetSightingsAsync()).ToList();
            var entities = (await _entities.GetEntitiesAsync()).ToList();
            var userSightings = (await _userSightings.GetUserSightingsAsync()).ToList();

            
            TotalUsers = users.Count;

            
            var reportCounts =
                userSightings
                .GroupBy(x => x.UserID)
                .ToDictionary(g => g.Key, g => g.Count());

            
            RepeatReporters = users.Where(u => reportCounts.ContainsKey(u.UserID) && reportCounts[u.UserID] > 1).ToList();
            OneTimeReporters = users.Where(u => reportCounts.ContainsKey(u.UserID) && reportCounts[u.UserID] == 1).ToList();

            
            ReporterStats =
                users.Select(u => new ReporterStat
                {
                    FullName = u.Name,
                    ReportCount = reportCounts.ContainsKey(u.UserID) ? reportCounts[u.UserID] : 0,
                    AvgCredibility = sightings
                        .Where(s => userSightings.Any(us => us.UserID == u.UserID && us.SightingID == s.SightingID))
                        .Select(s => s.CredibilityScore)
                        .DefaultIfEmpty(0)
                        .Average()
                }).ToList();

            
            var display = sightings.Select(s => new SightingDisplay
            {
                SightingID = s.SightingID,
                EntityName = entities.First(e => e.EntityID == s.EntityID).Name,
                ScaryLevel = entities.First(e => e.EntityID == s.EntityID).ScaryLevel,
                City = s.CityName,
                State = s.State,
                Credibility = s.CredibilityScore,
                FullName = users.First(u => userSightings.Any(us => us.SightingID == s.SightingID && us.UserID == u.UserID)).Name
            }).ToList();

            
            SortedSightings = SortBy switch
            {
                "Location" => display.OrderBy(d => d.City).ToList(),
                "Entity" => display.OrderBy(d => d.EntityName).ToList(),
                "ScaryLevel" => display.OrderByDescending(d => d.ScaryLevel).ToList(),
                "Credibility" => display.OrderByDescending(d => d.Credibility).ToList(),
                _ => display.OrderBy(d => d.FullName).ToList(),
            };

            
            TopLocations =
                display.GroupBy(d => $"{d.City}, {d.State}")
                       .Select(g => new LocationScore
                       {
                           Location = g.Key,
                           Score = (int)g.Sum(x => x.Credibility * x.ScaryLevel)
                       })
                       .OrderByDescending(x => x.Score)
                       .Take(10)
                       .ToList();

            
            FilteredByScary =
                display.Where(s => s.ScaryLevel >= MinScaryLevel)
                       .ToList();
        }

        public class ReporterStat
        {
            public string FullName { get; set; }
            public int ReportCount { get; set; }
            public double AvgCredibility { get; set; }
        }

        public class SightingDisplay
        {
            public int SightingID { get; set; }
            public string FullName { get; set; }
            public string EntityName { get; set; }
            public int ScaryLevel { get; set; }
            public string City { get; set; }
            public string State { get; set; }
            public int Credibility { get; set; }
        }

        public class LocationScore
        {
            public string Location { get; set; }
            public int Score { get; set; }
        }

    }
}