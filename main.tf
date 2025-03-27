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

  depends_on = [module.networking, module.security, module.loadbalancer]
}