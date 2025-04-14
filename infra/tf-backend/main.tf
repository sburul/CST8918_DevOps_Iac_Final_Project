terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}
  subscription_id = "286a69d3-dc09-45e3-b4a1-1b7dc9a02f90"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "cst8918-final-project-group-2-backend-rg"
  location = "canadacentral"
}

# Storage Account Info
resource "azurerm_storage_account" "storage" {
  name                     = "cst8918storageaccountgr2"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

# Storage Account Container
resource "azurerm_storage_container" "container" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}