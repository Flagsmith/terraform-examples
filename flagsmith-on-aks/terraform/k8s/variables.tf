variable "db_host" {
  description = "PostgreSQL host"
}

variable "db_admin_dsn" {
  description = "PostgreSQL admin DSN"
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

variable "sendgrid_api_key" {
  description = "Sendgrid API key"
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
