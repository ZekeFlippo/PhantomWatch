using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using PhantomWatchUI.DataDelegates;
using PhantomWatchUI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace PhantomWatchUI.Pages
{
    public class HomeModel : PageModel
    {
        private readonly SightingsDelegate _sightingsDelegate;
        private readonly UsersDelegate _usersDelegate;
        private readonly EntitiesDelegate _entitiesDelegate;
        private readonly CitiesDelegate _citiesDelegate;
        private readonly UserSightingsDelegate _userSightingsDelegate;
        private readonly SightingBehaviorsDelegate _sightingBehaviorsDelegate;
        private readonly BehaviorsDelegate _behaviorsDelegate;
        private readonly UserVotesDelegate _userVotesDelegate;

        public HomeModel(
            SightingsDelegate sightingsDelegate,
            UsersDelegate usersDelegate,
            EntitiesDelegate entitiesDelegate,
            CitiesDelegate citiesDelegate,
            UserSightingsDelegate userSightingsDelegate,
            SightingBehaviorsDelegate sightingBehaviorsDelegate,
            BehaviorsDelegate behaviorsDelegate,
            UserVotesDelegate userVotesDelegate)
        {
            _sightingsDelegate = sightingsDelegate;
            _usersDelegate = usersDelegate;
            _entitiesDelegate = entitiesDelegate;
            _citiesDelegate = citiesDelegate;
            _userSightingsDelegate = userSightingsDelegate;
            _sightingBehaviorsDelegate = sightingBehaviorsDelegate;
            _behaviorsDelegate = behaviorsDelegate;
            _userVotesDelegate = userVotesDelegate;
        }

        [BindProperty(SupportsGet = true)]
        public string? Search { get; set; }

        public List<SightingViewModel> Feed { get; set; } = new();

        // ----------------------------------------------------------
        //  GET FEED
        // ----------------------------------------------------------
        public async Task OnGetAsync()
        {
            var sightings = (await _sightingsDelegate.GetSightingsAsync()).ToList();
            var entities = (await _entitiesDelegate.GetEntitiesAsync()).ToList();
            var users = (await _usersDelegate.GetUsersAsync()).ToList();
            var userSightings = (await _userSightingsDelegate.GetUserSightingsAsync()).ToList();
            var sightingBehaviors = (await _sightingBehaviorsDelegate.GetSightingBehaviorsAsync()).ToList();

            var list = new List<SightingViewModel>();

            foreach (var s in sightings)
            {
                var entity = entities.FirstOrDefault(e => e.EntityID == s.EntityID);

                var us = userSightings.FirstOrDefault(x => x.SightingID == s.SightingID);
                var user = us != null ? users.FirstOrDefault(u => u.UserID == us.UserID) : null;

                var behavs = sightingBehaviors
                    .Where(b => b.SightingID == s.SightingID)
                    .Select(b => b.BehaviorName)
                    .ToList();

                list.Add(new SightingViewModel
                {
                    SightingID = s.SightingID,
                    EntityName = entity?.Name ?? "Unknown Entity",
                    PostedByAlias = user?.Alias ?? "Unknown",
                    CityName = s.CityName,
                    State = s.State,
                    TimeObserved = s.TimeObserved,
                    CredibilityScore = s.CredibilityScore,
                    Behaviors = behavs
                });
            }

            list = list.OrderByDescending(v => v.TimeObserved).ToList();

            if (!string.IsNullOrWhiteSpace(Search))
            {
                var term = Search.Trim();

                list = list.Where(v =>
                    v.EntityName.Contains(term, StringComparison.OrdinalIgnoreCase) ||
                    v.PostedByAlias.Contains(term, StringComparison.OrdinalIgnoreCase) ||
                    v.CityName.Contains(term, StringComparison.OrdinalIgnoreCase) ||
                    v.Behaviors.Any(b => b.Contains(term, StringComparison.OrdinalIgnoreCase))
                )
                .OrderByDescending(v => v.TimeObserved)
                .ToList();
            }

            Feed = list;
        }

        // ----------------------------------------------------------
        //  UPVOTE HANDLER
        // ----------------------------------------------------------
        public async Task<IActionResult> OnPostUpvoteAsync(int sightingId)
        {
            int userId = 1; // TODO: replace with logged-in user

            // prevent double-voting
            if (!await _userVotesDelegate.HasUserVotedAsync(userId, sightingId))
            {
                await _sightingsDelegate.UpvoteAsync(sightingId);
                await _userVotesDelegate.InsertVoteAsync(userId, sightingId, 'U');
            }

            return RedirectToPage();
        }

        // ----------------------------------------------------------
        //  DOWNVOTE HANDLER
        // ----------------------------------------------------------
        public async Task<IActionResult> OnPostDownvoteAsync(int sightingId)
        {
            int userId = 1; // TODO: replace with logged-in user

            if (!await _userVotesDelegate.HasUserVotedAsync(userId, sightingId))
            {
                await _sightingsDelegate.DownvoteAsync(sightingId);
                await _userVotesDelegate.InsertVoteAsync(userId, sightingId, 'D');
            }

            return RedirectToPage();
        }
    }

    public class SightingViewModel
    {
        public int SightingID { get; set; }
        public string EntityName { get; set; } = string.Empty;
        public string PostedByAlias { get; set; } = string.Empty;
        public string CityName { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public DateTime TimeObserved { get; set; }
        public int CredibilityScore { get; set; }
        public List<string> Behaviors { get; set; } = new();
    }
}
