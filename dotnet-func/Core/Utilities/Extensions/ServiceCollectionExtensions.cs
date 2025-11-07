// Utilities/Extensions/ServiceCollectionExtensions.cs
using dotnet_func.Data;
using dotnet_func.Services;
using dotnet_func.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace dotnet_func.Utilities.Extensions
{
    public static class ServiceCollectionExtensions
    {
        public static IServiceCollection AddCustomServices(this IServiceCollection services)
        {
            services.AddSingleton<IGreetingService, GreetingService>();
            services.AddSingleton<IUserService, UserService>();
            services.AddDbContext<AppDbContext>(options =>
                options.UseNpgsql(Environment.GetEnvironmentVariable("PostgreSqlConnectionString")));
            return services;
        }
    }
}