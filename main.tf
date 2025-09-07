module "azure_function" {
  source               = "./modules/azure-function"
  resource_group_name  = "microleaf-test-hai"
  function_name        = "microleaffunc"
  location             = "Southeast Asia"
  app_service_plan_sku = "FC1"
  runtime              = "python"
  runtime_version      = "3.12"
}
