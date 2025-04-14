terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Test Cluster (1 node)
resource "azurerm_kubernetes_cluster" "test" {
  name                = "${var.label_prefix}-aks-test"
  location            = var.location
  resource_group_name = var.resource_group_name
  node_resource_group = "${var.label_prefix}-aks-nodes-test"
  kubernetes_version  = "1.32.0"
  dns_prefix          = "${var.label_prefix}-aks-test"

  default_node_pool {
    name           = "testnp"
    node_count     = 1
    vm_size        = "Standard_B2s"
    vnet_subnet_id = var.test_subnet_id
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "172.16.0.0/16" # Different range from VNet
    dns_service_ip = "172.16.0.10"   # Must be within service_cidr
  }

  identity {
    type = "SystemAssigned"
  }
}

# Prod Cluster (autoscale - 1 to 3 nodes)
resource "azurerm_kubernetes_cluster" "prod" {
  name                = "${var.label_prefix}-aks-prod"
  location            = var.location
  resource_group_name = var.resource_group_name
  node_resource_group = "${var.label_prefix}-aks-nodes-prod"
  kubernetes_version  = "1.32.0"
  dns_prefix          = "${var.label_prefix}-aks-prod"

  default_node_pool {
    name                 = "prodnp"
    vm_size              = "Standard_B2s"
    vnet_subnet_id       = var.prod_subnet_id
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 3
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "172.16.0.0/16" # Different range from VNet
    dns_service_ip = "172.16.0.10"   # Must be within service_cidr
  }

  identity {
    type = "SystemAssigned"
  }
}