resource "azurerm_servicebus_namespace" "servicebus" {
  for_each            = var.service_bus_namespaces != null ? { for index, namespace in var.service_bus_namespaces : index => namespace } : {}
  name                = each.value.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.service_bus_sku

  tags = {
    namespace = each.value.name
    type      = each.value.type
  }
}


resource "azurerm_monitor_diagnostic_setting" "service_bus_diag" {
  for_each           = var.service_bus_namespaces != null && var.enable_diagnostic ? { for index, namespace in var.service_bus_namespaces : index => namespace } : {}
  name               = "service_bus_diag"
  target_resource_id = azurerm_servicebus_namespace.servicebus[each.key].id
  storage_account_id = azurerm_storage_account.storage_account.id

  log {
    category = "OperationalLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.diag_retention_days
    }
  }
  log {
    category = "RuntimeAuditLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.diag_retention_days
    }
  }
  log {
    category = "ApplicationMetricsLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.diag_retention_days
    }
  }
  log {
    category = "VNetAndIPFilteringLogs"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.diag_retention_days
    }
  }
  metric {
    category = "AllMetrics"
    retention_policy {
      enabled = true
      days    = var.diag_retention_days
    }
  }
}
