resource "azurerm_storage_account" "storage_account" {
  name                     = "mkosstorageaccount"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "example" {
  name                 = "sharename"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 50
}


resource "azurerm_monitor_diagnostic_setting" "storage" {
  count              = var.enable_diagnostic ? 1 : 0
  name               = "storageaccount"
  target_resource_id = azurerm_storage_account.storage_account.id
  storage_account_id = azurerm_storage_account.storage_account.id

  metric {
    category = "Capacity"

    retention_policy {
      enabled = false
    }
  }
  metric {
    category = "Transaction"

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_file" {
  count              = var.enable_diagnostic ? 1 : 0
  name               = "storageaccount-file"
  target_resource_id = "${azurerm_storage_account.storage_account.id}/fileServices/default"
  storage_account_id = azurerm_storage_account.storage_account.id

  log {
    category = "StorageRead"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "StorageWrite"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "StorageDelete"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  metric {
    category = "Capacity"

    retention_policy {
      enabled = false
    }
  }
  metric {
    category = "Transaction"

    retention_policy {
      enabled = false
    }
  }
}
