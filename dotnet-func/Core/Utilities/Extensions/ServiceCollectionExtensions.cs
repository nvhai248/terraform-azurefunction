using dotnet_func.Data;
using dotnet_func.Services;
using dotnet_func.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Qdrant.Client;

namespace dotnet_func.Utilities.Extensions
{
    public static class ServiceCollectionExtensions
    {
        public static IServiceCollection AddCustomServices(this IServiceCollection services)
        {
            // -------------------------------
            // DB
            // -------------------------------
            services.AddDbContext<AppDbContext>(options =>
                options.UseNpgsql(Environment.GetEnvironmentVariable("PostgreSqlConnectionString")));

            // -------------------------------
            // App Services
            // -------------------------------
            services.AddSingleton<IGreetingService, GreetingService>();
            services.AddSingleton<IUserService, UserService>();

            // -------------------------------
            // HttpClientFactory (required!)
            // -------------------------------
            services.AddHttpClient();

            // -------------------------------
            // Qdrant (using REST API via HttpClient)
            // -------------------------------
            services.AddSingleton<IQdrantService, QdrantService>();

            // -------------------------------
            // Vertex AI
            // -------------------------------
            services.AddSingleton<IVertexAIService, VertexAIService>();

            return services;
        }
    }
}
