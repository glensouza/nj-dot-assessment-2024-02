﻿namespace NJDOT.Models;

public class Car
{
    public string CarName { get; set; } = string.Empty;
    public string CarImage { get; set; } = string.Empty;
    public double Score { get; set; } = 1200;
    public int Wins { get; set; } = 0;
    public int Losses { get; set; } = 0;
}
