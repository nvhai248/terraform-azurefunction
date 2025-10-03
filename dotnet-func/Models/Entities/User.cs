namespace dotnet_func.Models;

public enum Gender
{
    Male,
    Female,
    Other
}

public class User
{
    public required string Id { get; set; }

    public DateTime? DateOfBirth { get; set; }
    public string? Gender { get; set; }
    public string? PhoneNumber { get; set; }
    public string? AvatarUrl { get; set; }

    public float? Height { get; set; }
    public float? Weight { get; set; }
    public float? TargetWeight { get; set; }
    public float? Bmi { get; set; }
    public ActivityLevel? ActivityLevel { get; set; }
    public string[] Allergies { get; set; } = Array.Empty<string>();
    public string? MedicalHistory { get; set; }

    public string? DietaryPreference { get; set; }
    public int? DailyCalorieGoal { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public ICollection<Meal> Meals { get; set; } = new List<Meal>();
    public ICollection<WeightLog> WeightLogs { get; set; } = new List<WeightLog>();
    public ICollection<Activity> Activities { get; set; } = new List<Activity>();
}