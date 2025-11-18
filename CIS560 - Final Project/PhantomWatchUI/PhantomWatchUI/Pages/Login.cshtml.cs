using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using PhantomWatchUI.DataDelegates;
using PhantomWatchUI.Models;

namespace PhantomWatchUI.Pages
{
    public class LoginModel : PageModel
    {
        private readonly UsersDelegate _usersDelegate;

        public LoginModel(UsersDelegate usersDelegate)
        {
            _usersDelegate = usersDelegate;
        }

        [BindProperty]
        public string EmailOrAlias { get; set; } = string.Empty;

        public string? ErrorMessage { get; set; }

        public void OnGet()
        {
        }

        public async Task<IActionResult> OnPostAsync()
        {
            if (string.IsNullOrWhiteSpace(EmailOrAlias))
            {
                ErrorMessage = "Please enter your email or alias.";
                return Page();
            }

            var users = await _usersDelegate.GetUsersAsync();
            var user = users.FirstOrDefault(u =>
                string.Equals(u.Email, EmailOrAlias, StringComparison.OrdinalIgnoreCase) ||
                string.Equals(u.Alias, EmailOrAlias, StringComparison.OrdinalIgnoreCase));

            if (user == null)
            {
                ErrorMessage = "No user found with that email or alias.";
                return Page();
            }

            // "Authenticate" – no real password check
            HttpContext.Session.SetInt32("UserID", user.UserID);
            HttpContext.Session.SetString("Alias", user.Alias);
            HttpContext.Session.SetString("Name", user.Name);
            HttpContext.Session.SetString("IsAdmin", user.isAdmin ? "1" : "0");

            return RedirectToPage("/Home");
        }
    }
}
