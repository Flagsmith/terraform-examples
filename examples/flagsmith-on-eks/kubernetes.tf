provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
    command     = "aws"
  }
}

resource "kubernetes_secret" "flagsmith_db" {
  metadata {
    name = "flagsmith-db"
  }

  data = {
    url = join("", [
      "postgresql://${aws_db_instance.flagsmith_db.username}:${var.db_password}",
      "@${aws_db_instance.flagsmith_db.address}:${aws_db_instance.flagsmith_db.port}",
      "/${aws_db_instance.flagsmith_db.db_name}"
    ])
  }
}

data "kubernetes_service" "flagsmith_frontend" {
  depends_on = [helm_release.flagsmith]
  metadata {
    name = "${helm_release.flagsmith.name}-frontend"
  }
}

data "kubernetes_service" "flagsmith_api" {
  depends_on = [helm_release.flagsmith]
  metadata {
    name = "${helm_release.flagsmith.name}-api"
  }
}
