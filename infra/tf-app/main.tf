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