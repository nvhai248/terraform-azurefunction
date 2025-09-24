# API Management Instance
resource "azurerm_api_management" "apim" {
  name                = "${var.function_name}-apim"
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = "Microleaf"
  publisher_email     = "admin@microleaf.com"
  sku_name            = "Developer_1"
}

# Import Function API to APIM
resource "azurerm_api_management_api" "function_api" {
  name                = "${var.function_name}-api"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Function API"
  path                = "functions"
  protocols           = ["https"]
  service_url         = "https://${var.function_app_url}/api"

  import {
    # If you have swagger/json spec for function
    # change to link swagger. if you don't have,
    # you can create it using OpenAPI or mock
    content_format = "openapi-link"
    content_value  = "https://${var.function_app_url}/api/swagger.json?rev=${var.build_id}"
  }

  depends_on = [azurerm_api_management.apim]
}

# JWT Validation Policy
resource "azurerm_api_management_api_policy" "jwt_policy" {
  api_name            = azurerm_api_management_api.function_api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name

  xml_content = <<XML
<policies>
    <inbound>
        <base />
        <validate-azure-ad-token tenant-id="${var.tenant_id}" require-scheme="Bearer" header-name="Authorization" output-token-variable-name="jwt">
            <audiences>
                <audience>https://graph.microsoft.com</audience>
            </audiences>
            <client-application-ids>
                <application-id>${var.api_app_client_id}</application-id>
            </client-application-ids>
        </validate-azure-ad-token>
        <set-backend-service base-url="https://${var.function_app_url}" />
        <set-header name="x-functions-key" exists-action="override">
            <value>${var.function_key}</value>
        </set-header>
    </inbound>
    <backend>
        <forward-request />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
XML

  depends_on = [azurerm_api_management_api.function_api]
}

resource "azurerm_api_management_backend" "function_backend" {
  name                = "${var.function_name}-backend"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  protocol            = "http"
  url                 = "https://${var.function_app_url}"
  description         = "Backend for Azure Function"

  # Nếu Function yêu cầu Function Key
  credentials {
    header = {
      "x-functions-key" = var.function_key
    }
  }

  depends_on = [azurerm_api_management.apim]
}
