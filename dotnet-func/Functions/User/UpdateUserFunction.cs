using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Enums;
using dotnet_func.Models;
using System.Net;
using dotnet_func.Utilities;
using dotnet_func.Services.Interfaces;
using dotnet_func.Models.RequestModels;
using Newtonsoft.Json;
using Microsoft.OpenApi.Models;

namespace dotnet_func;

public class UpdateUserFunction
{
    private readonly IUserService _iUserService;
    private readonly ILogger<UpdateUserFunction> _logger;

    public UpdateUserFunction(IUserService iUserService, ILogger<UpdateUserFunction> logger)
    {
        _iUserService = iUserService;
        _logger = logger;
    }

    [Function("UpdateUser")]
    [OpenApiOperation(
        operationId: "updateUser",
        tags: new[] { "User" },
        Summary = "Update user information",
        Description = "Updates an existing user's information by their authentication token.",
        Visibility = OpenApiVisibilityType.Important
    )]
    [OpenApiSecurity(
        "bearerAuth",
        SecuritySchemeType.Http,
        Scheme = OpenApiSecuritySchemeType.Bearer,
        BearerFormat = "JWT",
        Description = "Enter 'Bearer {token}'"
    )]
    [OpenApiRequestBody(
        contentType: "application/json",
        bodyType: typeof(UpdateUserRequest),
        Required = true,
        Description = "User update payload containing fields to be updated.",
        Example = typeof(UpdateUserRequestExample)
    )]
    [OpenApiResponseWithBody(
        statusCode: HttpStatusCode.OK,
        contentType: "application/json",
        bodyType: typeof(User),
        Summary = "User updated successfully",
        Description = "Returns the updated user information."
    )]
    [OpenApiResponseWithBody(
        statusCode: HttpStatusCode.BadRequest,
        contentType: "application/json",
        bodyType: typeof(object),
        Summary = "Invalid request body",
        Description = "Returned when the request body is missing or invalid."
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
        Description = "Returned when the user does not exist."
    )]
    public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Function, "post", Route = "user/update")] HttpRequest req)
    {
        _logger.LogInformation("Processing UpdateUser request...");
        var token = Auth.ExtractToken(req);
        var userId = Auth.GetUserId(token);

        if (userId == null)
        {
            _logger.LogWarning("Unauthorized request: missing or invalid token");
            return new UnauthorizedObjectResult(new { message = "Unauthorized" });
        }

        string body = await new StreamReader(req.Body).ReadToEndAsync();
        var updatedUser = JsonConvert.DeserializeObject<UpdateUserRequest>(body);

        if (updatedUser == null)
        {
            _logger.LogWarning("Invalid request body");
            return new BadRequestObjectResult(new { message = "Invalid request body" });
        }

        var user = _iUserService.UpdateUserInfo(userId, updatedUser);
        if (user == null)
        {
            user = await _iUserService.AddUserAsync(updatedUser, userId);
        }

        return new OkObjectResult(user);
    }

    private class UpdateUserRequestExample
    {
        public UpdateUserRequestExample()
        {
            // Set up example values
            Example = new UpdateUserRequest
            {
                DateOfBirth = new DateTime(1990, 1, 1),
                Gender = Gender.Male,
                Weight = 75,
                Height = 180,
                ActivityLevel = ActivityLevel.Active,
                DailyCalorieGoal = 2500,
                Allergies = new List<string> { "None" },
                DietaryPreference = "Omnivore",
                AvatarUrl = "https://example.com/avatar.jpg"
            };
        }

        public UpdateUserRequest Example { get; }
    }
}
