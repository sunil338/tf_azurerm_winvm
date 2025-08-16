output "public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.pip.ip_address
}

output "admin_username" {
  value = var.admin_username
}

output "admin_password" {
  description = "The admin password (sensitive)"
  value       = var.admin_password
  sensitive   = true
}
