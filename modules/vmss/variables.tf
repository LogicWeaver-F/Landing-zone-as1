variable "resource_group_name" {}
variable "location" {}
variable "vnet_name" {}
variable "vmss_name" {}
variable "admin_username" {
  sensitive = true
}
variable "admin_password" {
  sensitive = true
}
variable "backend_pool_id" {}
variable "subnet_id" {}
variable "instance_count" {}
variable "health_probe_id" {}