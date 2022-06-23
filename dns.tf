#resource "azurerm_resource_group" "dns" {
#    name = "Terraform-dns"
#    location = "North Europe"
#}
#
#resource "azurerm_dns_zone" "terraform_dns" {
#    name = "terraform.devopstraining.pl"
#    resource_group_name = azurerm_resource_group.dns.name
#}
#
resource "azurerm_dns_a_record" "dns" {
    name = var.env_type
    zone_name = "terraform.devopstraining.pl"
    resource_group_name = "Terraform-dns"
    ttl = 300
    records = [azurerm_public_ip.ag_pip.ip_address]
}