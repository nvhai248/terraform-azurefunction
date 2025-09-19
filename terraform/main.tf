module "azure_function" {
  source               = "./modules/azure-function"
  resource_group_name  = "microleaf-test-hai"
  function_name        = "microleaffunc"
  location             = "Southeast Asia"
  app_service_plan_sku = "FC1"
  runtime              = "node"
  runtime_version      = "22"
}

module "apim" {
  source              = "./modules/apim"
  function_name       = module.azure_function.function_app_name
  api_app_client_id   = "fe4c4971-249d-4fc8-bc38-2500ffa92816"
  resource_group_name = module.azure_function.resource_group_name
  location            = module.azure_function.location
  function_app_url    = module.azure_function.function_app_url
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

data "azurerm_client_config" "current" {}
