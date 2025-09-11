variable "resource_group_name" {}
variable "location" { default = "Southeast Asia" }
variable "function_name" {}
variable "app_service_plan_sku" { default = "Y1" }
variable "runtime" { default = "python" }
variable "runtime_version" { default = "3.11" }
