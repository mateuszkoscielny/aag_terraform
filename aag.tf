
resource "azurerm_subnet" "frontend" {
  name                 = "ag-waf-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.demo.name
  address_prefixes     = ["10.0.128.0/24"]
}
#&nbsp;since these variables are re-used - a locals block makes this more rgtainable
#locals {
#  backend_address_pool_name      = "${azurerm_virtual_network.rg.name}-beap"
#  frontend_port_name             = "${azurerm_virtual_network.rg.name}-feport"
#  frontend_ip_configuration_name = "${azurerm_virtual_network.rg.name}-feip"
#  http_setting_name              = "${azurerm_virtual_network.rg.name}-be-htst"
#  listener_name                  = "${azurerm_virtual_network.rg.name}-httplstn"
#  request_routing_rule_name      = "${azurerm_virtual_network.rg.name}-rqrt"
#  redirect_configuration_name    = "${azurerm_virtual_network.rg.name}-rdrcfg"
#}

resource "azurerm_application_gateway" "network" {
  name                = format("mkos-%s-ag", var.cluster_name)
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = var.ag_min_capacity
    max_capacity = var.ag_max_capacity
  }

  gateway_ip_configuration {
    name      = "ag-ip-config"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = var.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.ag_pip.id
  }

  backend_address_pool {
    name         = var.backend_address_pool
    ip_addresses = [azurerm_public_ip.demo-instance.ip_address]
  }
  probe {
    name                = var.ag_probe_name
    protocol            = "Http"
    host                = azurerm_public_ip.demo-instance.ip_address
    path                = "/"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    match {
      body        = ""
      status_code = ["200-399"]
    }
  }

  backend_http_settings {
    name                  = var.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    probe_name            = var.ag_probe_name
  }

  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.listener_name
    backend_address_pool_name  = var.backend_address_pool
    backend_http_settings_name = var.backend_http_settings_name
  }
  firewall_policy_id = azurerm_web_application_firewall_policy.demo_waf_policty.id
}

resource "azurerm_monitor_diagnostic_setting" "ag" {
  name               = "ag_diag"
  target_resource_id = azurerm_application_gateway.network.id
  storage_account_id = var.storage_account_diag_id

  log {
    category = "ApplicationGatewayAccessLog"
    enabled  = true

    retention_policy {
      days = 0
      enabled = false
    }
  }
    log {
    category = "ApplicationGatewayPerformanceLog"
    enabled  = true

    retention_policy {
      days = 0
      enabled = false
    }
  }
    log {
    category = "ApplicationGatewayFirewallLog"
    enabled  = true

    retention_policy {
      days = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      days = 0
      enabled = false
    }
  }
}

