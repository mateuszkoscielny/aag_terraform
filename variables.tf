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
  default = "mkosdemo"
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
variable "enable_diagnostic" {
  description = "Whether to enable diagnostic settings"
  default     = false
  type        = bool
}
variable "enable_aag" {
  description = "Whether to enable diagnostic settings"
  default     = false
  type        = bool
}
variable "service_bus_namespaces" {
  description = "Names of storage accounts. If null none will be created"
  type        = list(map(string))
  default = [
    {
      type = "internal"
      name = "mkosdemo"
    },
    {
      type = "internal"
      name = "mkosdemos"
    }
  ]
}
variable "service_bus_sku" {
  description = "SKU to be used by ASB"
  type        = string
  default     = "Standard"
}
variable "diag_retention_days" {
  description = "Number of days for the retention period of diagnostic setting files"
  type        = string
  default     = "365"
}
variable "private_zone" {
  description = "private zone name"
  type        = string
  default     = "terraform.devopstraining.pl"
}
