using dotnet_func.Services.Interfaces;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Configuration;
using System.Net.Http.Headers;
using System.Net.Http.Json;

namespace dotnet_func.Services
{
    public class VertexAIService : IVertexAIService
    {
        private readonly HttpClient _httpClient;
        private readonly string _baseUrl;
        private readonly string _projectId;
        private readonly string _modelName;
        private readonly GoogleCredential _credential;

        public VertexAIService(IConfiguration config, System.Net.Http.IHttpClientFactory httpClientFactory)
        {
            _httpClient = httpClientFactory.CreateClient();

            _baseUrl = config["VERTEXAI_BASE_URL"]
                ?? "https://us-central1-aiplatform.googleapis.com";

            _projectId = config["VERTEXAI_PROJECT_ID"]
                ?? throw new Exception("Missing VERTEXAI_PROJECT_ID");

            _modelName = config["VERTEXAI_MODEL_NAME"]
                ?? "gemini-1.5-flash"; // default model

            // var serviceAccountJson = File.ReadAllText("vertex-sa.json");

            var serviceAccountBase64 = config["VERTEXAI_SERVICE_ACCOUNT"]
                ?? throw new Exception("Missing VERTEXAI_SERVICE_ACCOUNT");

            var serviceAccountJson = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(serviceAccountBase64));

            _credential = LoadCredentialAsync(serviceAccountJson).Result;
        }

        // ---------------------------------------------------------------------
        // LOAD SERVICE ACCOUNT CREDENTIAL
        // ---------------------------------------------------------------------
#pragma warning disable CS0618 // Type or member is obsolete
        private Task<GoogleCredential> LoadCredentialAsync(string serviceAccountJson)
        {
            // Parse the service account JSON into a GoogleCredential and add the cloud-platform scope
            var credential = GoogleCredential.FromJson(serviceAccountJson);
            var scoped = credential.CreateScoped(new[] { "https://www.googleapis.com/auth/cloud-platform" });
            return Task.FromResult(scoped);
        }
#pragma warning restore CS0618 // Type or member is obsolete

        // ---------------------------------------------------------------------
        // SIMPLE TEXT GENERATION
        // ---------------------------------------------------------------------
        public Task<string> GenerateText(string prompt)
        {
            // This method is synchronous → no async/await needed
            return Task.FromResult($"Placeholder for prompt: {prompt}");
        }

        // ---------------------------------------------------------------------
        // FOOD CLASSIFICATION (IMAGE → LABELS)
        // Using Gemini multimodal endpoint
        // ---------------------------------------------------------------------
        public async Task<string> ClassifyFoodAsync(byte[] imageBytes, string contentType = "image/jpeg")
        {
            var base64 = Convert.ToBase64String(imageBytes);

            var token = await _credential.UnderlyingCredential.GetAccessTokenForRequestAsync();

            var url = $"{_baseUrl}/v1/projects/{_projectId}/locations/us-central1/publishers/google/models/{_modelName}:generateContent";

            var requestBody = new
            {
                contents = new[]
                {
                    new {
                        role = "user",
                        parts = new [] {
                            new {
                                inline_data = new {
                                    mime_type = contentType,
                                    data = base64
                                }
                            }
                        }
                    }
                }
            };

            var req = new HttpRequestMessage(HttpMethod.Post, url);
            req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
            req.Content = JsonContent.Create(requestBody);

            var response = await _httpClient.SendAsync(req);
            var json = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception($"VertexAI Error: {response.StatusCode}\n{json}");
            }

            return json; // Gemini returns labels/descriptions inside this JSON
        }

        // ---------------------------------------------------------------------
        // IMAGE EMBEDDING (For Qdrant)
        // Using Vertex AI multimodalembedding@001 model
        // ---------------------------------------------------------------------
        public async Task<float[]> GetImageEmbeddingAsync(byte[] imageBytes)
        {
            var base64 = Convert.ToBase64String(imageBytes);
            var token = await _credential.UnderlyingCredential.GetAccessTokenForRequestAsync();

            var url = $"{_baseUrl}/v1/projects/{_projectId}/locations/us-central1/publishers/google/models/multimodalembedding@001:predict";

            var requestBody = new
            {
                instances = new[]
                {
                    new
                    {
                        image = new
                        {
                            bytesBase64Encoded = base64
                        }
                    }
                }
            };

            var req = new HttpRequestMessage(HttpMethod.Post, url);
            req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
            req.Content = JsonContent.Create(requestBody);

            var response = await _httpClient.SendAsync(req);
            var json = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception($"VertexAI Embedding Error: {response.StatusCode}\n{json}");
            }

            // Parse the response to extract embeddings
            var result = System.Text.Json.JsonDocument.Parse(json);
            var embeddings = result.RootElement
                .GetProperty("predictions")[0]
                .GetProperty("imageEmbedding");

            var embeddingList = new List<float>();
            foreach (var element in embeddings.EnumerateArray())
            {
                embeddingList.Add(element.GetSingle());
            }

            return embeddingList.ToArray();
        }
    }
}
