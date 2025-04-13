output "zipkin_url" {
  value = azurerm_container_app.services["zipkin"].latest_revision_fqdn
}

output "redis_url" {
  value = azurerm_container_app.services["redis"].latest_revision_fqdn
}

output "frontend_url" {
  value = azurerm_container_app.services["frontend"].latest_revision_fqdn
}