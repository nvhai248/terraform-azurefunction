data "azurerm_client_config" "current" {}

data "azurerm_function_app_host_keys" "function_keys" {
  name                = azurerm_function_app_flex_consumption.function.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_function_app_flex_consumption.function]
}
