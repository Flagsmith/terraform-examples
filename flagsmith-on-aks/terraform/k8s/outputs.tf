output "db_secret_name" {
  value = kubernetes_secret.db_app.metadata.0.name
}

output "db_secret_key" {
  value     = "app_database_dsn"
  sensitive = true
}

output "db_analytics_secret_key" {
  value     = "analytics_database_dsn"
  sensitive = true
}

output "app_namespace" {
  value = kubernetes_namespace.flagsmith.metadata.0.name
}
