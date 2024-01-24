terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.10.1"
    }
  }

  required_version = ">=1.0"
}
