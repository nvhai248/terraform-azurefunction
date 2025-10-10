using Microsoft.OpenApi.Models;

namespace dotnet_func.Configuration;

public class OpenApiConfig
{
    public static void ConfigureOpenApi(OpenApiInfo options)
    {
        options.Title = "My Azure Functions API";
        options.Version = "1.0.0";
        options.Description = "API documentation for my Azure Functions running on .NET Isolated model.";
    }
}
