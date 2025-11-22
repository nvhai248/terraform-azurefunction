using Qdrant.Client.Grpc;

namespace dotnet_func.Services.Interfaces
{
    public interface IQdrantService
    {
        Task<IEnumerable<ScoredPoint>> SearchAsync(float[] vector, int limit = 5);
        Task UpsertAsync(float[] vector, object payload);
        
        // Collection management
        Task CreateCollectionAsync();
        Task<bool> CollectionExistsAsync();
        Task DeleteCollectionAsync();
        
        // Food-specific operations
        Task<IEnumerable<ScoredPoint>> SearchFoodWithGoogleAIAsync(byte[] imageBuffer, float threshold = 0.8f);
        Task InsertFoodWithGoogleAIAsync(float[] vector, object analysisResult, float confidenceThreshold = 0.85f);
        Task<ScoredPoint?> FindExistingFoodWithGoogleAIAsync(byte[] imageBuffer, float threshold = 0.85f);
    }
}
