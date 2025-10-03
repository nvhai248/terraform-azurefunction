using dotnet_func.Services.Interfaces;

namespace dotnet_func.Services
{
    public class GreetingService : IGreetingService
    {
        public string GetGreeting(string name)
        {
            return $"Hello, {name}!";
        }
    }
}