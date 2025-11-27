resource "azurerm_kubernetes_cluster" "default" {
  name                = "${var.project_name}-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${var.project_name}-k8s"

  default_node_pool {
    name                        = "default"
    vnet_subnet_id              = azurerm_subnet.aks.id
    node_count                  = 2
    vm_size                     = "standard_b2ms"
    os_disk_size_gb             = 30
    temporary_name_for_rotation = "defaulttemp"
  }

  service_principal {
    client_id     = var.app_id
    client_secret = var.password
  }

  network_profile {
    network_plugin = "kubenet"

    load_balancer_profile {
      outbound_ip_address_ids = [azurerm_public_ip.default.id]
    }
  }

  role_based_access_control_enabled = true

  depends_on = [azurerm_subnet.aks, azurerm_public_ip.default]
}
