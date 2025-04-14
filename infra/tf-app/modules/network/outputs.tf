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

