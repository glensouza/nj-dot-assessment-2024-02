using NJDOT.Models;
using NJDOT.Services;

WebApplicationBuilder? builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<NameGenerator>();
WebApplication? app = builder.Build();

app.MapGet("/GenerateCarName", (NameGenerator nameGenerator) => new Car { Name = nameGenerator.GetRandomCarName() });

app.Run();
