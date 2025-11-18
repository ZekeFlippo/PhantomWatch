using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using PhantomWatchUI.DataDelegates;
using PhantomWatchUI.Models;

namespace PhantomWatchUI.Pages
{
    public class SignUpModel : PageModel
    {
        private readonly UsersDelegate _usersDelegate;

        public SignUpModel(UsersDelegate usersDelegate)
        {
            _usersDelegate = usersDelegate;
        }

        [BindProperty]
        public string Email { get; set; } = string.Empty;

        [BindProperty]
        public string Alias { get; set; } = string.Empty;

        [BindProperty]
        public string Name { get; set; } = string.Empty;

        [BindProperty]
        public short Age { get; set; }

        public string? ErrorMessage { get; set; }

        public void OnGet()
        {
        }

        public async Task<IActionResult> OnPostAsync()
        {
            if (string.IsNullOrWhiteSpace(Email) ||
                string.IsNullOrWhiteSpace(Alias) ||
                string.IsNullOrWhiteSpace(Name))
            {
                ErrorMessage = "Email, alias, and display name are required.";
                return Page();
            }

            var existing = (await _usersDelegate.GetUsersAsync())
                .FirstOrDefault(u => u.Email.Equals(Email, StringComparison.OrdinalIgnoreCase)
                                  || u.Alias.Equals(Alias, StringComparison.OrdinalIgnoreCase));

            if (existing != null)
            {
                ErrorMessage = "A user with that email or alias already exists.";
                return Page();
            }

            var newUser = new User
            {
                Email = Email,
                Alias = Alias,
                Name = Name,
                Age = Age,
                isAdmin = false
            };

            await _usersDelegate.InsertUserAsync(newUser);

            // Fetch again to get assigned UserID
            var users = await _usersDelegate.GetUsersAsync();
            var user = users.First(u => u.Email.Equals(Email, StringComparison.OrdinalIgnoreCase));

            HttpContext.Session.SetInt32("UserID", user.UserID);
            HttpContext.Session.SetString("Alias", user.Alias);
            HttpContext.Session.SetString("Name", user.Name);
            HttpContext.Session.SetString("IsAdmin", user.isAdmin ? "1" : "0");

            return RedirectToPage("/Home");
        }
    }
}
