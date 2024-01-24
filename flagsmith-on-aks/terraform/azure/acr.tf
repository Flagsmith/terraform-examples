resource "azurerm_container_registry" "default" {
  name                = var.project_name
  sku                 = "Standard"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}
