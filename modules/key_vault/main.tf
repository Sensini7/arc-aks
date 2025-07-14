#Key Vault
# Current client configuration to get tenant and object ID
data "azurerm_client_config" "current" {}

# Get current public IP for Terraform access
data "http" "terraform_public_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "azurerm_key_vault" "main" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7
  enabled_for_disk_encryption = true
  enabled_for_deployment      = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Use access policy instead of role assignment
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "List",
    "Update",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]

  certificate_permissions = [
    "Get",
    "List",
    "Create",
    "Delete",
    "Update",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]
}

resource "azurerm_key_vault_key" "disk_encryption" {
  depends_on   = [azurerm_key_vault_access_policy.current_user]
  name         = "aks-disk-encryption-key"
  key_vault_id = azurerm_key_vault.main.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_disk_encryption_set" "main" {
  name                = "${var.key_vault_name}-des"
  resource_group_name = var.resource_group_name
  location            = var.location
  key_vault_key_id    = azurerm_key_vault_key.disk_encryption.id

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "disk_encryption_set" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = azurerm_disk_encryption_set.main.identity.0.tenant_id
  object_id    = azurerm_disk_encryption_set.main.identity.0.principal_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey",
  ]
}