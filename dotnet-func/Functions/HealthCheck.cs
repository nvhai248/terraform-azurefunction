using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.OpenApi.Models;
using System.Net;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using dotnet_func.Services.Interfaces;

namespace dotnet_func;

public class HealthCheck
{
    private readonly IGreetingService _greetingService;
    private readonly ILogger<HealthCheck> _logger;

    public HealthCheck(IGreetingService greetingService, ILogger<HealthCheck> logger)
    {
        _greetingService = greetingService;
        _logger = logger;
    }

    [Function("HealthCheck")]
    [OpenApiOperation(operationId: "helloWorld", tags: new[] { "greeting" }, Summary = "Say Hello", Description = "Returns a greeting message.")]
    [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "text/plain", bodyType: typeof(string), Description = "The OK response")]
    [OpenApiParameter(name: "name", In = ParameterLocation.Query, Required = false, Type = typeof(string), Description = "The name to greet")]
    public Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req)
    {
        _logger.LogInformation("C# HTTP trigger function processed a request.");
        var name = string.IsNullOrEmpty(req.Query["name"]) ? "World" : req.Query["name"].ToString();
        var message = _greetingService.GetGreeting(name);
        return Task.FromResult<IActionResult>(new OkObjectResult(message));
    }
}
