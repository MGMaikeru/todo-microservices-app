variable "resource_group_name" {
  type    = string
  default = "microservices_rg"
}

variable "microservices_location" {
  type        = string
  description = "Ubicación de Azure"
  default     = "East US"
}

variable "microservices_log_analytics_name" {
  type        = string
  description = "Nombre del workspace de Log Analytics"
  default     = "microservices-log"
}

variable "microservices_container_env_name" {
  type        = string
  description = "Nombre del entorno de Azure Container Apps"
  default     = "microservices-env"
}

variable "subscription_id" {
  type      = string
  sensitive = true
}