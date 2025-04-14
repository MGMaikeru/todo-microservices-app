provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "microservices_rg" {
  name     = var.resource_group_name
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
    frontend              = { port = 80, image = "mag1305/frontend:latest" }
    users-api             = { port = 8080, image = "mag1305/users-api:latest" }
    todos-api             = { port = 8082, image = "mag1305/todos-api:latest" }
    log-message-processor = { port = 6379, image = "mag1305/log-message-processor:latest" }
    auth-api              = { port = 8000, image = "mag1305/auth-api:latest" }
    zipkin                = { port = 9411, image = "openzipkin/zipkin:latest" }
    redis                 = { port = 6380, image = "redis:alpine" }
  }
}

resource "azurerm_container_app" "services" {
  for_each                     = local.services
  name                         = each.key
  container_app_environment_id = azurerm_container_app_environment.microservices_env.id
  resource_group_name          = azurerm_resource_group.microservices_rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = each.key
      image  = each.value.image
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "AUTH_API_PORT"
        value = "8000"
      }

      env {
        name  = "USERS_API_ADDRESS"
        value = "https://${azurerm_container_app.services["users-api"].ingress[0].fqdn}"
      }

      env {
        name = "JWT_SECRET"
        value = "PRTF"
      }

      env {
        name  = "ZIPKIN_URL"
        value = "https://${azurerm_container_app.services["zipkin"].ingress[0].fqdn}"
      }

      env {
        name  = "SERVER_PORT"
        value = "8080"
      }

      env {
        name  = "spring.zipkin.baseUrl"
        value = "https://${azurerm_container_app.services["zipkin"].ingress[0].fqdn}"
      }

      env {
        name  = "TODO_API_PORT"
        value = "8082"
      }

      env {
        name  = "REDIS_PORT"
        value = "6380"
      }

      env {
        name  = "REDIS_HOST"
        value = "https://${azurerm_container_app.services["redis"].ingress[0].fqdn}"
      }

      env {
        name  = "REDIS_CHANNEL"
        value = "log_channel"
      }

      env {
        name  = "PORT"
        value = "80"
      }

      env {
        name  = "AUTH_API_ADDRESS"
        value = "https://${azurerm_container_app.services["auth-api"].ingress[0].fqdn}"
      }

      env {
        name  = "TODOS_API_ADDRESS"
        value = "https://${azurerm_container_app.services["todos-api"].ingress[0].fqdn}"
      }
    }
  }
}
