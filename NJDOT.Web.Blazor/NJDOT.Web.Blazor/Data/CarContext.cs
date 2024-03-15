using Microsoft.EntityFrameworkCore;
using NJDOT.Models;

namespace NJDOT.Web.Blazor.Data;

public class CarContext : DbContext
{
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseInMemoryDatabase("CarsInMemoryDatabase");
    }

    public DbSet<CarModel> Cars { get; set; }
    public DbSet<VoteModel> Votes { get; set; }
}
