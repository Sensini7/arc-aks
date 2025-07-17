output "id" {
  description = "Key Vault ID"
  value       = azurerm_key_vault.main.id
}

output "name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.main.name
}

output "vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.main.vault_uri
}

output "github_app_id_secret_name" {
  description = "Name of the GitHub App ID secret"
  value       = azurerm_key_vault_secret.github_app_id.name
}

output "github_app_installation_id_secret_name" {
  description = "Name of the GitHub App Installation ID secret"
  value       = azurerm_key_vault_secret.github_app_installation_id.name
}

output "github_app_private_key_secret_name" {
  description = "Name of the GitHub App Private Key secret"
  value       = azurerm_key_vault_secret.github_app_private_key.name
}
