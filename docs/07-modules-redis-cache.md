CST8918 - DevOps: Infrastructure as Code  
Prof. Robert McKenney

# Final Project: Terraform, Azure AKS, and GitHub Actions

# 7. Create Redis Cache Module in Terraform Infrastructure

This Terraform module provisions an Azure Redis Cache instance. It supports configuration for the **test** and **prod** environments, with the ability to set the **size** of the Redis Cache, **SKU**, and **replica settings**. This is part of the infrastructure that supports the Remix Weather Application by providing caching services.

---

## Files Overview

### 1. Add `tf-app/modules/redis_cache/main.tf` file

This file contains the primary resource definitions for creating a Redis Cache instance in Azure.

- **Redis Cache Instance**: Provisions a Redis Cache instance with a specified SKU, size, and replication settings based on the environment (`test` or `prod`).
- **Firewall Rules**: Defines IP ranges allowed to connect to the Redis instance.
- **Identity and Replication**: Configures access control and replication settings for high availability.

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.25.0"  # Specifies the Azure RM provider version
    }
  }
}

# Define Azure Redis Cache for Test environment
resource "azurerm_redis_cache" "redis_test" {
  name                          = lower("redis-${var.label_prefix}-test") # Redis Cache name (prefix + label + test)
  resource_group_name           = var.resource_group_name # Name of the resource group where Redis will be deployed
  location                      = var.location # Azure region where Redis will be deployed
  capacity                      = 1 # Redis capacity (valid values are 0-6 for Basic/Standard SKU, 1-5 for Premium SKU)
  family                        = "C" # SKU family: C (Basic/Standard)
  sku_name                      = "Basic" # SKU type: Basic
  non_ssl_port_enabled          = false # Disable non-SSL port
  minimum_tls_version           = "1.2" # Minimum TLS version: 1.2
  public_network_access_enabled = var.redis_public_network_access_enabled # Whether public network access is allowed

  redis_configuration {
    authentication_enabled = var.redis_enable_authentication # Enable Redis authentication
  }
}

# Define Azure Redis Cache for Production environment
resource "azurerm_redis_cache" "redis_prod" {
  name                          = lower("redis-${var.label_prefix}-prod") # Redis Cache name (prefix + label + prod)
  resource_group_name           = var.resource_group_name # Name of the resource group where Redis will be deployed
  location                      = var.location # Azure region where Redis will be deployed
  capacity                      = 1 # Redis capacity (valid values are 0-6 for Basic/Standard SKU, 1-5 for Premium SKU)
  family                        = "C" # SKU family: C (Basic/Standard)
  sku_name                      = "Basic" # SKU type: Basic
  non_ssl_port_enabled          = false # Disable non-SSL port
  minimum_tls_version           = "1.2" # Minimum TLS version: 1.2
  public_network_access_enabled = var.redis_public_network_access_enabled # Whether public network access is allowed

  redis_configuration {
    authentication_enabled = var.redis_enable_authentication # Enable Redis authentication
  }
}

# Create Azure Private DNS Zone for Redis
resource "azurerm_private_dns_zone" "pdz_redis" {
  name                = "privatelink.redis.cache.windows.net" # Private DNS zone name for Redis
  resource_group_name = var.resource_group_name # Resource group for the DNS zone
}

# Create a link between the Private DNS Zone and VNet
resource "azurerm_private_dns_zone_virtual_network_link" "redis_pdz_vnet_link" {
  name                  = "privatelink_to_${var.vnet_name}" # Name of the link between the VNet and the DNS zone
  resource_group_name   = var.resource_group_name # Resource group for the DNS zone
  virtual_network_id    = var.vnet_id # VNet ID for the link
  private_dns_zone_name = azurerm_private_dns_zone.pdz_redis.name # Name of the DNS zone to link
}

# Create a Private Endpoint for Azure Redis Cache in the Test environment
resource "azurerm_private_endpoint" "pe_redis_test" {
  name                = lower("${var.private_endpoint_prefix}-${azurerm_redis_cache.redis_test.name}") # Private Endpoint name
  location            = azurerm_redis_cache.redis_test.location # Location of the Redis test environment
  resource_group_name = azurerm_redis_cache.redis_test.resource_group_name # Resource group for the Redis test environment
  subnet_id           = var.subnet_id_test # Subnet ID for the test environment's private endpoint

  private_service_connection {
    name                           = "pe-${azurerm_redis_cache.redis_test.name}" # Name of the private service connection
    private_connection_resource_id = azurerm_redis_cache.redis_test.id # Redis Cache resource ID
    is_manual_connection           = false # Whether the connection is manual
    subresource_names              = ["redisCache"] # Subresource to connect to (Redis cache)
    request_message                = try(var.request_message, null) # Optional message for connection request
  }

  private_dns_zone_group {
    name                 = "default" # DNS zone group name
    private_dns_zone_ids = [azurerm_private_dns_zone.pdz_redis.id] # Private DNS zone ID
  }

  depends_on = [
    azurerm_redis_cache.redis_test,
    azurerm_private_dns_zone.pdz_redis
  ]
}

# Create a Private Endpoint for Azure Redis Cache in the Production environment
resource "azurerm_private_endpoint" "pe_redis_prod" {
  name                = lower("${var.private_endpoint_prefix}-${azurerm_redis_cache.redis_prod.name}") # Private Endpoint name
  location            = azurerm_redis_cache.redis_prod.location # Location of the Redis production environment
  resource_group_name = azurerm_redis_cache.redis_prod.resource_group_name # Resource group for the Redis production environment
  subnet_id           = var.subnet_id_prod # Subnet ID for the production environment's private endpoint

  private_service_connection {
    name                           = "pe-${azurerm_redis_cache.redis_prod.name}" # Name of the private service connection
    private_connection_resource_id = azurerm_redis_cache.redis_prod.id # Redis Cache resource ID
    is_manual_connection           = false # Whether the connection is manual
    subresource_names              = ["redisCache"] # Subresource to connect to (Redis cache)
    request_message                = try(var.request_message, null) # Optional message for connection request
  }

  private_dns_zone_group {
    name                 = "default" # DNS zone group name
    private_dns_zone_ids = [azurerm_private_dns_zone.pdz_redis.id] # Private DNS zone ID
  }

  depends_on = [
    azurerm_redis_cache.redis_prod,
    azurerm_private_dns_zone.pdz_redis
  ]
}

```

---

### 2. Add `tf-app/modules/redis_cache/variables.tf` file

This file defines the input variables for the Redis Cache module.

```hcl
variable "label_prefix" {
  type        = string
  description = "A short prefix used to consistently name and identify Azure resources related to the Redis Cache deployment. Helps with resource organization and filtering."
}

variable "location" {
  type        = string
  description = "The Azure region where the Redis Cache instances will be deployed (e.g., canadacentral, eastus). This determines the physical location of the infrastructure."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the existing Azure Resource Group in which the Redis Cache instances will be created."
}
```

---

### 3. Add `tf-app/modules/redis_cache/outputs.tf` file

This file defines the outputs for the Redis Cache module for use in other modules or higher-level configurations.

```hcl
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

```

---

### 4. Update `tf-app/main.tf` to Include the Redis Cache Module

```hcl
# Redis Cache Module
module "redis" {
  source              = "./modules/redis_cache"
  label_prefix        = var.labelPrefix
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  redis_cache_prefix  = "weather"
  # Default values from existing module
  redis_cache_sku                     = "Basic"
  redis_cache_family                  = "C"
  redis_cache_capacity_test           = 0
  redis_cache_capacity_prod           = 1
  redis_public_network_access_enabled = true
  redis_enable_authentication         = true
  vnet_id                             = module.network.vnet_id
  vnet_name                           = module.network.vnet_name
  subnet_id_test                      = module.network.test_subnet_id
  subnet_id_prod                      = module.network.prod_subnet_id
}
```

---

### 5. Add Outputs to `tf-app/outputs.tf`

```hcl
# Outputs for Redis Cache Module
output "test_redis_cache_id" {
  description = "ID of the test Redis Cache instance"
  value       = module.redis.test_redis_cache_id
}

output "test_redis_cache_name" {
  description = "Name of the test Redis Cache instance"
  value       = module.redis.test_redis_cache_name
}

output "test_redis_cache_host" {
  description = "Host for the test Redis Cache instance"
  value       = module.redis.test_redis_cache_host
}

output "prod_redis_cache_id" {
  description = "ID of the production Redis Cache instance"
  value       = module.redis.prod_redis_cache_id
}

output "prod_redis_cache_name" {
  description = "Name of the production Redis Cache instance"
  value       = module.redis.prod_redis_cache_name
}

output "prod_redis_cache_host" {
  description = "Host for the production Redis Cache instance"
  value       = module.redis.prod_redis_cache_host
}
```

---

### 6. Apply Module Changes

```bash
terraform init
terraform validate
terraform plan -out=tf-app.plan
terraform apply tf-app.plan
```

---