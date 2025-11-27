output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.default.name
}

output "resource_group_name" {
  value = azurerm_resource_group.default.name
}

output "db_host" {
  value = azurerm_postgresql_flexible_server.db.fqdn
}

output "db_admin_dsn" {
  value     = "postgresql://${var.db_admin_username}:${urlencode(var.db_admin_password)}@${azurerm_postgresql_flexible_server.db.fqdn}:5432/postgres"
  sensitive = true
}

output "public_ip" {
  value = azurerm_public_ip.default.ip_address
}

output "acr_url" {
  value = azurerm_container_registry.default.login_server
}
