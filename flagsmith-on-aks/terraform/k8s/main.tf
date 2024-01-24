# "terraform" namespace holds database admin secrets and a job that creates
# the Flagsmith database-scoped user.  
resource "kubernetes_namespace" "tf" {
  metadata {
    name = "terraform"
  }
}

# "flagsmith" namespace is used for the Helm deployment. It holds
# the application-specic database secret.
resource "kubernetes_namespace" "flagsmith" {
  metadata {
    name = "flagsmith"
  }
}
