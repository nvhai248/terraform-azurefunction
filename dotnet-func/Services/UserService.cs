using dotnet_func.Data;
using dotnet_func.Models;
using dotnet_func.Models.RequestModels;
using dotnet_func.Services.Interfaces;

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
}
