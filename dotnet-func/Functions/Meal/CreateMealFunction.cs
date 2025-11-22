using System.Net;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Azure.Functions.Worker.Extensions.Http.AspNetCore;
using dotnet_func.Services.Interfaces;
using Qdrant.Client.Grpc;

namespace dotnet_func;

public class CreateMealFunction
{
    private readonly IVertexAIService _vertexAIService;
    private readonly IQdrantService _qdrantService;

    public CreateMealFunction(IVertexAIService vertexAIService, IQdrantService qdrantService)
    {
        _vertexAIService = vertexAIService;
        _qdrantService = qdrantService;
    }

    [Function("food-detect")]
    public async Task<HttpResponseData> Run(
        [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req,
        FunctionContext context)
    {
        try
        {
            var httpContext = context.GetHttpContext();
            if (httpContext?.Request.HasFormContentType != true)
            {
                var badResp = req.CreateResponse(HttpStatusCode.BadRequest);
                await badResp.WriteStringAsync("Request must be multipart/form-data.");
                return badResp;
            }

            var form = await httpContext.Request.ReadFormAsync();
            if (form.Files.Count == 0)
            {
                var badResp = req.CreateResponse(HttpStatusCode.BadRequest);
                await badResp.WriteStringAsync("No file uploaded.");
                return badResp;
            }

            var file = form.Files[0];
            byte[] imageBytes;
            using (var ms = new MemoryStream())
            {
                await file.CopyToAsync(ms);
                imageBytes = ms.ToArray();
            }

            var imageContentType = file.ContentType ?? "image/jpeg";

            // Step 1: Check if this food already exists (deduplication)
            var existingFood = await _qdrantService.FindExistingFoodWithGoogleAIAsync(
                imageBytes,
                threshold: 0.85f
            );

            Console.WriteLine($"Existed food: {existingFood}");

            if (existingFood != null)
            {
                // Food already exists - return existing data with clean payload
                var _payload = ExtractPayload(existingFood.Payload);

                var existingResponse = req.CreateResponse(HttpStatusCode.OK);
                await existingResponse.WriteAsJsonAsync(new
                {
                    Status = "existing",
                    Message = "Similar food found in database",
                    SimilarityScore = existingFood.Score,
                    ExistingData = new
                    {
                        Id = existingFood.Id.Uuid,
                        Score = existingFood.Score,
                        Payload = _payload
                    }
                });
                return existingResponse;
            }

            // Step 2: Analyze the food with Vertex AI
            var analysisResult = await _vertexAIService.ClassifyFoodAsync(imageBytes, imageContentType);
            var embedding = await _vertexAIService.GetImageEmbeddingAsync(imageBytes);

            // Step 3: Store the new food in Qdrant
            var payload = new
            {
                analysisResult = new
                {
                    classification = analysisResult,
                    contentType = imageContentType,
                    analyzedAt = DateTime.UtcNow
                },
                confidenceThreshold = 0.85f,
                createdAt = DateTime.UtcNow,
                source = "google_vertex_ai"
            };

            await _qdrantService.InsertFoodWithGoogleAIAsync(
                embedding,
                payload,
                confidenceThreshold: 0.85f
            );

            // Step 4: Find similar foods
            var similarFoods = await _qdrantService.SearchFoodWithGoogleAIAsync(
                imageBytes,
                threshold: 0.7f
            );

            // Step 5: Return comprehensive results
            var response = req.CreateResponse(HttpStatusCode.OK);
            await response.WriteAsJsonAsync(new
            {
                Status = "new",
                Message = "Food analyzed and stored successfully",
                VertexAI = new
                {
                    Classification = JsonSerializer.Deserialize<JsonElement>(analysisResult),
                    EmbeddingGenerated = true
                },
                SimilarFoods = similarFoods.Select(p => new
                {
                    Id = p.Id.Uuid,
                    SimilarityScore = p.Score,
                    Payload = ExtractPayload(p.Payload)
                }).ToList()
            });

            return response;
        }
        catch (Exception ex)
        {
            var errorResp = req.CreateResponse(HttpStatusCode.BadRequest);
            Console.WriteLine($"Error in food-detect: {ex}");
            await errorResp.WriteStringAsync($"Error: {ex.Message}");
            return errorResp;
        }
    }

    /// <summary>
    /// Extracts clean payload from Qdrant's Value dictionary
    /// </summary>
    private static Dictionary<string, object?> ExtractPayload(IDictionary<string, Qdrant.Client.Grpc.Value> payload)
    {
        var result = new Dictionary<string, object?>();

        foreach (var kvp in payload)
        {
            var value = ExtractValue(kvp.Value);

            // Special handling for nested analysisResult
            if (kvp.Key == "analysisResult" && value is Dictionary<string, object?> analysisDict)
            {
                // Parse the classification string as JSON if it exists
                if (analysisDict.TryGetValue("classification", out var classificationObj) &&
                    classificationObj is string classificationStr &&
                    !string.IsNullOrEmpty(classificationStr))
                {
                    try
                    {
                        analysisDict["classification"] = JsonSerializer.Deserialize<JsonElement>(classificationStr);
                    }
                    catch
                    {
                        // Keep as string if parsing fails
                    }
                }
                result[kvp.Key] = analysisDict;
            }
            else
            {
                result[kvp.Key] = value;
            }
        }

        return result;
    }

    /// <summary>
    /// Converts Qdrant.Client.Grpc.Value to a clean C# object
    /// </summary>
    private static object? ExtractValue(Qdrant.Client.Grpc.Value value)
    {
        return value.KindCase switch
        {
            Qdrant.Client.Grpc.Value.KindOneofCase.StringValue => value.StringValue,
            Qdrant.Client.Grpc.Value.KindOneofCase.DoubleValue => value.DoubleValue,
            Qdrant.Client.Grpc.Value.KindOneofCase.IntegerValue => value.IntegerValue,
            Qdrant.Client.Grpc.Value.KindOneofCase.BoolValue => value.BoolValue,
            Qdrant.Client.Grpc.Value.KindOneofCase.StructValue => ExtractStruct(value.StructValue),
            Qdrant.Client.Grpc.Value.KindOneofCase.ListValue => ExtractList(value.ListValue),
            _ => null
        };
    }

    private static Dictionary<string, object?> ExtractStruct(Qdrant.Client.Grpc.Struct structValue)
    {
        var result = new Dictionary<string, object?>();
        foreach (var kvp in structValue.Fields)
        {
            result[kvp.Key] = ExtractValue(kvp.Value);
        }
        return result;
    }

    private static List<object?> ExtractList(Qdrant.Client.Grpc.ListValue listValue)
    {
        return listValue.Values.Select(ExtractValue).ToList();
    }
}
