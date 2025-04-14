# Create resource group for all resources
resource "azurerm_resource_group" "rg" {
  name     = "${var.labelPrefix}-rg"
  location = var.region
}

# Network Module
module "network" {
  source              = "./modules/network"
  label_prefix        = var.labelPrefix
  region              = var.region
  resource_group_name = azurerm_resource_group.rg.name
}
# AKS Module
module "aks" {
  source              = "./modules/aks"
  label_prefix        = var.labelPrefix
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  test_subnet_id      = module.network.test_subnet_id
  prod_subnet_id      = module.network.prod_subnet_id
}
# Redis Cache Module
module "redis" {
  source              = "./modules/redis_cache"
  label_prefix        = var.labelPrefix
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

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