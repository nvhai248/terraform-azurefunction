# 1. App Registration
resource "azuread_application" "app_registration" {
  display_name = var.app_display_name

  web {
    redirect_uris = ["http://localhost:3000/api/auth/callback/azure-ad"]
  }

  # API Permissions for Microsoft Graph
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "741f803b-c850-494e-b5df-cde7c675a1ca" # User.ReadWrite.All (Delegated)
      type = "Scope"
    }
  }
}

# 2. Service Principal (represents the app in the tenant)
resource "azuread_service_principal" "app_registration_sp" {
  client_id = azuread_application.app_registration.client_id
}

# Follow: https://learn.microsoft.com/en-us/entra/external-id/google-federation to set up Google federation.
