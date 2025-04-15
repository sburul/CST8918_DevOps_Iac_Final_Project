terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    required_version = ">= 1.0.0"
  }
}

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
