variable "api_app_client_id" {
  description = "Azure AD App Registration client id cho API (audience)."
  type        = string
}

variable "function_name" {}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Location"
}

variable "function_app_url" {
  description = "The URL of the Azure Function App"
  type        = string
  default     = "microleaffunc.azurewebsites.net"
}

variable "tenant_id" {
  description = "The Azure AD tenant ID"
  type        = string
}
