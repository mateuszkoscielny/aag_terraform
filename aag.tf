
resource "azurerm_subnet" "frontend" {
  name                 = "ag-waf-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.demo.name
  address_prefixes     = ["10.0.128.0/24"]
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "local_file" "certificate_crt" {
  content_base64 = filebase64("./cert/certificate.crt")
  filename       = "./certificate/certificate.crt"
}

# writes the private key to a temp file.
resource "local_file" "private_key_crt" {
  content_base64 = filebase64("./cert/private.key")
  filename       = "./certificate/private.key"
}

# uses both files to generate the pfx with openssl
resource "null_resource" "crt2pfx" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "openssl pkcs12 -export -in ${local_file.certificate_crt.filename} -inkey ${local_file.private_key_crt.filename} -out ./certificate/certificate.pfx -passout pass:${random_password.password.result}"
  }
}

resource "azurerm_application_gateway" "network" {
  depends_on = [
    null_resource.crt2pfx
  ]
  count               = var.enable_aag ? 1 : 0
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
    name = local.aag_parameters.frontend_port_name
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.aag_parameters.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.ag_pip.id
  }

  # backend_address_pool {
  #   name         = var.backend_address_pool
  #   ip_addresses = [azurerm_public_ip.demo-instance.ip_address]
  # }
  # probe {
  #   name                = var.ag_probe_name
  #   protocol            = "Http"
  #   host                = azurerm_public_ip.demo-instance.ip_address
  #   path                = "/"
  #   interval            = 30
  #   timeout             = 30
  #   unhealthy_threshold = 3
  #   match {
  #     body        = ""
  #     status_code = ["200-399"]
  #   }
  # }

  # backend_http_settings {
  #   name                  = var.backend_http_settings_name
  #   cookie_based_affinity = "Disabled"
  #   port                  = 80
  #   protocol              = "Http"
  #   request_timeout       = 20
  #   probe_name            = var.ag_probe_name
  # }

  # http_listener {
  #   name                           = var.listener_name
  #   frontend_ip_configuration_name = var.frontend_ip_configuration_name
  #   frontend_port_name             = var.frontend_port_name
  #   protocol                       = "Http"
  # }

  # request_routing_rule {
  #   name                       = var.request_routing_rule_name
  #   rule_type                  = "Basic"
  #   http_listener_name         = var.listener_name
  #   backend_address_pool_name  = var.backend_address_pool
  #   backend_http_settings_name = var.backend_http_settings_name
  # }
  firewall_policy_id = azurerm_web_application_firewall_policy.demo_waf_policty[0].id

  ssl_certificate {
    name     = local.aag_parameters.ssl_certificate_name
    data     = data.local_file.certificate_pfx.content_base64
    password = random_password.password.result
  }

  dynamic "backend_address_pool" {
    for_each = local.aag_parameters2
    iterator = self
    content {
      name = self.value["backend_address_pool_name"]
      # fqdns = self.value["aag_backends"]
      ip_addresses = [azurerm_public_ip.demo-instance.ip_address]
    }

  }
  dynamic "backend_address_pool" {
    for_each = local.aag_parameters3
    iterator = self
    content {
      name  = self.value["backend_address_pool_name"]
      fqdns = self.value["aag_backends"]
    }
  }
  dynamic "backend_http_settings" {
    for_each = local.aag_parameters2
    iterator = self
    content {
      name                  = self.value["http_setting_name"]
      cookie_based_affinity = "Disabled"
      path                  = ""
      port                  = 80
      protocol              = "Http"
      request_timeout       = 60
      probe_name            = self.value["health_probe"]
    }
  }
  dynamic "backend_http_settings" {
    for_each = local.aag_parameters3
    iterator = self
    content {
      name                  = self.value["http_setting_name"]
      cookie_based_affinity = "Disabled"
      path                  = ""
      port                  = 443
      protocol              = "Https"
      request_timeout       = 60
      probe_name            = self.value["health_probe"]
    }
  }
  dynamic "probe" {
    for_each = local.aag_parameters2
    iterator = self
    content {
      name                = self.value["health_probe"]
      host                = azurerm_public_ip.demo-instance.ip_address
      path                = "/"
      interval            = 60
      unhealthy_threshold = 10
      timeout             = 10
      protocol            = "Http"
    }
  }
  dynamic "probe" {
    for_each = local.aag_parameters3
    iterator = self
    content {
      name                = self.value["health_probe"]
      host                = format("%s.reltio.com", self.key)
      path                = "/logo.svg"
      interval            = 60
      unhealthy_threshold = 10
      timeout             = 10
      protocol            = "Https"
    }
  }
  dynamic "http_listener" {
    for_each = local.aag_parameters2
    iterator = self
    content {
      name                           = self.value["listener_name"]
      frontend_ip_configuration_name = local.aag_parameters.frontend_ip_configuration_name
      frontend_port_name             = local.aag_parameters.frontend_port_name
      protocol                       = "Https"
      ssl_certificate_name           = local.aag_parameters.ssl_certificate_name
      host_names                     = self.value["host_names"]
    }
  }
  dynamic "http_listener" {
    for_each = local.aag_parameters3
    iterator = self
    content {
      name                           = self.value["listener_name"]
      frontend_ip_configuration_name = local.aag_parameters.frontend_ip_configuration_name
      frontend_port_name             = local.aag_parameters.frontend_port_name
      protocol                       = "Https"
      ssl_certificate_name           = local.aag_parameters.ssl_certificate_name
      host_names                     = self.value["host_names"]
    }
  }
  dynamic "request_routing_rule" {
    for_each = local.aag_parameters2
    iterator = self
    content {
      name                       = self.value["request_routing_rule_name"]
      rule_type                  = "Basic"
      http_listener_name         = self.value["listener_name"]
      backend_address_pool_name  = self.value["backend_address_pool_name"]
      backend_http_settings_name = self.value["http_setting_name"]
    }
  }


  dynamic "request_routing_rule" {
    for_each = local.aag_parameters3
    iterator = self
    content {
      name                       = self.value["request_routing_rule_name"]
      rule_type                  = "Basic"
      http_listener_name         = self.value["listener_name"]
      backend_address_pool_name  = self.value["backend_address_pool_name"]
      backend_http_settings_name = self.value["http_setting_name"]
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "ag" {
  count              = var.enable_aag && var.enable_diagnostic ? 1 : 0
  name               = "ag_diag"
  target_resource_id = azurerm_application_gateway.network[0].id
  storage_account_id = azurerm_storage_account.storage_account.id

  log {
    category = "ApplicationGatewayAccessLog"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "ApplicationGatewayPerformanceLog"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "ApplicationGatewayFirewallLog"
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
