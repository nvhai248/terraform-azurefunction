module "azure_function" {
  source               = "./modules/azure-function"
  resource_group_name  = "microleaf-test-hai"
  function_name        = "microleaffunc"
  location             = "Southeast Asia"
  app_service_plan_sku = "FC1"
  runtime              = "node"
  runtime_version      = "22"
}

module "azure_function_dotnet" {
  source               = "./modules/azure-function"
  resource_group_name  = "microleaf-dotnet-rg"
  function_name        = "microleafdotnetfunc"
  location             = "Southeast Asia"
  app_service_plan_sku = "FC1"
  runtime              = "dotnet-isolated"
  runtime_version      = "8.0"
}

module "azure_ad" {
  source = "./modules/azure-ad"

  app_display_name = "tf-external-id-google-app"
}

module "apim" {
  source              = "./modules/apim"
  function_name       = module.azure_function.function_app_name
  api_app_client_id   = module.azure_ad.app_client_id
  resource_group_name = module.azure_function.resource_group_name
  location            = module.azure_function.location
  function_app_url    = module.azure_function.function_app_url
  tenant_id           = data.azurerm_client_config.current.tenant_id
  function_key        = module.azure_function.default_function_key
  build_id            = var.build_id
}

data "azurerm_client_config" "current" {}
