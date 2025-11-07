using dotnet_func.Data;
using dotnet_func.Models;
using dotnet_func.Models.RequestModels;
using dotnet_func.Services.Interfaces;
using dotnet_func.Utilities;

namespace dotnet_func.Services;

public class UserService : IUserService
{
    private readonly AppDbContext _context;

    public UserService(AppDbContext context)
    {
        _context = context;
    }
    public User? GetUserInfo(string userId)
    {
        User? user = _context.Users.Find(userId);
        return user;
    }

    public User? UpdateUserInfo(string userId, UpdateUserRequest updatedUser)
    {
        var user = _context.Users.Find(userId);
        if (user == null)
        {
            return null;
        }

        if (updatedUser.DateOfBirth.HasValue)
            user.DateOfBirth = updatedUser.DateOfBirth.Value;
        if (updatedUser.Gender.HasValue)
            user.Gender = updatedUser.Gender.Value.ToString();
        if (updatedUser.Weight.HasValue)
            user.Weight = (float?)updatedUser.Weight.Value;
        if (updatedUser.Height.HasValue)
            user.Height = (float?)updatedUser.Height.Value;
        if (updatedUser.ActivityLevel.HasValue)
            user.ActivityLevel = updatedUser.ActivityLevel.Value;
        if (updatedUser.DailyCalorieGoal.HasValue)
            user.DailyCalorieGoal = (int?)updatedUser.DailyCalorieGoal.Value;
        if (updatedUser.Allergies != null)
            user.Allergies = updatedUser.Allergies.ToArray();
        if (updatedUser.DietaryPreference != null)
            user.DietaryPreference = updatedUser.DietaryPreference.ToString();
        if (updatedUser.AvatarUrl != null)
            user.AvatarUrl = updatedUser.AvatarUrl;

        _context.SaveChanges();
        return user;
    }

    /// <summary>
    /// Adds a new user to the database.
    /// </summary>
    /// <param name="newUser">User entity to be added.</param>
    /// <param name="userId">The user ID to assign.</param>
    /// <returns>The newly created user.</returns>
    public async Task<User> AddUserAsync(UpdateUserRequest newUser, string userId)
    {
        var user = new User()
        {
            Id = userId
        };

        if (newUser.DateOfBirth.HasValue)
            user.DateOfBirth = newUser.DateOfBirth.Value;
        if (newUser.Gender.HasValue)
            user.Gender = newUser.Gender.Value.ToString();
        if (newUser.Weight.HasValue)
            user.Weight = (float?)newUser.Weight.Value;
        if (newUser.Height.HasValue)
            user.Height = (float?)newUser.Height.Value;
        if (newUser.ActivityLevel.HasValue)
            user.ActivityLevel = newUser.ActivityLevel.Value;
        if (newUser.DailyCalorieGoal.HasValue)
            user.DailyCalorieGoal = (int?)newUser.DailyCalorieGoal.Value;
        if (newUser.Allergies != null)
            user.Allergies = newUser.Allergies.ToArray();
        if (newUser.DietaryPreference != null)
            user.DietaryPreference = newUser.DietaryPreference.ToString();
        if (newUser.AvatarUrl != null)
            user.AvatarUrl = newUser.AvatarUrl;
        // --- Auto calculate missing health fields ---
        if (user.DateOfBirth != default && user.Gender != null && user.Weight != null && user.Height != null)
        {
            var result = UserHealthCalculator.GenerateHealthData(
                gender: user.Gender!,
                weightKg: user.Weight!.Value,
                heightCm: user.Height!.Value,
                dateOfBirth: user.DateOfBirth!.Value
            );

            // Calculate only if field not provided
            user.Bmi ??= (float)result.Bmi;
            user.DailyCalorieGoal ??= result.DailyCalorieGoal;
            user.DietaryPreference ??= result.DietaryPreference;
            user.ActivityLevel ??= Enum.TryParse<ActivityLevel>(result.ActivityLevel, out var level) ? level : ActivityLevel.Active;
            user.TargetWeight ??= (float)result.TargetWeight;
        }
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        return user;
    }
}
