using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using PhantomWatchUI.DataDelegates;
using PhantomWatchUI.Models;

namespace PhantomWatchUI.Pages
{
    public class AnalyticsDashboardModel : PageModel
    {
        private readonly AggregatesDelegate _aggregates;

        public AnalyticsDashboardModel(AggregatesDelegate aggregates)
        {
            _aggregates = aggregates;
        }

        public IEnumerable<RegionCredibility> TopRegions { get; set; } = Enumerable.Empty<RegionCredibility>();
        public IEnumerable<RegionScaryEntities> RegionsWithScary { get; set; } = Enumerable.Empty<RegionScaryEntities>();
        public IEnumerable<UserCredibilityStats> AvgCredByReporter { get; set; } = Enumerable.Empty<UserCredibilityStats>();
        public IEnumerable<ReporterSummary> ReporterSummary { get; set; } = Enumerable.Empty<ReporterSummary>();

        [BindProperty(SupportsGet = true)] public int MinScaryLevel { get; set; } = 7;
        [BindProperty(SupportsGet = true)] public int MinReports { get; set; } = 2;
        [BindProperty(SupportsGet = true)] public DateTime StartDate { get; set; } = DateTime.UtcNow.AddYears(-10);
        [BindProperty(SupportsGet = true)] public DateTime EndDate { get; set; } = DateTime.UtcNow;

        public async Task OnGetAsync()
        {
            await LoadAll();
        }

        private async Task LoadAll()
        {
            TopRegions = await _aggregates.GetTopRegionsByCredibilityAsync(StartDate, EndDate);
            RegionsWithScary = await _aggregates.GetRegionsWithHighScaryEntitiesAsync((short)MinScaryLevel);
            AvgCredByReporter = await _aggregates.GetAverageCredibilityByReporterAsync(MinReports);
            ReporterSummary = await _aggregates.GetRepeatVsSingleReportersAsync(StartDate, EndDate);
        }

        public async Task<IActionResult> OnGetTopRegionsAsync()
        {
            TopRegions = await _aggregates.GetTopRegionsByCredibilityAsync(StartDate, EndDate);
            await LoadAll(); return Page();
        }

        public async Task<IActionResult> OnGetScaryRegionsAsync()
        {
            RegionsWithScary = await _aggregates.GetRegionsWithHighScaryEntitiesAsync((short)MinScaryLevel);
            await LoadAll(); return Page();
        }

        public async Task<IActionResult> OnGetReporterCredibilityAsync()
        {
            AvgCredByReporter = await _aggregates.GetAverageCredibilityByReporterAsync(MinReports);
            await LoadAll(); return Page();
        }

        public async Task<IActionResult> OnGetReporterSummaryAsync()
        {
            ReporterSummary = await _aggregates.GetRepeatVsSingleReportersAsync(StartDate, EndDate);
            await LoadAll(); return Page();
        }
    }
}
