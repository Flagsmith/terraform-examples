provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}

resource "helm_release" "flagsmith" {
  depends_on = [aws_db_instance.flagsmith_db, kubernetes_secret.flagsmith_db]

  name       = "flagsmith"
  repository = "https://flagsmith.github.io/flagsmith-charts"
  chart      = "flagsmith"

  values = [
    file("${path.module}/flagsmith-values.yaml")
  ]
}
