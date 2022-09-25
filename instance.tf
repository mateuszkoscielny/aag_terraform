# Bootstrapping Template File
data "template_file" "nginx-vm-cloud-init" {
  template = file("./install-nginx.sh")
}

resource "azurerm_linux_virtual_machine" "demo-instance" {
  name                  = "${var.prefix}-${var.env_type}-vm"
  location              = var.region
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = ["${azurerm_network_interface.demo-instance.id}"]
  size                  = "Standard_A1_v2"
  admin_username        = "demo"
  admin_ssh_key {
    username   = "demo"
    public_key = file("./ssh_key/vm.pub")
  }
  boot_diagnostics {}
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  allow_extension_operations = true
}

resource "null_resource" "nginx_install" {

  triggers = {
    zabbix_proxy_host_id = azurerm_linux_virtual_machine.demo-instance.id
  }

  connection {
    user        = azurerm_linux_virtual_machine.demo-instance.admin_username
    private_key = file("./ssh_key/vm")
    host        = azurerm_linux_virtual_machine.demo-instance.public_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt -y install nginx",
    ]
  }
  depends_on = [
    azurerm_linux_virtual_machine.demo-instance
  ]
}

resource "azurerm_monitor_diagnostic_setting" "vm" {
  count              = var.enable_diagnostic ? 1 : 0
  name               = "${var.prefix}-${var.env_type}-vm"
  target_resource_id = azurerm_linux_virtual_machine.demo-instance.id
  storage_account_id = azurerm_storage_account.storage_account.id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = "5"
    }
  }
}


resource "azurerm_network_interface" "demo-instance" {
  name                = "${var.prefix}-${var.env_type}-instance1"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "instance1"
    subnet_id                     = azurerm_subnet.demo-internal-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.demo-instance.id
  }
}

resource "azurerm_public_ip" "demo-instance" {
  name                = "instance1-public-ip"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "ag_pip" {
  name                = var.frontend_ip_configuration_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_monitor_diagnostic_setting" "vm_pip" {
  count              = var.enable_diagnostic ? 1 : 0
  name               = "${var.prefix}-${var.env_type}-vm-pip"
  target_resource_id = azurerm_public_ip.demo-instance.id
  storage_account_id = azurerm_storage_account.storage_account.id

  log {
    category = "DDoSProtectionNotifications"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "DDoSMitigationFlowLogs"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "DDoSMitigationReports"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}
resource "azurerm_monitor_diagnostic_setting" "ag_pip" {
  count              = var.enable_diagnostic ? 1 : 0
  name               = "${var.prefix}-${var.env_type}-ag-pip"
  target_resource_id = azurerm_public_ip.ag_pip.id
  storage_account_id = azurerm_storage_account.storage_account.id

  log {
    category = "DDoSProtectionNotifications"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "DDoSMitigationFlowLogs"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "DDoSMitigationReports"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}
resource "azurerm_monitor_diagnostic_setting" "network_interface" {
  count              = var.enable_diagnostic ? 1 : 0
  name               = "${var.prefix}-${var.env_type}-nic"
  target_resource_id = azurerm_network_interface.demo-instance.id
  storage_account_id = azurerm_storage_account.storage_account.id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}
