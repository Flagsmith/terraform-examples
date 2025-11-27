terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.41"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.16.0"
    }
  }

  required_version = ">=1.0"
}
