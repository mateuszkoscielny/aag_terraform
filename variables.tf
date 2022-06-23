variable "region" {
  type    = string
  default = "northeurope"
}
variable "prefix" {
  type    = string
  default = "demo"
}
variable "env_type" {
  type    = string
  default = "demo"
}

variable "ssh-source-address" {
  type    = string
  default = "*"
}

variable "private-cidr" {
  type    = string
  default = "10.1.0.0/24"
}
variable "cluster_name" {
  type    = string
  default = "demo"
}
variable "vnet_cidr_prefix" {
  type    = string
  default = "10.1"
}
variable "ag_min_capacity" {
  type    = string
  default = "0"
}
variable "ag_max_capacity" {
  type    = string
  default = "10"
}
variable "frontend_port_name" {
  type    = string
  default = "Port_80"
}
variable "frontend_ip_configuration_name" {
  type    = string
  default = "ag-pip"
}
variable "ag_probe_name" {
  type    = string
  default = "test_probe"
}
variable "probe_host" {
  type    = string
  default = "demo.terraform.devopstraining.pl"
}
variable "backend_http_settings_name" {
  type    = string
  default = "http-settings"
}
variable "listener_name" {
  type    = string
  default = "http-listner"
}
variable "request_routing_rule_name" {
  type    = string
  default = "routing-rule-test"
}
variable "backend_address_pool" {
  type    = string
  default = "ag-waf-pool"
}
variable "storage_account_diag_id" {
  type    = string
  default = "/subscriptions/508b244a-ad76-4aa0-b3bb-27c348b54deb/resourceGroups/DefaultResourceGroup-NEU/providers/Microsoft.Storage/storageAccounts/northeustorageaccounmkos"
}