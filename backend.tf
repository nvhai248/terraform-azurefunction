terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "microtfstatestorage"
    container_name       = "microtfstate"
    key                  = "terraform.tfstate"
  }
}
