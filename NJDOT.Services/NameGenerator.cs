using NJDOT.Models;

namespace NJDOT.Services;

public class NameGenerator
{
    private readonly List<string> names = [];

    public NameGenerator(string fileLocation = "carNames.txt")
    {
        IEnumerable<string> lines = File.ReadLines(fileLocation);
        foreach (string line in lines)
        {
            this.names.Add(line);
        }
    }

    public string GetRandomCarName()
    {
        this.names.Shuffle();
        int firstName = Random.Shared.Next(this.names.Count);
        if (this.names[firstName].Contains(' '))
        {
            return this.names[firstName];
        }

        int secondName = Random.Shared.Next(this.names.Count);
        if (this.names[secondName].Contains(' '))
        {
            return this.names[secondName];
        }

        string generatedCarName = $"{this.names[firstName]} {this.names[secondName]}";
        return generatedCarName;
    }
}