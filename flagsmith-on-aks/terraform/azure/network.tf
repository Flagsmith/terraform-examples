# Azure virtual network for all ClarusONE resources.
resource "azurerm_virtual_network" "default" {
  name                = "${var.project_name}-vnet"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.30.0.0/16"]
}

# A subnet for Kubernetes.
resource "azurerm_subnet" "aks" {
  name                 = "${var.project_name}-aks-subnet"
  virtual_network_name = azurerm_virtual_network.default.name
  resource_group_name  = azurerm_resource_group.default.name
  address_prefixes     = ["10.30.1.0/24"]
}

# Flexible Server PostgreSQL requires a dedicated subnet.
resource "azurerm_subnet" "db" {
  name                 = "${var.project_name}-db-subnet"
  virtual_network_name = azurerm_virtual_network.default.name
  resource_group_name  = azurerm_resource_group.default.name
  address_prefixes     = ["10.30.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# Security group for the PosgreSQL subnet.
resource "azurerm_network_security_group" "db" {
  name                = "${var.project_name}-nsg"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  # Allow PostgreSQL connections from the Kubernetes subnet.
  security_rule {
    name                       = "AllowPostgesConnections"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = azurerm_subnet.aks.address_prefixes[0]
    destination_address_prefix = azurerm_subnet.db.address_prefixes[0]
  }
}

# Tie the group to the PostgreSQL subnet.
resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.db.id
}

# Add a PostgreSQL internal domain name to DNS.
resource "azurerm_private_dns_zone" "db" {
  name                = "${var.project_name}-pdz.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.default.name

  depends_on = [azurerm_subnet_network_security_group_association.db]
}

# Enable the PostgreSQL domain resolution in the virtual network.
resource "azurerm_private_dns_zone_virtual_network_link" "db" {
  name                  = "${var.project_name}-pdzvnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.db.name
  virtual_network_id    = azurerm_virtual_network.default.id
  resource_group_name   = azurerm_resource_group.default.name
}

resource "azurerm_public_ip" "default" {
  name                = "${var.project_name}-public-ip"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
