module "azure_function" {
  source               = "./modules/azure-function"
  resource_group_name  = "microleaf-test-hai"
  function_name        = "microleaffunc"
  location             = "Southeast Asia"
  app_service_plan_sku = "FC1"
  runtime              = "node"
  runtime_version      = "22"
}
