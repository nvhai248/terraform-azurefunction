output "app_client_id" {
  value = azuread_application.app_registration.client_id
}

output "app_object_id" {
  value = azuread_application.app_registration.object_id
}
