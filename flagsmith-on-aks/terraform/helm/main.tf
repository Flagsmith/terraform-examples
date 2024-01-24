resource "helm_release" "ingress-nginx" {
  count           = 1
  name            = "flagsmith-ingress"
  namespace       = var.app_namespace
  chart           = "ingress-nginx"
  repository      = "https://kubernetes.github.io/ingress-nginx"
  version         = "4.1.3"
  timeout         = "600"
  max_history     = "5"
  cleanup_on_fail = "true"
  wait_for_jobs   = "true"

  values = [
    file("../helm/ingress-nginx-values.yaml"),
  ]
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-ipv4"
    value = var.load_balancer_ip
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = var.load_balancer_resource_group
  }
}

resource "helm_release" "flagsmith" {
  count           = 1
  name            = "flagsmith"
  namespace       = var.app_namespace
  chart           = "flagsmith/flagsmith"
  repository      = "flagsmith"
  timeout         = "600"
  max_history     = "5"
  cleanup_on_fail = "true"
  wait_for_jobs   = "true"

  values = [
    file("../helm/flagsmith-values.yaml"),
  ]

  set {
    name  = "databaseExternal.urlFromExistingSecret.name"
    value = var.db_secret_name
  }
  set {
    name  = "databaseExternal.urlFromExistingSecret.key"
    value = var.db_secret_key
  }
  set {
    name  = "api.image.repository"
    value = var.api_image_repository
  }
  set {
    name  = "api.image.tag"
    value = var.api_image_tag
  }
  set {
    name  = "api.extraEnvFromSecret.ANALYTICS_DATABASE_URL.secretName"
    value = var.db_analytics_secret_name
  }
  set {
    name  = "api.extraEnvFromSecret.ANALYTICS_DATABASE_URL.secretKey"
    value = var.db_analytics_secret_key
  }
  set {
    name  = "frontend.extraEnv.FLAGSMITH_ON_FLAGSMITH_API_URL"
    value = "https://${var.api_domain}/api/v1/"
  }
  set {
    name  = "ingress.api.annotations.cert-manager\\.io/cluster-issuer"
    value = var.cluster_issuer_name
  }
  set {
    name  = "ingress.api.hosts"
    value = [var.api_domain]
  }
  set {
    name  = "ingress.api.tls.hosts"
    value = [var.api_domain]
  }
  set {
    name  = "ingress.frontend.annotations.cert-manager\\.io/cluster-issuer"
    value = var.cluster_issuer_name
  }
  set {
    name  = "ingress.frontend.hosts"
    value = [var.frontend_domain]
  }
  set {
    name  = "ingress.frontend.tls.hosts"
    value = [var.frontend_domain]
  }

  depends_on = [helm_release.ingress-nginx]
}
