variable "build_id" {
  description = "Build id from CI/CD pipeline used to bust cache for APIM swagger import"
  type        = string
  default     = "local" # fallback for local apply
}

# variable "subscription_id" {}
# variable "tenant_id" {}
# variable "client_id" {}
# variable "client_secret" {}
