# Azure Entra ID Dashboard

A modern Next.js dashboard with Azure Entra ID authentication using MSAL (Microsoft Authentication Library).

## Features

- 🔐 Azure Entra ID authentication
- 📊 Modern dashboard interface
- 📱 Responsive design
- 🎨 Beautiful UI with shadcn/ui components
- 🔄 Automatic token refresh
- 👤 User profile management
- 🔗 Azure Function App integration with access tokens
- 📡 API client utilities for authenticated requests

## Setup Instructions

### 1. Azure App Registration

1. Go to the [Azure Portal](https://portal.azure.com/)
2. Navigate to "Azure Active Directory" > "App registrations"
3. Click "New registration"
4. Fill in:
   - **Name**: Your app name (e.g., "NextJS Dashboard")
   - **Supported account types**: Choose based on your needs
   - **Redirect URI**: Select "Single-page application (SPA)" and enter `http://localhost:3000`
5. After creation, note down:
   - **Application (client) ID**
   - **Directory (tenant) ID**

### 2. Configure Permissions

1. In your app registration, go to "API permissions"
2. Click "Add a permission"
3. Choose "Microsoft Graph"
4. Select "Delegated permissions"
5. Add "User.Read" permission
6. Click "Grant admin consent"

### 2.1. Configure Function App Access (Optional)

If you want to call Azure Function Apps:

1. In your app registration, go to "API permissions"
2. Click "Add a permission"
3. Choose "APIs my organization uses"
4. Search for your Function App name
5. Select your Function App and add the required permissions
6. Update the `functionAppBaseUrl` in `lib/auth-config.ts` with your Function App URL

### 3. Environment Variables

1. Copy `.env.local.example` to `.env.local`
2. Replace the placeholder values:
   ```
   NEXT_PUBLIC_AZURE_CLIENT_ID=your-application-client-id
   NEXT_PUBLIC_AZURE_TENANT_ID=your-directory-tenant-id
   ```

### 4. Run the Application

```bash
npm run dev
```

Navigate to `http://localhost:3000` to see the application.

## Authentication Flow

1. Users are redirected to Azure login page
2. After successful authentication, they're redirected back to the app
3. The dashboard displays user information and provides logout functionality
4. All routes are protected and require authentication

## Customization

- Modify `components/dashboard/DashboardLayout.tsx` to change the dashboard layout
- Update `lib/auth-config.ts` to adjust MSAL configuration
- Add more protected routes by wrapping them with `<AuthGuard>`
- Use the `useApiClient` hook to make authenticated calls to your Azure Function Apps

## Azure Function App Integration

The application includes utilities to call Azure Function Apps with proper authentication:

### Using the API Client Hook

```typescript
import { useApiClient } from "@/lib/api-client";

function MyComponent() {
  const apiClient = useApiClient();

  const callMyFunction = async () => {
    try {
      const data = await apiClient.get("/api/my-function");
      console.log(data);
    } catch (error) {
      console.error("API call failed:", error);
    }
  };

  return <button onClick={callMyFunction}>Call Function</button>;
}
```

### Available Methods

- `apiClient.get(endpoint)` - GET request
- `apiClient.post(endpoint, data)` - POST request
- `apiClient.put(endpoint, data)` - PUT request
- `apiClient.delete(endpoint)` - DELETE request
- `apiClient.getAccessToken()` - Get raw access token
- `apiClient.apiCall(endpoint, options)` - Custom request with full control

## Deployment

For production deployment:

1. Update the redirect URI in Azure App Registration to your production URL
2. Update environment variables in your hosting platform
3. Build and deploy the application

## Troubleshooting

- Ensure your Azure app registration is configured correctly
- Check that environment variables are set properly
- Verify redirect URIs match between Azure and your application
- Check browser console for any MSAL errors
