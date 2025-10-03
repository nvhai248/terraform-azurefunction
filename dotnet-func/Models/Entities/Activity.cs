namespace dotnet_func.Models;

public enum ActivityLevel
{
    Sedentary,
    Active,
    VeryActive
}

public enum ActivityType
{
    Running,
    Gym,
    Cycling,
    Swimming,
    Walking,
    Other
}

public class Activity
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public required string UserId { get; set; }
    public required User User { get; set; }

    public ActivityType Type { get; set; }
    public int? DurationMin { get; set; }
    public int? Calories { get; set; }
    public DateTime LoggedAt { get; set; } = DateTime.UtcNow;
}