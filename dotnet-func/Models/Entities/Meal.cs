namespace dotnet_func.Models;

public enum MealType
{
    BREAKFAST,
    LUNCH,
    DINNER,
    SNACK
}

public class Meal
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public required string UserId { get; set; }
    public required User User { get; set; }

    public string? ImageUrl { get; set; }
    public string? Name { get; set; }
    public string? Description { get; set; }
    public MealType MealType { get; set; }

    public int? Calories { get; set; }
    public float? Protein { get; set; }
    public float? Fat { get; set; }
    public float? Carbs { get; set; }
    public DateTime DetectedAt { get; set; } = DateTime.UtcNow;
}