locals {
  flagsmith_api_docker_repository = "flagsmith/flagsmith-private-cloud"
  flagsmith_api_version           = "2.64.0"
}

provider "azurerm" {
  features {}
}

# Azure module creates:
# - Azure virtual network
# - PostgreSQL Flexible server and database, its subnet and security group
# - AKS cluster and its subnet
module "azure" {
  source = "./azure"

  project_name      = var.project_name
  app_id            = var.app_id
  password          = var.password
  db_admin_username = var.db_admin_username
  db_admin_password = var.db_admin_password
}

# Reload cluster state to ensure that subsequent modules work correctly, see
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources
data "azurerm_kubernetes_cluster" "default" {
  depends_on          = [module.azure]
  name                = module.azure.aks_cluster_name
  resource_group_name = module.azure.resource_group_name
}


# Connect the Terraform k8s provider to the AKS cluster. 
provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
}


# k8s module creates: 
# - Database user for the Flagsmith backend
# - Kubernetes secret with the database connection string
# - Kubernetes namespace for the app deployment
module "k8s" {
  source = "./k8s"

  db_admin_dsn               = module.azure.db_admin_dsn
  db_host                    = module.azure.db_host
  db_user_username           = var.db_user_username
  db_user_password           = var.db_user_password
  db_analytics_user_username = var.db_analytics_user_username
  db_analytics_user_password = var.db_analytics_user_password

  sendgrid_api_key               = var.sendgrid_api_key
  flagsmith_django_secret_key    = var.flagsmith_django_secret_key
  flagsmith_on_flagsmith_api_key = var.flagsmith_on_flagsmith_api_key
}

# Connect the kubectl provider to the AKS cluster. This is required for cert-manager.
provider "kubectl" {
  host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
}

# Install cert-manager CRDs.
module "cert_manager" {
  source  = "terraform-iaac/cert-manager/kubernetes"
  version = "~> 2.5.1"

  cluster_issuer_email                   = "matthew.elwell@flagsmith.com"
  cluster_issuer_name                    = "cert-manager-global"
  cluster_issuer_private_key_secret_name = "cert-manager-private-key"
}

# Connect the Terraform Helm provider to the AKS cluster. 
provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
  }
}

# Install Flagsmith.
module "helm" {
  source = "./helm"

  api_domain                   = var.api_domain
  frontend_domain              = var.frontend_domain
  app_namespace                = module.k8s.app_namespace
  db_secret_name               = module.k8s.db_secret_name
  db_secret_key                = module.k8s.db_secret_key
  db_analytics_secret_name     = module.k8s.db_secret_name
  db_analytics_secret_key      = module.k8s.db_analytics_secret_key
  load_balancer_ip             = module.azure.public_ip
  load_balancer_resource_group = module.azure.resource_group_name
  cluster_issuer_name          = "cert-manager-global"
  api_image_repository         = "${module.azure.acr_url}/${local.flagsmith_api_docker_repository}"
  api_image_tag                = local.flagsmith_api_version
}
