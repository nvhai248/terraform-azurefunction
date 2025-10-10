using dotnet_func.Configuration;
using dotnet_func.Utilities.Extensions;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

var builder = FunctionsApplication.CreateBuilder(args);

builder.ConfigureFunctionsWebApplication();
builder.Services
    .AddApplicationInsightsTelemetryWorkerService()
    .ConfigureFunctionsApplicationInsights()
    .AddCustomServices()
    .AddSwaggerGen(options =>
    {
        var openApiInfo = new OpenApiInfo();
        OpenApiConfig.ConfigureOpenApi(openApiInfo);
        options.SwaggerDoc("v1", openApiInfo);
        options.SwaggerGeneratorOptions = new SwaggerGeneratorOptions();
    });

var app = builder.Build();
app.Run();
