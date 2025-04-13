provider "azurerm" {
  features {}
  subscription_id = var.microservices_subscription_id
}

resource "azurerm_resource_group" "microservices_rg" {
  name     = var.microservices_resource_group_name
  location = var.microservices_location
}

resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = var.microservices_log_analytics_name
  location            = azurerm_resource_group.microservices_rg.location
  resource_group_name = azurerm_resource_group.microservices_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "microservices_env" {
  name                       = var.microservices_container_env_name
  location                   = azurerm_resource_group.microservices_rg.location
  resource_group_name        = azurerm_resource_group.microservices_rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id
}

locals {
  services = {
    users-api             = { port = 3000, image = "mag1305/users-api:latest" }
    todos-api             = { port = 3001, image = "mag1305/todos-api:latest" }
    log-message-processor = { port = 3002, image = "mag1305/log-message-processor:latest" }
    auth-api              = { port = 3003, image = "mag1305/auth-api:latest" }
    zipkin                = { port = 9411, image = "openzipkin/zipkin:latest" }
    redis                 = { port = 6379, image = "redis:alpine" }
  }
}

resource "azurerm_container_app" "services" {
  for_each                      = local.services
  name                          = each.key
  container_app_environment_id = azurerm_container_app_environment.microservices_env.id
  resource_group_name           = azurerm_resource_group.microservices_rg.name
  location                      = azurerm_resource_group.microservices_rg.location
  revision_mode                 = "Single"

  template {
    container {
      name   = each.key
      image  = each.value.image
      cpu    = 0.25
      memory = "0.5Gi"

      ports {
        port = each.value.port
      }
    }

    ingress {
      external_enabled = true
      target_port      = each.value.port
      transport        = "auto"
    }
  }
}
