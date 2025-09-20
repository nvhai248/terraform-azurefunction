output "function_app_name" {
  value = azurerm_function_app_flex_consumption.function.name
}

output "function_app_url" {
  value = azurerm_function_app_flex_consumption.function.default_hostname
}

output "resource_group_name" {
  value = var.resource_group_name
}

output "location" {
  value = var.location
}

output "default_function_key" {
  value     = data.azurerm_function_app_host_keys.function_keys.default_function_key
  sensitive = true
}
