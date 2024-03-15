using NJDOT.Models;
using NJDOT.Services;

namespace NJDOT.Web.Blazor.Data;

public class CarRepository
{
    private readonly CarContext carContext = new();

    public List<CarModel> GetAllCars()
    {
        return carContext.Cars.ToList() ?? new List<CarModel>();
    }

    public CarModel? GetCarByName(string carName)
    {
        return carContext.Cars.FirstOrDefault(s => s.CarName == carName);
    }

    public void AddCar(CarModel entity)
    {
        // Check unique name
        if (GetCarByName(entity.CarName) is not null)
        {
            return;
        }

        // Add Votes
        List<CarModel> cars = GetAllCars();
        foreach (CarModel car in cars.Where(s => s.CarName != entity.CarName))
        {
            VoteModel vote = new()
            {
                Car1 = entity.CarName,
                Car2 = car.CarName
            };
            carContext.Votes.Add(vote);
            carContext.SaveChanges();
        }

        carContext.Cars.Add(entity);
        carContext.SaveChanges();
    }

    public int GetVotesLeft()
    {
        int voteCount = carContext.Votes.Count(s => string.IsNullOrEmpty(s.Winner));
        return voteCount;
    }

    public VoteModel? GetVote()
    {
        List<VoteModel> votes = carContext.Votes.Where(s => string.IsNullOrEmpty(s.Winner)).ToList();
        if (votes.Count == 0)
        {
            return null;
        }

        VoteModel? vote = votes.FirstOrDefault();
        return vote;
    }

    public void VoteForWinner(string voteId, string winner)
    {
        VoteModel? vote = carContext.Votes.FirstOrDefault(s => s.Id == voteId);
        if (vote is null)
        {
            return;
        }

        CarModel? winningCar = GetCarByName(winner);
        CarModel? losingCar = GetCarByName(vote.Car1 == winner ? vote.Car2 : vote.Car1);
        if (winningCar is null || losingCar is null)
        {
            return;
        }

        (double, double) scores = EloCalculator.CalculateElo(winningCar.Score, losingCar.Score);
        winningCar.Score += scores.Item1;
        winningCar.Wins++;
        carContext.SaveChanges();
        losingCar.Score += scores.Item2;
        losingCar.Losses++;
        carContext.SaveChanges();

        vote.Winner = winner;
        vote.Score = scores.Item1;
        carContext.SaveChanges();
    }

    public List<VoteModel> GetAllVotes()
    {
        return carContext.Votes.ToList() ?? new List<VoteModel>();
    }

    public void DeleteCar(string carName)
    {
        List<VoteModel> votes = carContext.Votes.Where(s => s.Car1 == carName || s.Car2 == carName).ToList();
        foreach (VoteModel vote in votes)
        {
            carContext.Votes.Remove(vote);
            carContext.SaveChanges();

            if (string.IsNullOrEmpty(vote.Winner))
            {
                continue;
            }

            string competitor = vote.Car1 == carName ? vote.Car2 : vote.Car1;
            CarModel? competingCar = GetCarByName(competitor);
            if (competingCar is null)
            {
                continue;
            }

            if (vote.Winner == competitor)
            {
                competingCar.Score -= vote.Score;
                competingCar.Wins--;
            }
            else
            {
                competingCar.Score += vote.Score;
                competingCar.Losses--;
            }

            carContext.SaveChanges();
        }

        CarModel? carByName = GetCarByName(carName);
        if (carByName is null)
        {
            return;
        }

        carContext.Cars.Remove(carByName);
        carContext.SaveChanges();
    }
}
