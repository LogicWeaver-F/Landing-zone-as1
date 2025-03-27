variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "landing-zone-rg"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "vmss_subnet_prefix" {
  description = "Subnet address prefix for VMSS"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "admin_username" {
  description = "Administrator username for VMs"
  type        = string
}

variable "admin_password" {
  description = "Administrator password for VMs"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Size of the Virtual Machines in the Scale Set"
  type        = string
  default     = "Standard_F2"
}

variable "vm_instances" {
  description = "Number of VM instances in the Scale Set"
  type        = number
  default     = 4
}

variable "os_image_publisher" {
  description = "Publisher of the OS image"
  type        = string
  default     = "Canonical"
}

variable "os_image_offer" {
  description = "Offer of the OS image"
  type        = string
  default     = "UbuntuServer"
}

variable "os_image_sku" {
  description = "SKU of the OS image"
  type        = string
  default     = "18.04-LTS"
}

variable "os_image_version" {
  description = "Version of the OS image"
  type        = string
  default     = "latest"
}