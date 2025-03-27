resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.vmss_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard_F2"
  instances           = var.instance_count
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  upgrade_mode        = "Rolling"
  health_probe_id     = var.health_probe_id
  rolling_upgrade_policy {
    max_batch_instance_percent              = 10
    max_unhealthy_instance_percent          = 10
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "vmss_interface"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id
      application_gateway_backend_address_pool_ids = [var.backend_pool_id]
    }
  }

  tags = {
    environment = "dev"
  }
}