resource "azurerm_public_ip" "appgw_pip" {
  name                = "appgw-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "appgateway"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }
  frontend_port {
    name = var.frontend_port_name
    port = 80
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "http-rule"
    rule_type                  = "Basic"
    priority                   = 1
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
  }

  probe {
    name                = "health-probe"
    protocol            = "Http"
    host                = "localhost"
    path                = "/"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }
}


output "appgw_public_ip" {
  value = azurerm_public_ip.appgw_pip.ip_address
}

output "backend_pool_id" {
  value = [for pool in azurerm_application_gateway.appgw.backend_address_pool : pool.id if pool.name == "backend-pool"][0]
}

output "health_probe_id" {
  value = [for probe in azurerm_application_gateway.appgw.probe : probe.id][0]
}