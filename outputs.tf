
/*
output "public_ip_address" {
  for_each = var.instances
  value = azurerm_public_ip.public_ip[each.key].ip_address
}

output "public_ip_domain_name_label" {
  value = azurerm_public_ip.public_ip.domain_name_label
}

output "public_ip_fqdn" {
  value = join(".", [azurerm_public_ip.public_ip.domain_name_label, var.location, "cloudapp.azure.com"])
}

output "nios_url" {
  value = "https://${join(".", [azurerm_public_ip.public_ip.domain_name_label, var.location, "cloudapp.azure.com"])}/"
}

output "user_data" {
  value = local.nios_infoblox_config_vars
  sensitive = true
} 

*/