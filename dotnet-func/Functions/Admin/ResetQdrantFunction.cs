using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using dotnet_func.Services.Interfaces;

namespace dotnet_func.Functions.Admin;

public class ResetQdrantFunction
{
    private readonly IQdrantService _qdrantService;

    public ResetQdrantFunction(IQdrantService qdrantService)
    {
        _qdrantService = qdrantService;
    }

    [Function("reset-qdrant")]
    public async Task<HttpResponseData> Run(
        [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
    {
        try
        {
            // Delete the collection
            await _qdrantService.DeleteCollectionAsync();
            
            // Wait a bit
            await Task.Delay(1000);
            
            // Recreate it
            await _qdrantService.CreateCollectionAsync();

            var response = req.CreateResponse(HttpStatusCode.OK);
            await response.WriteAsJsonAsync(new
            {
                Message = "Qdrant collection reset successfully",
                Collection = "food_vectors"
            });

            return response;
        }
        catch (Exception ex)
        {
            var errorResp = req.CreateResponse(HttpStatusCode.BadRequest);
            await errorResp.WriteStringAsync($"Error: {ex.Message}");
            return errorResp;
        }
    }
}
