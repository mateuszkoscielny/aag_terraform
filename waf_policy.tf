resource "azurerm_web_application_firewall_policy" "demo_waf_policty" {
  count               = var.enable_aag ? 1 : 0
  name                = "${var.env_type}-policy"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.region

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.1"
    }
  }

}
