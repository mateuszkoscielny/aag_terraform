locals {
  ag_waf_subnet_address_space = format("%s.128.0/24", var.vnet_cidr_prefix)
  vnet_address_space          = format("%s.0.0/16", var.vnet_cidr_prefix)
  demo_internat_space         = format("%s.0.0/16", var.vnet_cidr_prefix)
}
