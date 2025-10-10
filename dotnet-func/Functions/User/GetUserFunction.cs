using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.OpenApi.Models;
using System.Net;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Enums;
using dotnet_func.Services.Interfaces;
using dotnet_func.Utilities;
using dotnet_func.Models;

namespace dotnet_func;

public class GetUserFunction
{
    private readonly IUserService _iUserService;
    private readonly ILogger<GetUserFunction> _logger;

    public GetUserFunction(IUserService userService, ILogger<GetUserFunction> logger)
    {
        _iUserService = userService;
        _logger = logger;
    }

    [Function("GetUser")]
    [OpenApiOperation(
        operationId: "getUser",
        tags: new[] { "User" },
        Summary = "Get user information",
        Description = "Retrieves user information based on the Bearer authentication token.",
        Visibility = OpenApiVisibilityType.Important
    )]
    [OpenApiSecurity(
        "bearerAuth",
        SecuritySchemeType.Http,
        Scheme = OpenApiSecuritySchemeType.Bearer,
        BearerFormat = "JWT",
        Description = "Enter 'Bearer {token}'"
    )]
    [OpenApiResponseWithBody(
        statusCode: HttpStatusCode.OK,
        contentType: "application/json",
        bodyType: typeof(User),
        Summary = "User information retrieved successfully",
        Description = "Returns the user information associated with the provided token."
    )]
    [OpenApiResponseWithBody(
        statusCode: HttpStatusCode.Unauthorized,
        contentType: "application/json",
        bodyType: typeof(object),
        Summary = "Unauthorized request",
        Description = "Returned when the authentication token is missing or invalid."
    )]
    [OpenApiResponseWithBody(
        statusCode: HttpStatusCode.NotFound,
        contentType: "application/json",
        bodyType: typeof(object),
        Summary = "User not found",
        Description = "Returned when the user associated with the token does not exist."
    )]
    public IActionResult Run([HttpTrigger(AuthorizationLevel.Function, "get", Route = "user/get")] HttpRequest req)
    {
        _logger.LogInformation("Processing GetUser request...");

        var token = Auth.ExtractToken(req);
        var userId = Auth.GetUserId(token);

        if (userId == null)
        {
            _logger.LogWarning("Unauthorized request: missing or invalid token");
            return new UnauthorizedObjectResult(new { message = "Unauthorized" });
        }

        var userInfo = _iUserService.GetUserInfo(userId);

        if (userInfo == null)
        {
            _logger.LogWarning("User not found");
            return new NotFoundObjectResult(new { message = "User not found" });
        }

        return new OkObjectResult(userInfo);
    }
}
