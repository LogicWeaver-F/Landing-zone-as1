# Application Gateway Outputs
output "application_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.app_gateway_pip.ip_address
}

output "application_gateway_fqdn" {
  description = "Fully qualified domain name of the Application Gateway"
  value       = azurerm_public_ip.app_gateway_pip.fqdn
}

# VMSS Outputs
output "vmss_id" {
  description = "The ID of the Virtual Machine Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.landing_zone.id
}

output "vmss_resource_group" {
  description = "The resource group of the Virtual Machine Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.landing_zone.resource_group_name
}

# Network Outputs
output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.landing_zone.id
}

output "subnet_id" {
  description = "The ID of the VMSS Subnet"
  value       = azurerm_subnet.vmss_subnet.id
}