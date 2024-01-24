# Assign a Network Contributor role for binding the load balancer to a static public IP.  
resource "azurerm_role_assignment" "service_principal__default__network_contributor" {
  principal_id         = data.azuread_service_principal.current.object_id
  role_definition_name = "Network Contributor"
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.default.name}"
}

# Assign an ACRPull role for the cluster to pull application images.
resource "azurerm_role_assignment" "service_principal__default__acrpull" {
  principal_id         = data.azuread_service_principal.current.object_id
  role_definition_name = "AcrPull"
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.default.name}/providers/Microsoft.ContainerRegistry/registries/${azurerm_container_registry.default.name}"
}
