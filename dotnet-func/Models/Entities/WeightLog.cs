namespace dotnet_func.Models;

public class WeightLog
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public required string UserId { get; set; }
    public required User User { get; set; }

    public float Weight { get; set; }
    public DateTime LoggedAt { get; set; } = DateTime.UtcNow;
}
