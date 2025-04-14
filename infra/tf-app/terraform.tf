terraform {
  required_version = ">= 1.0.0"

  backend "azurerm" {
    resource_group_name  = "cst8918-final-project-group-2-backend-rg"
    storage_account_name = "cst8918storageaccountgr2"
    container_name       = "tfstate"
    key                  = "prod.app.tfstate"
    use_oidc             = true
    subscription_id      = "286a69d3-dc09-45e3-b4a1-1b7dc9a02f90"
  }
} 