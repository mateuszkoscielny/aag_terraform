resource "azurerm_virtual_network" "demo" {
  name                = "${var.prefix}-${var.env_type}-network"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "demo-internal-1" {
  name                 = "${var.prefix}-${var.env_type}-internal-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.demo.name
  address_prefixes     = ["10.0.0.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_network_security_group" "vm-nsg" {
  name                = "${var.prefix}-${var.env_type}-vm-nsg"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                         = "SSH"
    priority                     = 1001
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "22"
    source_address_prefix        = "*"
    destination_address_prefixes = azurerm_subnet.demo-internal-1.address_prefixes
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1011
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = azurerm_public_ip.ag_pip.ip_address
    destination_address_prefix = "Internet"
  }
  security_rule {
    name                         = "AllowSubnetInBound"
    priority                     = 4095
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "*"
    source_port_range            = "*"
    destination_port_range       = "*"
    source_address_prefixes      = azurerm_subnet.demo-internal-1.address_prefixes
    destination_address_prefixes = azurerm_subnet.demo-internal-1.address_prefixes
  }
  security_rule {
    name                       = "DenyVnetInBound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
}
resource "azurerm_subnet_network_security_group_association" "demo" {
  subnet_id                 = azurerm_subnet.demo-internal-1.id
  network_security_group_id = azurerm_network_security_group.vm-nsg.id
}

resource "azurerm_monitor_diagnostic_setting" "network" {
  name               = "${var.prefix}-${var.env_type}-network"
  target_resource_id = azurerm_virtual_network.demo.id
  storage_account_id = var.storage_account_diag_id

  log {
    category = "VMProtectionAlerts"
    enabled  = true

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
resource "azurerm_monitor_diagnostic_setting" "network_nsg" {
  name               = "${var.prefix}-${var.env_type}-vm-nsg"
  target_resource_id = azurerm_network_security_group.vm-nsg.id
  storage_account_id = var.storage_account_diag_id

  log {
    category = "NetworkSecurityGroupEvent"
    enabled  = true

    retention_policy {
      days = 0
      enabled = false
    }
  }
  log {
    category = "NetworkSecurityGroupRuleCounter"
    enabled  = true

    retention_policy {
      days = 0
      enabled = false
    }
  }
}
