CST8918 - DevOps: Infrastructure as Code  
Prof. Robert McKenney

# Final Project: Terraform, Azure AKS, and GitHub Actions

## 5. Create Network Module in Terrafomr Infrastructure


This module is designed to provision and manage Azure networking resources such as Virtual Networks (VNets), Subnets, Network Security Groups (NSG), Public IPs, and Network Interfaces.

## Files Overview

### 1. Add `tf-app/modules/network/main.tf` file

This file contains the primary resource definitions for the Azure networking resources, including the Virtual Network (VNet), Subnets, Network Security Group (NSG), Public IP addresses, and Network Interfaces. The resources are deployed based on the configuration provided in the `variables.tf` file.

- **Virtual Network (VNet)**: Defines a VNet with a specific address space in the selected Azure region.
- **Subnets**: Creates multiple subnets within the VNet, such as Production, Test, Development, and Admin subnets.
- **Network Security Group (NSG)**: A security group with inbound rules (SSH on port 22 and HTTP on port 80).
- **Public IP**: A static public IP address for use with a Network Interface.
- **Network Interface (NIC)**: Associates the NIC with the VNet and subnet, along with public IP assignment.

```hcl
# Create a Virtual Network (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.label_prefix}-Vnet"
  address_space       = ["10.0.0.0/14"]
  location            = var.region
  resource_group_name = var.resource_group_name
}

# Create Production subnet
resource "azurerm_subnet" "prod" {
  name                 = "${var.label_prefix}-Subnet-Prod"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/16"]
}

# Create Test subnet
resource "azurerm_subnet" "test" {
  name                 = "${var.label_prefix}-Subnet-Test"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.0.0/16"]
}

# Create Development subnet
resource "azurerm_subnet" "dev" {
  name                 = "${var.label_prefix}-Subnet-Dev"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.2.0.0/16"]
}

# Create Admin subnet
resource "azurerm_subnet" "admin" {
  name                 = "${var.label_prefix}-Subnet-Admin"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.3.0.0/16"]
}

# Create a Network Security Group with rules for SSH and HTTP access
resource "azurerm_network_security_group" "webserver" {
  name                = "${var.label_prefix}-SG"
  location            = var.region
  resource_group_name = var.resource_group_name

  # Allow inbound SSH access on port 22
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow inbound HTTP access on port 80
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a static public IP address for the web server
resource "azurerm_public_ip" "webserver" {
  name                = "${var.label_prefix}-PublicIP"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

# Create a network interface and associate it with the production subnet and public IP
resource "azurerm_network_interface" "webserver" {
  name                = "${var.label_prefix}-Nic"
  location            = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.label_prefix}-NicConfig"
    subnet_id                     = azurerm_subnet.prod.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.10"
    public_ip_address_id          = azurerm_public_ip.webserver.id
  }

  # Ensures the NIC is created before being destroyed (useful for updates)
  lifecycle {
    create_before_destroy = true
  }
}

# Associate the Network Security Group with the NIC
resource "azurerm_network_interface_security_group_association" "webserver" {
  network_interface_id      = azurerm_network_interface.webserver.id
  network_security_group_id = azurerm_network_security_group.webserver.id
}
```


### 2. Add `tf-app/modules/network/variables.tf` file

This file defines the input variables for the module. These variables allow users to customize the module’s behavior and deployment.

- **`label_prefix`**: A string prefix used to create resource names. It ensures all resources are named consistently.
- **`region`**: The Azure region where the resources will be deployed. It defaults to `canadacentral`, but this can be overridden.
- **`resource_group_name`**: The name of the resource group in which to deploy the resources.

```hcl
# Prefix used to standardize naming across all Azure resources
variable "label_prefix" {
  description = "A short, descriptive prefix used to consistently name all resources created by this module."
  type        = string
}

# Azure region where all resources will be deployed
variable "region" {
  description = "The Azure region where the resources will be provisioned. Default is 'Canada Central'."
  type        = string
  default     = "canadacentral"
}

# Name of the Azure resource group that will contain the resources
variable "resource_group_name" {
  description = "The name of the existing Azure Resource Group in which all resources will be deployed."
  type        = string
}
```

### 3. Add `tf-app/modules/network/outputs.tf` file

This file defines the output values for the resources created by the module. These outputs provide the resource IDs and other important information for downstream usage.

- **`vnet_id`**: The ID of the Virtual Network (VNet) created.
- **`vnet_name`**: The name of the Virtual Network.
- **`prod_subnet_id`**, **`test_subnet_id`**, **`dev_subnet_id`**, **`admin_subnet_id`**: The IDs of the respective subnets (Production, Test, Development, and Admin).
- **`nsg_id`**: The ID of the Network Security Group associated with the web server.
- **`public_ip_id`**: The ID of the public IP address.
- **`public_ip_address`**: The actual public IP address.
- **`network_interface_id`**: The ID of the network interface created.

```hcl
output "vnet_id" {
  description = "The unique identifier (ID) of the Virtual Network (VNet)."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name assigned to the Virtual Network (VNet)."
  value       = azurerm_virtual_network.vnet.name
}

output "prod_subnet_id" {
  description = "The unique identifier (ID) of the Production subnet within the Virtual Network."
  value       = azurerm_subnet.prod.id
}

output "test_subnet_id" {
  description = "The unique identifier (ID) of the Test subnet within the Virtual Network."
  value       = azurerm_subnet.test.id
}

output "dev_subnet_id" {
  description = "The unique identifier (ID) of the Development subnet within the Virtual Network."
  value       = azurerm_subnet.dev.id
}

output "admin_subnet_id" {
  description = "The unique identifier (ID) of the Admin subnet within the Virtual Network."
  value       = azurerm_subnet.admin.id
}

output "nsg_id" {
  description = "The unique identifier (ID) of the Network Security Group (NSG) associated with the webserver."
  value       = azurerm_network_security_group.webserver.id
}

output "public_ip_id" {
  description = "The unique identifier (ID) of the Public IP resource assigned to the webserver."
  value       = azurerm_public_ip.webserver.id
}

output "public_ip_address" {
  description = "The actual Public IP address assigned to the webserver."
  value       = azurerm_public_ip.webserver.ip_address
}

output "network_interface_id" {
  description = "The unique identifier (ID) of the Network Interface Card (NIC) attached to the webserver."
  value       = azurerm_network_interface.webserver.id
}

```

### 4. Update main.tf to Include the Network Module

In your `tf-app/main.tf`, include the network module by referencing its location. 

```hcl
# Network Module
module "network" {
  source              = "./modules/network"
  label_prefix        = var.labelPrefix
  region              = var.region
  resource_group_name = azurerm_resource_group.rg.name
}
```

### 5. Update outputs.tf to Include the Network Module

In your `tf-app/outputs.tf`, include the network outputs. 

```hcl
# Outputs for Network module
output "public_ip" {
  value = module.network.public_ip_address
}

output "vnet_id" {
  value = module.network.vnet_id
}

output "vnet_name" {
  value = module.network.vnet_name
}

output "prod_subnet_id" {
  value = module.network.prod_subnet_id
}

output "test_subnet_id" {
  value = module.network.test_subnet_id
}

output "dev_subnet_id" {
  value = module.network.dev_subnet_id
}

output "admin_subnet_id" {
  value = module.network.admin_subnet_id
}
```

### 5. Apply module changes

```bash
terraform init
terraform validate
terraform plan -out=tf-app.plan
terraform apply tf-app.plan
```

---
