# Cluster basics
variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = null
}

# Default node pool
variable "default_node_pool_name" {
  description = "Name of the default node pool"
  type        = string
  default     = "default"
}

variable "default_node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "default_node_vm_size" {
  description = "VM size for default node pool"
  type        = string
  default     = "Standard_D2_v2"
}

variable "default_node_os_disk_size" {
  description = "OS disk size for default node pool (in GB)"
  type        = number
  default     = 30
}

# Autoscaling
variable "enable_auto_scaling" {
  description = "Enable autoscaling for default node pool"
  type        = bool
  default     = false
}

variable "min_node_count" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 5
}

# Network
variable "subnet_id" {
  description = "ID of the subnet where AKS will be deployed"
  type        = string
}

variable "network_plugin" {
  description = "Network plugin to use for Kubernetes network"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy to use for Kubernetes network"
  type        = string
  default     = "calico"
}

variable "service_cidr" {
  description = "CIDR block for Kubernetes service"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address for Kubernetes DNS service"
  type        = string
  default     = "10.0.0.10"
}

variable "docker_bridge_cidr" {
  description = "CIDR block for Docker bridge network"
  type        = string
  default     = "172.17.0.1/16"
}


# Additional node pools
variable "additional_node_pools" {
  description = "List of additional node pools to be created"
  type = list(object({
    name                = string
    vm_size             = string
    node_count          = number
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    os_disk_size_gb     = number
    node_labels         = map(string)
    node_taints         = list(string)
  }))
  default = []
}

variable application_gateway_id{}

# Monitoring
variable "enable_monitoring" {
  description = "Enable Azure Monitor for containers"
  type        = bool
  default     = false
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}