
# Outputs Container Registry
output "acr_login_server" {
  description = "The login server URL for the Azure Container Registry (ACR)"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Admin username for authenticating with Azure Container Registry (ACR)"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  description = "Admin password for ACR (sensitive data)"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

# Test Environment Outputs

output "test_deployment_name" {
  description = "Name of the Kubernetes deployment in the test environment"
  value       = kubernetes_deployment.remix_weather_app_test.metadata[0].name
}

output "test_service_name" {
  description = "Name of the Kubernetes service in the test environment"
  value       = kubernetes_service.remix_weather_app_test.metadata[0].name
}

output "test_service_endpoint" {
  description = "Internal IP address of the Kubernetes service in the test environment"
  value       = kubernetes_service.remix_weather_app_test.spec[0].cluster_ip
}

# Production Environment Outputs

output "prod_deployment_name" {
  description = "Name of the Kubernetes deployment in the production environment"
  value       = kubernetes_deployment.remix_weather_app_prod.metadata[0].name
}

output "prod_service_name" {
  description = "Name of the Kubernetes service in the production environment"
  value       = kubernetes_service.remix_weather_app_prod.metadata[0].name
}

output "prod_service_endpoint" {
  description = "External IP address of the Kubernetes service in the production environment"
  value       = kubernetes_service.remix_weather_app_prod.status[0].load_balancer[0].ingress[0].ip
}
