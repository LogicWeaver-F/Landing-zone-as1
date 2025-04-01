resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = var.default_node_pool_name
    node_count          = var.default_node_count
    vm_size             = var.default_node_vm_size
    os_disk_size_gb     = var.default_node_os_disk_size
    vnet_subnet_id      = var.subnet_id
    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.enable_auto_scaling ? var.min_node_count : null
    max_count           = var.enable_auto_scaling ? var.max_node_count : null
    type                = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    load_balancer_sku  = "standard"
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
  }

  ingress_application_gateway {
    gateway_id = var.application_gateway_id
  }

  tags = var.tags
}

# Additional node pool (optional)
resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  count                 = length(var.additional_node_pools)
  
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  name                  = var.additional_node_pools[count.index].name
  vm_size               = var.additional_node_pools[count.index].vm_size
  node_count            = var.additional_node_pools[count.index].node_count
  enable_auto_scaling   = var.additional_node_pools[count.index].enable_auto_scaling
  min_count             = var.additional_node_pools[count.index].enable_auto_scaling ? var.additional_node_pools[count.index].min_count : null
  max_count             = var.additional_node_pools[count.index].enable_auto_scaling ? var.additional_node_pools[count.index].max_count : null
  os_disk_size_gb       = var.additional_node_pools[count.index].os_disk_size_gb
  node_labels           = var.additional_node_pools[count.index].node_labels
  node_taints           = var.additional_node_pools[count.index].node_taints
}