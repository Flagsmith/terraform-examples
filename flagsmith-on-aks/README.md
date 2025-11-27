# Flagsmith AKS + Helm Terraform module

## Prerequisites

### Tools

Install the prerequisites:

```sh
brew update && brew install azure-cli kubernetes-cli helm terraform
```

Authorize your Azure CLI:

```sh
az login
```

## Deployment

### Inputs

Use the following `terraform.tfvars` file:

```terraform
project_name                   = myflagsmith                 # Or your own suitable project name
api_domain                     = flagsmith.mycompany.com     # Domain for the Flagsmith API
frontend_domain                = api.flagsmith.mycompany.com # Domain for the Flagsmith app
app_id                         = "***"  # Azure Service Principal Application ID
db_admin_password              = "***"  # PostgreSQL master user password
db_admin_username              = "***"  # PostgreSQL master user username
db_analytics_user_password     = "***"  # PostgreSQL analytics database password
db_analytics_user_username     = "***"  # PostgreSQL analytics database username
db_user_password               = "***"  # PostgreSQL application database password
db_user_username               = "***"  # PostgreSQL application database username
docker_hub_token               = "***"  # Docker Hub token for a user with private access to flagsmith-private-cloud image
docker_hub_user                = "***"  # Docker Hub username for a user with private access to flagsmith-private-cloud image
flagsmith_django_secret_key    = "***"  # Flagsmith application's Django secret key. *Be sure not to change it to avoid data loss*.
flagsmith_on_flagsmith_api_key = "***"  # Key for the Flagsmith-on-Flagsmith environment.
password                       = "***"  # Azure Service Principal Application password
sendgrid_api_key               = "***"  # Sendgrind API key
server_app_id                  = "6dae42f8-4368-4678-94ff-3960e28e3630"  # (Static value) Azure Service Principal Application ID
tenant_id                      = "***"  # Azure Service Principal Tenant ID
```

### AKS Cluster

Deploy the container registry, AKS cluster, database, role assignments and network configuration (`azure` submodule):

```sh
terraform apply -target module.azure
```

### Flagsmith private Docker image

Import the Flagsmith Private Cloud image:

```sh
az acr import \
    --name myflagsmith \  # `project_name` from tfvars
    --source docker.io/flagsmith/flagsmith-private-cloud:2.63.0 \
    --image flagsmith/flagsmith-private-cloud:2.63.0 \
    --username $DOCKER_USER \
    --password $DOCKER_TOKEN
```

### Kubernetes and Helm release

Deploy the following:
 - `k8s` submodule: Kubernetes secrets, namespaces, database users (`k8s` submodule);
 - `cert_manager` third-party module: cert-manager CRDs;
 - `helm` submodule: NGINX Ingress CRD and Flagsmith Helm release.

After you have your cluster ready, all of these are installed with a simple

```sh
terraform apply
```

## Update Flagsmith version

1. In [terraform/main.tf](terraform/main.tf), edit the `flagsmith_api_version` local variable, e.g.:
```diff
    locals {
        flagsmith_api_docker_repository = "flagsmith/flagsmith-private-cloud"
+        flagsmith_api_version           = "3.0.0"
-        flagsmith_api_version           = "2.64.0"
    }
```
2. Change the frontend version in [helm/flagsmith-values.yaml](helm/flagsmith-values.yaml):
```diff
frontend:
  image:
+    tag: 3.0.0
-    tag: 2.64.0
```
3. Import the correct API image to the Container Registry:
```sh
az acr import \
    --name <your project name> \
    --source docker.io/flagsmith/flagsmith-private-cloud:3.0.0 \
    --image flagsmith/flagsmith-private-cloud:3.0.0 \
    --username $DOCKER_USER \
    --password $DOCKER_TOKEN
```
4. Apply the Terraform configuration to install the new Helm release:
```sh
terraform apply
```

## Configuration

Static Helm values are stored in [helm/flagsmith-values.yaml](helm/flagsmith-values.yaml).

Notable values:

- `api.replicacount` — used to scale the API containers.

Helm values dependent on Terraform state are set in [terraform/helm/main.tf](terraform/helm/main.tf).
