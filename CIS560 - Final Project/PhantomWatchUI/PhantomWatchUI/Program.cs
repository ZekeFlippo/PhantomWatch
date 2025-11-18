using PhantomWatchUI.DataDelegates;

var builder = WebApplication.CreateBuilder(args);

// Razor Pages + Session
builder.Services.AddRazorPages();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});

// DATA DELEGATES – all the ones you inject anywhere
builder.Services.AddTransient<UsersDelegate>();
builder.Services.AddTransient<SightingsDelegate>();
builder.Services.AddTransient<EntitiesDelegate>();
builder.Services.AddTransient<BehaviorsDelegate>();
builder.Services.AddTransient<CitiesDelegate>();
builder.Services.AddTransient<UserSightingsDelegate>();
builder.Services.AddTransient<SightingBehaviorsDelegate>();
builder.Services.AddTransient<AggregatesDelegate>();
builder.Services.AddTransient<UserVotesDelegate>();


var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseSession();      // session before endpoints

app.MapRazorPages();

app.Run();
