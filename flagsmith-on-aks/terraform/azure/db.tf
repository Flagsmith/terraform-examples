resource "azurerm_postgresql_flexible_server" "db" {
  name                   = "${var.project_name}-db-server"
  resource_group_name    = azurerm_resource_group.default.name
  location               = azurerm_resource_group.default.location
  version                = "11"
  delegated_subnet_id    = azurerm_subnet.db.id
  private_dns_zone_id    = azurerm_private_dns_zone.db.id
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "MO_Standard_E4ds_v4"
  backup_retention_days  = 35

  depends_on = [azurerm_private_dns_zone_virtual_network_link.db]
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = "flagsmith"
  server_id = azurerm_postgresql_flexible_server.db.id
  collation = "en_US.UTF8"
  charset   = "UTF8"
}

resource "azurerm_postgresql_flexible_server_database" "analytics_db" {
  name      = "flagsmith_analytics"
  server_id = azurerm_postgresql_flexible_server.db.id
  collation = "en_US.UTF8"
  charset   = "UTF8"
}
