variable "project_name" {
  description = "Project name, e.g. `\"myflagsmith\"`. Will be used as a prefix for created resource names."
}

variable "app_id" {
  description = "Azure Kubernetes Service Cluster service principal"
  sensitive   = true
}

variable "password" {
  description = "Azure Kubernetes Service Cluster password"
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
