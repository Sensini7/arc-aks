# Key Vault
resource "azurerm_key_vault" "main" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  enabled_for_deployment      = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  sku_name                    = var.sku_name
  tags                        = var.tags

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
}

# Current client configuration
data "azurerm_client_config" "current" {}

# Key Vault Administrator role assignment for current user
resource "azurerm_role_assignment" "key_vault_admin_current_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Key Vault Administrator role assignments for additional admins
resource "azurerm_role_assignment" "key_vault_admin" {
  for_each             = toset(var.admin_object_ids)
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}

# Customer-managed key for disk encryption
resource "azurerm_key_vault_key" "disk_encryption" {
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

  depends_on = [azurerm_role_assignment.key_vault_admin_current_user]
}

# Disk encryption set
resource "azurerm_disk_encryption_set" "main" {
  name                = "${var.name}-des"
  resource_group_name = var.resource_group_name
  location            = var.location
  key_vault_key_id    = azurerm_key_vault_key.disk_encryption.id
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}

# Grant disk encryption set access to Key Vault
resource "azurerm_key_vault_access_policy" "disk_encryption_set" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = var.tenant_id
  object_id    = azurerm_disk_encryption_set.main.identity[0].principal_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
}