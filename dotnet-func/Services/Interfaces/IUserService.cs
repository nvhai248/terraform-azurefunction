using dotnet_func.Models;
using dotnet_func.Models.RequestModels;

namespace dotnet_func.Services.Interfaces;

public interface IUserService
{
    public User? GetUserInfo(string userId);
    public User? UpdateUserInfo(string userId, UpdateUserRequest updatedUser);
}
