# Create resource group for all resources
resource "azurerm_resource_group" "rg" {
  name     = "${var.labelPrefix}-rg"
  location = var.region
}