output "flagsmith_frontend_endpoint" {
  value       = "http://${data.kubernetes_service.flagsmith_frontend.status[0].load_balancer[0].ingress[0].hostname}"
  description = "Flagsmith's UI endpoint."
}

output "flagsmith_api_endpoint" {
  value       = "http://${data.kubernetes_service.flagsmith_api.status[0].load_balancer[0].ingress[0].hostname}/api/v1/"
  description = "Flagsmith's API endpoint."
}
