namespace dotnet_func.Models.RequestModels;


public class UpdateUserRequest
{
    public DateTime? DateOfBirth { get; set; }
    public Gender? Gender { get; set; }
    public double? Weight { get; set; }
    public double? Height { get; set; }
    public ActivityLevel? ActivityLevel { get; set; }
    public double? DailyCalorieGoal { get; set; }
    public List<string>? Allergies { get; set; }
    public string? DietaryPreference { get; set; }
    public string? AvatarUrl { get; set; }
}


