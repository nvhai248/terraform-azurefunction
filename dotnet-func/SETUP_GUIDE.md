# Food Detection API Setup Guide

This guide will help you set up the Food Detection Azure Function, which uses Google Vertex AI for image analysis and embeddings, and Qdrant for vector similarity search.

## Prerequisites

*   **Dotnet 8 SDK**: [Download here](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)
*   **Azure Functions Core Tools**: [Install guide](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local)
*   **Docker Desktop** (or Docker Engine): For running Qdrant locally.
*   **Google Cloud Account**: With billing enabled.

---

## 1. Google Cloud Setup

### Step 1.1: Create a Project
1.  Go to the [Google Cloud Console](https://console.cloud.google.com/).
2.  Create a new project (e.g., `food-detection-app`).
3.  Note down your **Project ID**.

### Step 1.2: Enable Vertex AI API
1.  In the Google Cloud Console, navigate to **Vertex AI**.
2.  Click **Enable All Recommended APIs** (or specifically enable "Vertex AI API").

### Step 1.3: Create a Service Account
1.  Go to **IAM & Admin** > **Service Accounts**.
2.  Click **Create Service Account**.
3.  Name it (e.g., `vertex-ai-sa`).
4.  Grant it the **Vertex AI User** role.
5.  Click **Done**.

### Step 1.4: Generate Key
1.  Click on the newly created service account email.
2.  Go to the **Keys** tab.
3.  Click **Add Key** > **Create new key**.
4.  Select **JSON** and click **Create**.
5.  A JSON file will download. **Keep this safe!** You will need its content.

---

## 2. Qdrant Setup (Local)

We will use Docker to run a local instance of the Qdrant vector database.

1.  Open your terminal.
2.  Run the following command:

```bash
docker run -p 6333:6333 -p 6334:6334 \
    -v $(pwd)/qdrant_storage:/qdrant/storage:z \
    qdrant/qdrant
```

*   This starts Qdrant on port `6333` (HTTP) and `6334` (gRPC).
*   It mounts a local volume `qdrant_storage` to persist data.

---

## 3. Environment Configuration

1.  Navigate to the `dotnet-func` directory.
2.  Create or update the `local.settings.json` file with the following structure:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
    
    "PostgreSqlConnectionString": "your_postgres_connection_string_if_needed",
    
    "QDRANT_URL": "http://localhost:6333",
    "QDRANT_API_KEY": "", 
    
    "VERTEXAI_BASE_URL": "https://us-central1-aiplatform.googleapis.com",
    "VERTEXAI_PROJECT_ID": "your-google-project-id",
    "VERTEXAI_MODEL_NAME": "gemini-1.5-flash",
    "VERTEXAI_SERVICE_ACCOUNT": "BASE64_ENCODED_JSON_KEY"
  }
}
```

### How to get `VERTEXAI_SERVICE_ACCOUNT` value:
The service account JSON content must be Base64 encoded.

**On Linux/Mac:**
```bash
cat path/to/your-key-file.json | base64 -w 0
```

**On Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("path\to\your-key-file.json"))
```

Copy the output string and paste it into the `VERTEXAI_SERVICE_ACCOUNT` value.

---

## 4. Running the Project

1.  Open a terminal in the `dotnet-func` directory.
2.  Start the function app:

```bash
func start
```

3.  The app should start and list the available endpoints:
    *   `http://localhost:7071/api/food-detect` (POST)
    *   `http://localhost:7071/api/reset-qdrant` (POST)

---

## 5. Testing

### Reset Qdrant Collection (Optional)
If you need to clear the database and start fresh:

```bash
curl -X POST http://localhost:7071/api/reset-qdrant
```

### Analyze a Food Image
Send a POST request with a food image to the detection endpoint.

**Using cURL:**
```bash
curl -X POST http://localhost:7071/api/food-detect \
  -F "file=@/path/to/your/food_image.jpg"
```

**Expected Response (New Food):**
```json
{
  "Status": "new",
  "Message": "Food analyzed and stored successfully",
  "VertexAI": { ... },
  "SimilarFoods": []
}
```

**Expected Response (Existing Food):**
```json
{
  "Status": "existing",
  "Message": "Similar food found in database",
  "SimilarityScore": 0.99,
  "ExistingData": { ... }
}
```
