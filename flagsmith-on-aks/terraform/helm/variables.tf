variable "app_namespace" {
  description = "Application namespace name"
}

variable "db_secret_name" {
  description = "PostgreSQL application database secret name"
  sensitive   = true
}

variable "db_secret_key" {
  description = "PostgreSQL application database secret key"
  sensitive   = true
}

variable "db_analytics_secret_name" {
  description = "PostgreSQL analytics database secret name"
  sensitive   = true
}

variable "db_analytics_secret_key" {
  description = "PostgreSQL analytics database secret key"
  sensitive   = true
}

variable "load_balancer_ip" {
  description = "An external IP for the load balancer"
}

variable "load_balancer_resource_group" {
  description = "Azure resource group name for the load balancer"
}

variable "cluster_issuer_name" {
  description = "Name of cert-manager cluster issuer"
}

variable "api_image_repository" {
  description = "Flagsmith Helm Chart's `api.image.repository` value"
}

variable "api_image_tag" {
  description = "Flagsmith Helm Chart's `api.image.tag` value"
}

variable "frontend_domain" {
  description = "Domain for the Flagsmith app"
}

variable "api_domain" {
  description = "Domain for the Flagsmith API"
}
