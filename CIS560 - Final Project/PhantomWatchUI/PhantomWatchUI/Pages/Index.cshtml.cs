using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc;

namespace PhantomWatchUI.Pages
{
    public class IndexModel : PageModel
    {
        public IActionResult OnGet()
        {
            // If already logged in, go straight to Home
            if (HttpContext.Session.GetInt32("UserID") != null)
            {
                return RedirectToPage("/Home");
            }
            return Page();
        }
    }
}
