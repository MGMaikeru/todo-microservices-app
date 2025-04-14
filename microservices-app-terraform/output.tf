output "zipkin_url" {
  value = azurerm_container_app.zipkin.latest_revision_fqdn
}

output "redis_url" {
  value = azurerm_container_app.redis.latest_revision_fqdn
}

output "frontend_url" {
  value = azurerm_container_app.frontend.latest_revision_fqdn
}