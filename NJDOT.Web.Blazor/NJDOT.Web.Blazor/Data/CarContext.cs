using Microsoft.EntityFrameworkCore;
using NJDOT.Models;

namespace NJDOT.Web.Blazor.Data;

public class CarContext : DbContext
{
    public CarContext(DbContextOptions options) : base(options) { }

    public DbSet<CarModel> Cars { get; set; }
    public DbSet<VoteModel> Votes { get; set; }
}
