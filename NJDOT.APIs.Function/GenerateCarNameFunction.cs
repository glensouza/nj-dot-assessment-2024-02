using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using NJDOT.Models;
using NJDOT.Services;

namespace NJDOT.APIs.Function;

public class GenerateCarName
{
    private readonly ILogger<GenerateCarName> logger;
    private readonly NameGenerator nameGenerator;

    public GenerateCarName(ILogger<GenerateCarName> logger, NameGenerator nameGenerator)
    {
        this.logger = logger;
        this.nameGenerator = nameGenerator;
    }

    [Function("GenerateCarName")]
    public IActionResult Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequest req)
    {
        this.logger.LogInformation("C# HTTP trigger function processed a request.");

        string carName = this.nameGenerator.GetRandomCarName();

        this.logger.LogInformation("Returning car name: {carName}", carName);

        return new OkObjectResult(new CarModel { CarName = carName });
    }
}
