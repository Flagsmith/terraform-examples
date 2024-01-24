variable "project_name" {
  description = "Project name, e.g. `\"myflagsmith\"`. Will be used as a prefix for created resource names."
}

variable "frontend_domain" {
  description = "Domain for the Flagsmith app"
}

variable "api_domain" {
  description = "Domain for the Flagsmith API"
}

variable "app_id" {
  description = "Azure Kubernetes Service Cluster service principal"
  sensitive   = true
}

variable "password" {
  description = "Azure Kubernetes Service Cluster password"
  sensitive   = true
}

variable "server_app_id" {
  description = "Azure Kubernetes Service Cluster server app ID"
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Kubernetes Service Cluster tenant ID"
  sensitive   = true
}

variable "db_admin_username" {
  description = "Azure PosgreSQL server admin username"
  sensitive   = true
}

variable "db_admin_password" {
  description = "Azure PosgreSQL server admin password"
  sensitive   = true
}

variable "db_user_username" {
  description = "PosgreSQL application user username"
  sensitive   = true
}

variable "db_user_password" {
  description = "PosgreSQL application user password"
  sensitive   = true
}

variable "db_analytics_user_username" {
  description = "PosgreSQL analytics user username"
  sensitive   = true
}

variable "db_analytics_user_password" {
  description = "PosgreSQL analytics user password"
  sensitive   = true
}

variable "flagsmith_django_secret_key" {
  description = "Flagsmith's Django secret key"
  sensitive   = true
}

variable "flagsmith_on_flagsmith_api_key" {
  description = "Flagsmith-on-Flagsmith environment key"
  sensitive   = true
}

variable "sendgrid_api_key" {
  description = "Sendgrid API key"
  sensitive   = true
}
