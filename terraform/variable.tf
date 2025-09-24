variable "build_id" {
  description = "Build id from CI/CD pipeline used to bust cache for APIM swagger import"
  type        = string
  default     = "local" # fallback for local apply
}
