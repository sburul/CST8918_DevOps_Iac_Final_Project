# Configure the Terraform runtime requirements.
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    # Azure Resource Manager provider and version
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.6"
    }
  }

}

# Define providers and their config params
provider "azurerm" {
  # Leave the features block empty to accept all defaults
  features {
    # resource_group {
    #   prevent_deletion_if_contains_resources = false
    # }
  }
  subscription_id = "286a69d3-dc09-45e3-b4a1-1b7dc9a02f90"
  use_oidc        = true

}

provider "cloudinit" {
  # Configuration options
}