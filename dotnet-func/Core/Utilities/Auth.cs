using System.IdentityModel.Tokens.Jwt;
using Microsoft.AspNetCore.Http;
using Microsoft.Azure.Functions.Worker.Http;

namespace dotnet_func.Utilities;

public static class Auth
{
    /// <summary>
    /// Extracts the Bearer token from the Authorization header.
    /// </summary>
    /// <param name="request">The HTTP request containing the Authorization header.</param>
    /// <returns>The token if found, otherwise null.</returns>
    public static string? ExtractToken(HttpRequest request)
    {
        var authHeader = request.Headers.TryGetValue("Authorization", out var headers)
            ? headers.FirstOrDefault()
            : null;

        if (string.IsNullOrEmpty(authHeader))
            return null;

        var parts = authHeader.Split(' ');
        if (parts.Length != 2 || parts[0] != "Bearer" || string.IsNullOrEmpty(parts[1]))
            return null;

        return parts[1];
    }

    /// <summary>
    /// Decodes a JWT and extracts the user ID, preferring 'oid' (Azure AD) or falling back to 'sub'.
    /// </summary>
    /// <param name="token">The JWT token to decode.</param>
    /// <returns>The user ID if found, otherwise null.</returns>
    public static string? GetUserId(string? token)
    {
        if (string.IsNullOrEmpty(token))
            return null;

        try
        {
            var handler = new JwtSecurityTokenHandler();
            var jwtToken = handler.ReadJwtToken(token);
            var claims = jwtToken.Claims;

            // Prefer Azure AD Object ID ('oid'), fallback to standard 'sub'
            var oid = claims.FirstOrDefault(c => c.Type == "oid")?.Value;
            var sub = claims.FirstOrDefault(c => c.Type == "sub")?.Value;

            return oid ?? sub;
        }
        catch
        {
            return null;
        }
    }
}

