using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc;

namespace PhantomWatchUI.Pages
{
    public class AdminModel : PageModel
    {
        public IActionResult OnGet()
        {
            // Only allow access if session IsAdmin == "1"
            if (HttpContext.Session.GetString("IsAdmin") != "1")
            {
                return RedirectToPage("/Index");
            }

            return Page();
        }
    }
}