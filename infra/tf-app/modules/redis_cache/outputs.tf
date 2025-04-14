# Outputs for Redis Cache Module
output "private_endpoint_test_id" {
  description = "ID of the private endpoint for the Redis Cache in the test environment."
  value       = azurerm_private_endpoint.pe_redis_test.id
}

output "private_endpoint_prod_id" {
  description = "ID of the private endpoint for the Redis Cache in the production environment."
  value       = azurerm_private_endpoint.pe_redis_prod.id
}

output "test_redis_host" {
  description = "Hostname of the Redis Cache in the test environment."
  value       = azurerm_redis_cache.redis_test.hostname
}

output "test_redis_ssl_port" {
  description = "SSL port for the Redis Cache in the test environment."
  value       = azurerm_redis_cache.redis_test.ssl_port
}

output "test_redis_primary_key" {
  description = "Primary access key for the Redis Cache in the test environment."
  value       = azurerm_redis_cache.redis_test.primary_access_key
  sensitive   = true
}

output "prod_redis_host" {
  description = "Hostname of the Redis Cache in the production environment."
  value       = azurerm_redis_cache.redis_prod.hostname
}

output "prod_redis_ssl_port" {
  description = "SSL port for the Redis Cache in the production environment."
  value       = azurerm_redis_cache.redis_prod.ssl_port
}

output "prod_redis_primary_key" {
  description = "Primary access key for the Redis Cache in the production environment."
  value       = azurerm_redis_cache.redis_prod.primary_access_key
  sensitive   = true
}

output "test_redis_name" {
  description = "Name of the Redis Cache in the test environment."
  value       = azurerm_redis_cache.redis_test.name
}

output "prod_redis_name" {
  description = "Name of the Redis Cache in the production environment."
  value       = azurerm_redis_cache.redis_prod.name
}
