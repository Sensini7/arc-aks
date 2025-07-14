data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"
  purge_protection_enabled    = var.purge_protection_enabled
  soft_delete_retention_days  = var.soft_delete_retention_days
  enabled_for_disk_encryption = true
  enabled_for_deployment      = true

  network_acls {
    default_action = var.key_vault_network_default_action
    bypass         = "AzureServices"
    ip_rules       = var.allowed_ip_ranges
  }

  tags = var.tags
}

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
  name         = var.disk_encryption_key_name
  key_vault_id = azurerm_key_vault.main.id
  key_type     = var.key_type
  key_size     = var.key_size

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  tags = var.tags
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