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
