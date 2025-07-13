output "key_vault_id" {
  value = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  value = azurerm_key_vault.main.vault_uri
}

output "disk_encryption_set_id" {
  value = azurerm_disk_encryption_set.main.id
}

output "key_vault_name" {
  value = azurerm_key_vault.main.name
}