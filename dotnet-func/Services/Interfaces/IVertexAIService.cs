namespace dotnet_func.Services.Interfaces
{
    public interface IVertexAIService
    {
        Task<string> ClassifyFoodAsync(byte[] imageBytes, string contentType = "image/jpeg");
        Task<float[]> GetImageEmbeddingAsync(byte[] imageBytes);
    }
}
