resource "azurerm_storage_account" "storage_account" {
  name                     = "mkosstorageaccount"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "storage_account1" {
  name                     = "mkosstorageaccount1"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
resource "azurerm_storage_share" "example" {
  name                 = "sharename"
  storage_account_name = azurerm_storage_account.storage_account1.name
  quota                = 50
}

resource "azurerm_private_endpoint" "test" {
  name = "demo01"
  location = var.region
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id = azurerm_subnet.demo-internal-1.id
  private_service_connection {
    is_manual_connection = false
    name = "demo01-psc"
    private_connection_resource_id = azurerm_storage_account.storage_account1.id
    subresource_names = [ "file" ]
  }
}


resource "azurerm_monitor_diagnostic_setting" "storage" {
  name               = "storageaccount"
  target_resource_id = var.storage_account_diag_id
  storage_account_id = var.storage_account_diag_id

  metric {
    category = "Capacity"

    retention_policy {
      days = 0
      enabled = false
    }
  }
  metric {
    category = "Transaction"

    retention_policy {
      days = 0
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_file" {
  name               = "storageaccount-file"
  target_resource_id = "${var.storage_account_diag_id}/fileServices/default"
  storage_account_id = var.storage_account_diag_id

  log {
    category = "StorageRead"
    enabled  = true

    retention_policy {
      days = 0
      enabled = false
    }
  }
  log {
    category = "StorageWrite"
    enabled  = true

    retention_policy {
      days = 0
      enabled = false
    }
  }
  log {
    category = "StorageDelete"
    enabled  = true

    retention_policy {
      days = 0
      enabled = false
    }
  }
  metric {
    category = "Capacity"

    retention_policy {
      days = 0
      enabled = false
    }
  }
  metric {
    category = "Transaction"

    retention_policy {
      days = 0
      enabled = false
    }
  }
}