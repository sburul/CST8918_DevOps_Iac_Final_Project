# Outputs for AKS Module
output "test_cluster_id" {
  description = "ID of the test AKS cluster"
  value       = azurerm_kubernetes_cluster.test.id
}

output "test_cluster_name" {
  description = "Name of the test AKS cluster"
  value       = azurerm_kubernetes_cluster.test.name
}

output "test_kube_config" {
  description = "Raw Kubernetes config for the test cluster"
  value       = azurerm_kubernetes_cluster.test.kube_config_raw
  sensitive   = true
}

output "test_kube_config_host" {
  description = "Host from kube_config for the test cluster"
  value       = azurerm_kubernetes_cluster.test.kube_config[0].host
}

output "test_kube_config_client_certificate" {
  description = "Client certificate from kube_config for the test cluster"
  value       = base64decode(azurerm_kubernetes_cluster.test.kube_config[0].client_certificate)
  sensitive   = true
}

output "test_kube_config_client_key" {
  description = "Client key from kube_config for the test cluster"
  value       = base64decode(azurerm_kubernetes_cluster.test.kube_config[0].client_key)
  sensitive   = true
}

output "test_kube_config_cluster_ca_certificate" {
  description = "Cluster CA certificate from kube_config for the test cluster"
  value       = base64decode(azurerm_kubernetes_cluster.test.kube_config[0].cluster_ca_certificate)
  sensitive   = true
}

output "prod_cluster_id" {
  description = "ID of the production AKS cluster"
  value       = azurerm_kubernetes_cluster.prod.id
}

output "prod_cluster_name" {
  description = "Name of the production AKS cluster"
  value       = azurerm_kubernetes_cluster.prod.name
}

output "prod_kube_config" {
  description = "Raw Kubernetes config for the production cluster"
  value       = azurerm_kubernetes_cluster.prod.kube_config_raw
  sensitive   = true
}

output "prod_kube_config_host" {
  description = "Host from kube_config for the production cluster"
  value       = azurerm_kubernetes_cluster.prod.kube_config[0].host
}

output "prod_kube_config_client_certificate" {
  description = "Client certificate from kube_config for the production cluster"
  value       = base64decode(azurerm_kubernetes_cluster.prod.kube_config[0].client_certificate)
  sensitive   = true
}

output "prod_kube_config_client_key" {
  description = "Client key from kube_config for the production cluster"
  value       = base64decode(azurerm_kubernetes_cluster.prod.kube_config[0].client_key)
  sensitive   = true
}

output "prod_kube_config_cluster_ca_certificate" {
  description = "Cluster CA certificate from kube_config for the production cluster"
  value       = base64decode(azurerm_kubernetes_cluster.prod.kube_config[0].cluster_ca_certificate)
  sensitive   = true
}

output "test_cluster_principal_id" {
  description = "The principal ID of the test AKS cluster's managed identity"
  value       = azurerm_kubernetes_cluster.test.identity[0].principal_id
}

output "prod_cluster_principal_id" {
  description = "The principal ID of the production AKS cluster's managed identity"
  value       = azurerm_kubernetes_cluster.prod.identity[0].principal_id
}
