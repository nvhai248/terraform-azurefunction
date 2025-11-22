using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Configuration;
using dotnet_func.Services.Interfaces;
using Qdrant.Client.Grpc;

namespace dotnet_func.Services
{
    public class QdrantService : IQdrantService
    {
        private readonly HttpClient _httpClient;
        private readonly string _baseUrl;
        private readonly string? _apiKey;
        private readonly IVertexAIService _vertexAIService;
        private const string CollectionName = "food_vectors";
        private const int VectorDimension = 1408; // multimodalembedding@001 dimension

        public QdrantService(
            IHttpClientFactory httpClientFactory, 
            IConfiguration configuration,
            IVertexAIService vertexAIService)
        {
            _httpClient = httpClientFactory.CreateClient();
            _baseUrl = configuration["QDRANT_URL"] ?? "http://localhost:6333";
            _apiKey = configuration["QDRANT_API_KEY"];
            _vertexAIService = vertexAIService;

            if (!string.IsNullOrEmpty(_apiKey))
            {
                _httpClient.DefaultRequestHeaders.Add("api-key", _apiKey);
            }
            
            // Ensure collection exists on startup
            _ = EnsureCollectionExistsAsync();
        }

        public async Task<IEnumerable<ScoredPoint>> SearchAsync(float[] vector, int limit = 5)
        {
            var requestBody = new
            {
                vector = vector,
                limit = limit,
                with_payload = true,
                with_vector = false
            };

            var url = $"{_baseUrl}/collections/{CollectionName}/points/search";
            Console.WriteLine($"Searching Qdrant at: {url}");

            var response = await _httpClient.PostAsJsonAsync(url, requestBody);

            if (response.StatusCode == System.Net.HttpStatusCode.NotFound)
            {
                Console.WriteLine($"Collection '{CollectionName}' not found. Returning empty results.");
                return Enumerable.Empty<ScoredPoint>();
            }

            if (!response.IsSuccessStatusCode)
            {
                var errorContent = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"Qdrant error: {response.StatusCode} - {errorContent}");
                throw new Exception($"Qdrant search failed: {response.StatusCode} - {errorContent}");
            }

            var jsonString = await response.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<QdrantSearchResponse>(jsonString);

            if (result?.Result == null)
            {
                return Enumerable.Empty<ScoredPoint>();
            }

            // Convert REST API response to ScoredPoint objects
            return result.Result.Select(r =>
            {
                var scoredPoint = new ScoredPoint
                {
                    Id = new PointId { Uuid = r.Id },
                    Score = r.Score
                };

                // Populate payload
                foreach (var kvp in r.Payload)
                {
                    scoredPoint.Payload[kvp.Key] = ConvertToValue(kvp.Value);
                }

                return scoredPoint;
            });
        }

        public async Task UpsertAsync(float[] vector, object payload)
        {
            var requestBody = new
            {
                points = new[]
                {
                    new
                    {
                        id = Guid.NewGuid().ToString(),
                        vector = vector,
                        payload = payload
                    }
                }
            };

            var response = await _httpClient.PutAsJsonAsync(
                $"{_baseUrl}/collections/{CollectionName}/points",
                requestBody);

            response.EnsureSuccessStatusCode();
        }

        // =====================================================================
        // COLLECTION MANAGEMENT
        // =====================================================================

        public async Task<bool> CollectionExistsAsync()
        {
            var response = await _httpClient.GetAsync($"{_baseUrl}/collections/{CollectionName}");
            return response.IsSuccessStatusCode;
        }

        public async Task CreateCollectionAsync()
        {
            var requestBody = new
            {
                vectors = new
                {
                    size = VectorDimension,
                    distance = "Cosine"
                }
            };

            var response = await _httpClient.PutAsJsonAsync(
                $"{_baseUrl}/collections/{CollectionName}",
                requestBody);

            if (response.IsSuccessStatusCode)
            {
                Console.WriteLine($"Collection '{CollectionName}' created successfully.");
            }
            else
            {
                var error = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"Failed to create collection: {response.StatusCode} - {error}");
            }
        }

        public async Task DeleteCollectionAsync()
        {
            var response = await _httpClient.DeleteAsync($"{_baseUrl}/collections/{CollectionName}");
            
            if (response.IsSuccessStatusCode)
            {
                Console.WriteLine($"Collection '{CollectionName}' deleted successfully.");
            }
            else
            {
                var error = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"Failed to delete collection: {response.StatusCode} - {error}");
            }
        }

        private async Task EnsureCollectionExistsAsync()
        {
            try
            {
                var exists = await CollectionExistsAsync();
                if (!exists)
                {
                    Console.WriteLine($"Collection '{CollectionName}' does not exist. Creating...");
                    await CreateCollectionAsync();
                }
                else
                {
                    Console.WriteLine($"Collection '{CollectionName}' already exists.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error ensuring collection exists: {ex.Message}");
            }
        }

        // =====================================================================
        // FOOD-SPECIFIC OPERATIONS
        // =====================================================================

        public async Task<IEnumerable<ScoredPoint>> SearchFoodWithGoogleAIAsync(byte[] imageBuffer, float threshold = 0.8f)
        {
            // Generate embedding from image
            var vector = await _vertexAIService.GetImageEmbeddingAsync(imageBuffer);
            
            // Search with threshold
            var results = await SearchAsync(vector, limit: 10);
            
            // Filter by threshold
            return results.Where(r => r.Score >= threshold);
        }

        public async Task InsertFoodWithGoogleAIAsync(float[] vector, object analysisResult, float confidenceThreshold = 0.85f)
        {
            // Log the payload being inserted for debugging
            var payloadJson = JsonSerializer.Serialize(analysisResult, new JsonSerializerOptions { WriteIndented = true });
            Console.WriteLine($"Inserting payload: {payloadJson}");
            
            // The analysisResult is expected to be the complete payload object
            // Just pass it through to UpsertAsync
            await UpsertAsync(vector, analysisResult);
            Console.WriteLine($"Inserted food vector with confidence threshold: {confidenceThreshold}");
        }

        public async Task<ScoredPoint?> FindExistingFoodWithGoogleAIAsync(byte[] imageBuffer, float threshold = 0.85f)
        {
            // Generate embedding from image
            var vector = await _vertexAIService.GetImageEmbeddingAsync(imageBuffer);
            
            // Search for similar items
            var results = await SearchAsync(vector, limit: 1);
            
            // Return the top result if it meets the threshold
            var topResult = results.FirstOrDefault();
            if (topResult != null && topResult.Score >= threshold)
            {
                Console.WriteLine($"Found existing food with similarity score: {topResult.Score}");
                return topResult;
            }
            
            Console.WriteLine($"No existing food found above threshold {threshold}");
            return null;
        }

        // =====================================================================
        // PRIVATE HELPERS
        // =====================================================================

        private static Qdrant.Client.Grpc.Value ConvertToValue(JsonElement element)
        {
            return element.ValueKind switch
            {
                JsonValueKind.String => new Qdrant.Client.Grpc.Value { StringValue = element.GetString() },
                JsonValueKind.Number => new Qdrant.Client.Grpc.Value { DoubleValue = element.GetDouble() },
                JsonValueKind.True or JsonValueKind.False => new Qdrant.Client.Grpc.Value { BoolValue = element.GetBoolean() },
                JsonValueKind.Object => ConvertObjectToValue(element),
                JsonValueKind.Array => ConvertArrayToValue(element),
                _ => new Qdrant.Client.Grpc.Value { NullValue = 0 }
            };
        }

        private static Qdrant.Client.Grpc.Value ConvertObjectToValue(JsonElement element)
        {
            var structValue = new Qdrant.Client.Grpc.Struct();
            foreach (var property in element.EnumerateObject())
            {
                structValue.Fields.Add(property.Name, ConvertToValue(property.Value));
            }
            return new Qdrant.Client.Grpc.Value { StructValue = structValue };
        }

        private static Qdrant.Client.Grpc.Value ConvertArrayToValue(JsonElement element)
        {
            var listValue = new Qdrant.Client.Grpc.ListValue();
            foreach (var item in element.EnumerateArray())
            {
                listValue.Values.Add(ConvertToValue(item));
            }
            return new Qdrant.Client.Grpc.Value { ListValue = listValue };
        }

        private class QdrantSearchResponse
        {
            [JsonPropertyName("result")]
            public List<QdrantSearchResult>? Result { get; set; }
        }

        private class QdrantSearchResult
        {
            [JsonPropertyName("id")]
            public string Id { get; set; } = string.Empty;

            [JsonPropertyName("score")]
            public float Score { get; set; }

            [JsonPropertyName("payload")]
            public Dictionary<string, JsonElement> Payload { get; set; } = new();
        }
    }
}
