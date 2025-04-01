resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = var.vnet_name
}

module "security" {
  source              = "./modules/security"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  subnet_id           = module.networking.subnet_id

  depends_on = [module.networking]
}

module "loadbalancer" {
  source              = "./modules/loadbalancer"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  subnet_id           = module.networking.subnet_id_appgw
  vnet_name           = var.vnet_name
  frontend_port_name  = var.frontend_port_name 

  depends_on = [module.networking, module.security]
}

module "vmss" {
  source              = "./modules/vmss"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vmss_name           = var.vmss_name
  vnet_name           = var.vnet_name
  instance_count      = var.instance_count
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  subnet_id           = module.networking.subnet_id
  backend_pool_id     = module.loadbalancer.backend_pool_id
  health_probe_id     = module.loadbalancer.health_probe_id
  os_image_offer      = var.os_image_offer
  os_image_publisher  = var.os_image_publisher
  os_image_sku        = var.os_image_sku
  os_image_version    = var.os_image_version
  vm_size             = var.vm_size

  depends_on = [module.networking, module.security, module.loadbalancer]
}

module "aks" {
  source = "./modules/aks"  # Path to the module directory

  # Pass variables from terraform.tfvars
  cluster_name        = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  # Node pool configuration
  default_node_pool_name    = var.default_node_pool_name
  default_node_count        = var.default_node_count
  default_node_vm_size      = var.default_node_vm_size
  default_node_os_disk_size = var.default_node_os_disk_size
  
  # Autoscaling
  enable_auto_scaling = var.enable_auto_scaling
  min_node_count      = var.min_node_count
  max_node_count      = var.max_node_count
  
  # Network configuration
  subnet_id          = module.networking.subnet_id
  network_plugin     = var.network_plugin
  network_policy     = var.network_policy
  service_cidr       = var.service_cidr
  dns_service_ip     = var.dns_service_ip
  docker_bridge_cidr = var.docker_bridge_cidr
  
  
  # Additional node pools
  additional_node_pools = var.additional_node_pools
  
  application_gateway_id = module.loadbalancer.application_gateway_id

  # Tags
  tags = var.tags
}

# Output the kubeconfig
output "kube_config" {
  value     = module.aks.kube_config
  sensitive = true
}