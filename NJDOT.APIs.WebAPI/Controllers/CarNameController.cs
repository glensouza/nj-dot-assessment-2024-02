using Microsoft.AspNetCore.Mvc;
using NJDOT.Models;
using NJDOT.Services;

namespace NJDOT.APIs.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CarNameController(ILogger<CarNameController> logger, NameGenerator nameGenerator) : ControllerBase
    {
        [HttpGet(Name = "GetCarName")]
        public Car Get()
        {
            logger.LogInformation("Getting a random car name");
            string carName = nameGenerator.GetRandomCarName();
            logger.LogInformation("Returning car name: {carName}", carName);
            return new Car { Name = carName };
        }
    }
}
