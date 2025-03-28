resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.vmss_name}-vmss"
  location            = var.location
  resource_group_name = var.resource_group_name

  lifecycle {
    create_before_destroy = true
  }

  sku                 = var.vm_size
  instances           = var.instance_count

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
      subnet_id = var.subnet_id
      application_gateway_backend_address_pool_ids = var.backend_pool_id
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