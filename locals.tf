locals {
  ag_waf_subnet_address_space = format("%s.128.0/24", var.vnet_cidr_prefix)
  vnet_address_space          = format("%s.0.0/16", var.vnet_cidr_prefix)
  demo_internat_space         = format("%s.0.0/16", var.vnet_cidr_prefix)
  aag_parameters = {
    backend_address_pool_name      = "${azurerm_virtual_network.demo.name}-beap"
    frontend_port_name             = "${azurerm_virtual_network.demo.name}-feport"
    frontend_ip_configuration_name = "${azurerm_virtual_network.demo.name}-feip"
    http_setting_name              = "${azurerm_virtual_network.demo.name}-be-htst"
    listener_name                  = "${azurerm_virtual_network.demo.name}-httplstn"
    request_routing_rule_name      = "${azurerm_virtual_network.demo.name}-rqrt"
    redirect_configuration_name    = "${azurerm_virtual_network.demo.name}-rdrchfg"
    health_probe                   = "${azurerm_virtual_network.demo.name}-health-probe"
    ssl_certificate_name           = format("mkos-%s-crt", var.cluster_name)
  }
  aag_parameters2 = var.service_bus_namespaces != null ? { for index, namespace in var.service_bus_namespaces : namespace.name => {
    backend_address_pool_name = "${namespace.name}-beap"
    # frontend_port_name             = "${namespace.name}-feport"
    # frontend_ip_configuration_name = "${namespace.name}-feip"
    http_setting_name           = "${namespace.name}-be-htst"
    listener_name               = "${namespace.name}-httplstn"
    request_routing_rule_name   = "${namespace.name}-rqrt-main"
    redirect_configuration_name = "${namespace.name}-rdrchfg"
    health_probe                = "${namespace.name}-health-probe"
    aag_backends                = [format("%s-router-elb-%s.reltio.com", namespace.name, var.private_zone)]
    host_names                  = [format("%s.terraform.devopstraining.pl", namespace.name)]
  } } : {}
  aag_parameters3 = var.service_bus_namespaces != null ? { for index, namespace in var.service_bus_namespaces : namespace.name => {
    backend_address_pool_name = "${namespace.name}-beap-srv"
    # frontend_port_name             = "${namespace.name}-feport-srv"
    # frontend_ip_configuration_name = "${namespace.name}-feip"
    http_setting_name           = "${namespace.name}-be-htst-sr"
    listener_name               = "${namespace.name}-httplstn-srv"
    request_routing_rule_name   = "${namespace.name}-rqrt-srv"
    redirect_configuration_name = "${namespace.name}-rdrchfg-srv"
    health_probe                = "${namespace.name}-health-probe-srv"
    aag_backends                = [format("%s-elb-%s", namespace.name, var.private_zone)]
    host_names                  = [format("%s-*.reltio.com", namespace.name)]
  } } : {}
  # aag_parameters_com = (local.aag_parameters2 + local.aag_parameters3)
}
