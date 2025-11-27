provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "${var.project_name}-rg"
  location = "eastus2"
}

data "azuread_service_principal" "current" {
  application_id = var.app_id
}

data "azurerm_subscription" "current" {}
