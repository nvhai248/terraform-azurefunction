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

  import {
    # If you have swagger/json spec for function
    # change to link swagger. if you don't have,
    # you can create it using OpenAPI or mock
    content_format = "openapi-link"
    content_value  = "https://${var.function_app_url}/api/swagger.json"
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
    <validate-jwt header-name="Authorization" failed-validation-httpcode="401" require-scheme="Bearer">
      <openid-config url="https://login.microsoftonline.com/${var.tenant_id}/v2.0/.well-known/openid-configuration" />
      <required-claims>
        <claim name="aud" match="any">
          <value>api://${var.api_app_client_id}</value>
        </claim>
      </required-claims>
    </validate-jwt>
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
</policies>
XML

  depends_on = [azurerm_api_management_api.function_api]
}
