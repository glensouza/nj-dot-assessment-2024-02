using Microsoft.EntityFrameworkCore;
using NJDOT.Services;
using NJDOT.Web.Blazor.Client.Pages;
using NJDOT.Web.Blazor.Components;
using NJDOT.Web.Blazor.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents()
    .AddInteractiveWebAssemblyComponents();

string connectionString = builder.Configuration.GetConnectionString("CarDB") ?? throw new InvalidOperationException("Connection string 'CarDB' not found.");
builder.Services.AddDbContext<CarContext>(options => options.UseSqlServer(connectionString));

builder.Services.AddScoped<CarRepository>();
builder.Services.AddSingleton<NameGenerator>();
builder.Services.AddSingleton<CarDoesNotExist>();

var app = builder.Build();

await using CarContext db = app.Services.CreateScope().ServiceProvider.GetRequiredService<CarContext>();
await db.Database.MigrateAsync();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseWebAssemblyDebugging();
}
else
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();
app.UseAntiforgery();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode()
    .AddInteractiveWebAssemblyRenderMode()
    .AddAdditionalAssemblies(typeof(NJDOT.Web.Blazor.Client._Imports).Assembly);

app.Run();
