variable "resource_group_name" {
  type        = string
  default     = "rg-one"
  description = "Name of the resource group."
}
variable "location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}
variable "vnet_name" {}
variable "vmss_name" {}
variable "frontend_port_name" {}
variable "instance_count" {}
variable "admin_username" {
  sensitive = true
}
variable "admin_password" {
  sensitive = true
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
variable "vm_size" {
  description = "Size of the Virtual Machines in the Scale Set"
  type        = string
  default     = "Standard_F2"
}
