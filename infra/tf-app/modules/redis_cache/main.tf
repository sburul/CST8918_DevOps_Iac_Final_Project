terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.25.0" # Specifies the Azure RM provider version
    }
  }
}

# Define Azure Redis Cache for Test environment
resource "azurerm_redis_cache" "redis_test" {
  name                          = lower("redis-${var.label_prefix}-test") # Redis Cache name (prefix + label + test)
  resource_group_name           = var.resource_group_name                 # Name of the resource group where Redis will be deployed
  location                      = var.location                            # Azure region where Redis will be deployed
  capacity                      = 1                                       # Redis capacity (valid values are 0-6 for Basic/Standard SKU, 1-5 for Premium SKU)
  family                        = "C"                                     # SKU family: C (Basic/Standard)
  sku_name                      = "Basic"                                 # SKU type: Basic
  non_ssl_port_enabled          = false                                   # Disable non-SSL port
  minimum_tls_version           = "1.2"                                   # Minimum TLS version: 1.2
  public_network_access_enabled = var.redis_public_network_access_enabled # Whether public network access is allowed

  redis_configuration {
    authentication_enabled = var.redis_enable_authentication # Enable Redis authentication
  }
}

# Define Azure Redis Cache for Production environment
resource "azurerm_redis_cache" "redis_prod" {
  name                          = lower("redis-${var.label_prefix}-prod") # Redis Cache name (prefix + label + prod)
  resource_group_name           = var.resource_group_name                 # Name of the resource group where Redis will be deployed
  location                      = var.location                            # Azure region where Redis will be deployed
  capacity                      = 1                                       # Redis capacity (valid values are 0-6 for Basic/Standard SKU, 1-5 for Premium SKU)
  family                        = "C"                                     # SKU family: C (Basic/Standard)
  sku_name                      = "Basic"                                 # SKU type: Basic
  non_ssl_port_enabled          = false                                   # Disable non-SSL port
  minimum_tls_version           = "1.2"                                   # Minimum TLS version: 1.2
  public_network_access_enabled = var.redis_public_network_access_enabled # Whether public network access is allowed

  redis_configuration {
    authentication_enabled = var.redis_enable_authentication # Enable Redis authentication
  }
}

# Create Azure Private DNS Zone for Redis
resource "azurerm_private_dns_zone" "pdz_redis" {
  name                = "privatelink.redis.cache.windows.net" # Private DNS zone name for Redis
  resource_group_name = var.resource_group_name               # Resource group for the DNS zone
}

# Create a link between the Private DNS Zone and VNet
resource "azurerm_private_dns_zone_virtual_network_link" "redis_pdz_vnet_link" {
  name                  = "privatelink_to_${var.vnet_name}"       # Name of the link between the VNet and the DNS zone
  resource_group_name   = var.resource_group_name                 # Resource group for the DNS zone
  virtual_network_id    = var.vnet_id                             # VNet ID for the link
  private_dns_zone_name = azurerm_private_dns_zone.pdz_redis.name # Name of the DNS zone to link
}

# Create a Private Endpoint for Azure Redis Cache in the Test environment
resource "azurerm_private_endpoint" "pe_redis_test" {
  name                = lower("${var.private_endpoint_prefix}-${azurerm_redis_cache.redis_test.name}") # Private Endpoint name
  location            = azurerm_redis_cache.redis_test.location                                        # Location of the Redis test environment
  resource_group_name = azurerm_redis_cache.redis_test.resource_group_name                             # Resource group for the Redis test environment
  subnet_id           = var.subnet_id_test                                                             # Subnet ID for the test environment's private endpoint

  private_service_connection {
    name                           = "pe-${azurerm_redis_cache.redis_test.name}" # Name of the private service connection
    private_connection_resource_id = azurerm_redis_cache.redis_test.id           # Redis Cache resource ID
    is_manual_connection           = false                                       # Whether the connection is manual
    subresource_names              = ["redisCache"]                              # Subresource to connect to (Redis cache)
    request_message                = try(var.request_message, null)              # Optional message for connection request
  }

  private_dns_zone_group {
    name                 = "default"                               # DNS zone group name
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
  location            = azurerm_redis_cache.redis_prod.location                                        # Location of the Redis production environment
  resource_group_name = azurerm_redis_cache.redis_prod.resource_group_name                             # Resource group for the Redis production environment
  subnet_id           = var.subnet_id_prod                                                             # Subnet ID for the production environment's private endpoint

  private_service_connection {
    name                           = "pe-${azurerm_redis_cache.redis_prod.name}" # Name of the private service connection
    private_connection_resource_id = azurerm_redis_cache.redis_prod.id           # Redis Cache resource ID
    is_manual_connection           = false                                       # Whether the connection is manual
    subresource_names              = ["redisCache"]                              # Subresource to connect to (Redis cache)
    request_message                = try(var.request_message, null)              # Optional message for connection request
  }

  private_dns_zone_group {
    name                 = "default"                               # DNS zone group name
    private_dns_zone_ids = [azurerm_private_dns_zone.pdz_redis.id] # Private DNS zone ID
  }

  depends_on = [
    azurerm_redis_cache.redis_prod,
    azurerm_private_dns_zone.pdz_redis
  ]
}
