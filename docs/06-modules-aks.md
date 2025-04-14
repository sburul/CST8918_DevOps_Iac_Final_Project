CST8918 - DevOps: Infrastructure as Code  
Prof. Robert McKenney

# Final Project: Terraform, Azure AKS, and GitHub Actions

## 6. Create AKS Module in Terraform Infrastructure

This Terraform module provisions an Azure Kubernetes Service (AKS) cluster within a specified subnet and environment (`test` or `prod`). It supports automatic scaling, VM sizing, and Kubernetes version selection. This is the base infrastructure to deploy the Remix Weather Application.

---

## Files Overview

### 1. Add `tf-app/modules/aks/main.tf` file

This file contains the primary resource definitions for creating an AKS cluster.

- **AKS Cluster**: Provisions an AKS cluster based on the environment (`dev`, `test`, `prod`)
- **Node Pool**: Automatically configured with size, min/max node counts, and autoscaling if enabled
- **Network Profile**: Uses an existing subnet for AKS node integration

```hcl
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
```

---

### 2. Add `tf-app/modules/redis/variables.tf` file

This file defines the input variables for the module.

```hcl
variable "label_prefix" {
  type        = string
  description = "A short prefix used to consistently name and identify Azure resources related to the AKS deployment. Helps with resource organization and filtering."
}

variable "location" {
  type        = string
  description = "The Azure region where the AKS clusters will be deployed (e.g., canadacentral, eastus). This determines the physical location of the infrastructure."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the existing Azure Resource Group in which the AKS clusters and associated resources will be created."
}

variable "test_subnet_id" {
  type        = string
  description = "The ID of the subnet within a Virtual Network (VNet) that will be used for deploying the test AKS cluster. This subnet must exist prior to deployment."
}

variable "prod_subnet_id" {
  type        = string
  description = "The ID of the subnet within a Virtual Network (VNet) used by the production AKS cluster. It should be configured to support autoscaling and production workloads."
}

```


### 3. Add `tf-app/modules/aks/outputs.tf` file

This file defines the outputs of the AKS module for use in other modules or higher-level configuration.

```hcl
# Outputs for AKS Module
output "test_cluster_id" {
  description = "ID of the test AKS cluster"
  value       = azurerm_kubernetes_cluster.test.id
}

output "test_cluster_name" {
  description = "Name of the test AKS cluster"
  value       = azurerm_kubernetes_cluster.test.name
}

output "test_kube_config" {
  description = "Raw Kubernetes config for the test cluster"
  value       = azurerm_kubernetes_cluster.test.kube_config_raw
  sensitive   = true
}

output "test_kube_config_host" {
  description = "Host from kube_config for the test cluster"
  value       = azurerm_kubernetes_cluster.test.kube_config[0].host
}

output "test_kube_config_client_certificate" {
  description = "Client certificate from kube_config for the test cluster"
  value       = base64decode(azurerm_kubernetes_cluster.test.kube_config[0].client_certificate)
  sensitive   = true
}

output "test_kube_config_client_key" {
  description = "Client key from kube_config for the test cluster"
  value       = base64decode(azurerm_kubernetes_cluster.test.kube_config[0].client_key)
  sensitive   = true
}

output "test_kube_config_cluster_ca_certificate" {
  description = "Cluster CA certificate from kube_config for the test cluster"
  value       = base64decode(azurerm_kubernetes_cluster.test.kube_config[0].cluster_ca_certificate)
  sensitive   = true
}

output "prod_cluster_id" {
  description = "ID of the production AKS cluster"
  value       = azurerm_kubernetes_cluster.prod.id
}

output "prod_cluster_name" {
  description = "Name of the production AKS cluster"
  value       = azurerm_kubernetes_cluster.prod.name
}

output "prod_kube_config" {
  description = "Raw Kubernetes config for the production cluster"
  value       = azurerm_kubernetes_cluster.prod.kube_config_raw
  sensitive   = true
}

output "prod_kube_config_host" {
  description = "Host from kube_config for the production cluster"
  value       = azurerm_kubernetes_cluster.prod.kube_config[0].host
}

output "prod_kube_config_client_certificate" {
  description = "Client certificate from kube_config for the production cluster"
  value       = base64decode(azurerm_kubernetes_cluster.prod.kube_config[0].client_certificate)
  sensitive   = true
}

output "prod_kube_config_client_key" {
  description = "Client key from kube_config for the production cluster"
  value       = base64decode(azurerm_kubernetes_cluster.prod.kube_config[0].client_key)
  sensitive   = true
}

output "prod_kube_config_cluster_ca_certificate" {
  description = "Cluster CA certificate from kube_config for the production cluster"
  value       = base64decode(azurerm_kubernetes_cluster.prod.kube_config[0].cluster_ca_certificate)
  sensitive   = true
}

output "test_cluster_principal_id" {
  description = "The principal ID of the test AKS cluster's managed identity"
  value       = azurerm_kubernetes_cluster.test.identity[0].principal_id
}

output "prod_cluster_principal_id" {
  description = "The principal ID of the production AKS cluster's managed identity"
  value       = azurerm_kubernetes_cluster.prod.identity[0].principal_id
}

```

---

### 4. Update `tf-app/main.tf` to Include the AKS Module

```hcl
# AKS Module
module "aks" {
  source              = "./modules/aks"
  label_prefix        = var.labelPrefix
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  test_subnet_id      = module.network.test_subnet_id
  prod_subnet_id      = module.network.prod_subnet_id
}
```

---

### 5. Add outputs to `tf-app/outputs.tf`

```hcl
# Outputs for AKS Module
output "test_cluster_id" {
  description = "ID of the test AKS cluster"
  value       = module.aks.test_cluster_id
}

output "test_cluster_name" {
  description = "Name of the test AKS cluster"
  value       = module.aks.test_cluster_name
}

output "test_kube_config" {
  description = "Kubeconfig for the test AKS cluster"
  value       = module.aks.test_kube_config
  sensitive   = true
}

output "prod_cluster_id" {
  description = "ID of the production AKS cluster"
  value       = module.aks.prod_cluster_id
}

output "prod_cluster_name" {
  description = "Name of the production AKS cluster"
  value       = module.aks.prod_cluster_name
}

output "prod_kube_config" {
  description = "Kubeconfig for the production AKS cluster"
  value       = module.aks.prod_kube_config
  sensitive   = true
}


```

---

### 6. Apply module changes

```bash
terraform init
terraform validate
terraform plan -out=tf-app.plan
terraform apply tf-app.plan
```

---
