# Resource Group
resource "azurerm_resource_group" "landing_zone" {
  name     = var.resource_group_name
  location = var.location

  tags = var.common_tags
  lifecycle {
    prevent_destroy = true
  }
}

# Virtual Network
resource "azurerm_virtual_network" "landing_zone" {
  name                = "${var.resource_group_name}-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name

  tags = var.common_tags
  lifecycle {
    prevent_destroy = true
  }
}

# Subnet for VMs
resource "azurerm_subnet" "vmss_subnet" {
  name                 = "${var.resource_group_name}-vmss-subnet"
  resource_group_name  = azurerm_resource_group.landing_zone.name
  virtual_network_name = azurerm_virtual_network.landing_zone.name
  address_prefixes     = var.vmss_subnet_prefix
}

# Network Security Group
resource "azurerm_network_security_group" "vmss_nsg" {
  name                = "${var.resource_group_name}-nsg"
  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name

  tags = var.common_tags

  lifecycle {
    prevent_destroy = true
  }

  # Inbound Security Rules
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # SSH Access Rule
  security_rule {
    name                       = "AllowSSH"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Subnet NSG Association
resource "azurerm_subnet_network_security_group_association" "vmss_nsg_association" {
  subnet_id                 = azurerm_subnet.vmss_subnet.id
  network_security_group_id = azurerm_network_security_group.vmss_nsg.id
}

# Public IP for Application Gateway
resource "azurerm_public_ip" "app_gateway_pip" {
  name                = "${var.resource_group_name}-app-gateway-pip"
  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.common_tags
}

# Subnet for Application Gateway
resource "azurerm_subnet" "app_gateway_subnet" {
  name                 = "${var.resource_group_name}-appgw-subnet"
  resource_group_name  = azurerm_resource_group.landing_zone.name
  virtual_network_name = azurerm_virtual_network.landing_zone.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Application Gateway
resource "azurerm_application_gateway" "landing_zone" {
  name                = "${var.resource_group_name}-appgateway"
  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name

  tags = var.common_tags

  lifecycle {
    create_before_destroy = true
  }

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.app_gateway_subnet.id
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.app_gateway_pip.id
  }

  frontend_port {
    name = "frontend-port"
    port = 80
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
  }
}

# Virtual Machine Scale Set
resource "azurerm_linux_virtual_machine_scale_set" "landing_zone" {
  name                = "${var.resource_group_name}-vmss"
  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name

  tags = var.common_tags

  lifecycle {
    create_before_destroy = true
  }

  sku                 = var.vm_size
  instances           = var.vm_instances

  source_image_reference {
    publisher = var.os_image_publisher
    offer     = var.os_image_offer
    sku       = var.os_image_sku
    version   = var.os_image_version
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.vmss_subnet.id
      application_gateway_backend_address_pool_ids = toset([for pool in azurerm_application_gateway.landing_zone.backend_address_pool : pool.id if pool.name == "backend-pool"])
    }
  }

  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "Landing Zone VMSS Instance" > /var/www/html/index.html
  EOF
  )
}
