output "demo_instance_public_ip" {
  description = "The actual ip address allocated for the resource."
  value       = azurerm_public_ip.demo-instance.ip_address
}
output "demo_ag_public_ip" {
  description = "The actual ip address allocated for the resource of Application Gateway."
  value       = azurerm_public_ip.ag_pip.ip_address
}
output "storage_account" {
  description = "Endpoint storage file"
  value       = azurerm_private_endpoint.test
}
output "storage_account1" {
  description = "Endpoint storage file"
  value       = azurerm_private_endpoint.test.network_interface[0].id
}