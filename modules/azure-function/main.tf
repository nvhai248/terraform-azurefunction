# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Storage Account
resource "azurerm_storage_account" "sa" {
  name                     = "${var.function_name}sa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# App Service Plan
resource "azurerm_service_plan" "plan" {
  name                = "${var.function_name}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = var.app_service_plan_sku
}

# Application Insights
resource "azurerm_application_insights" "app" {
  name                = "${var.function_name}-ai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                       = "${var.function_name}-kv"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}

# Container
resource "azurerm_storage_container" "container" {
  name                  = "${var.function_name}container"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

# Function App
resource "azurerm_linux_function_app" "function" {
  name                       = var.function_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key

  site_config {
    application_stack {
      python_version = var.runtime_version
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.app.instrumentation_key
    "STORAGE_CONTAINER_NAME"         = azurerm_storage_container.container.name
    "STORAGE_ACCOUNT_NAME"           = azurerm_storage_account.sa.name
  }
}

data "azurerm_client_config" "current" {}
