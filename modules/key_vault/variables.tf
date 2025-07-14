variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for Key Vault access"
  type        = list(string)
  default     = []
}

variable "key_vault_network_default_action" {
  description = "Default action for Key Vault network ACLs"
  type        = string
  default     = "Allow"
}

variable "purge_protection_enabled" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention days"
  type        = number
  default     = 7
}

variable "disk_encryption_key_name" {
  description = "Name of the disk encryption key"
  type        = string
  default     = "aks-disk-encryption-key"
}

variable "key_type" {
  description = "Type of key to create"
  type        = string
  default     = "RSA"
}

variable "key_size" {
  description = "Size of the key"
  type        = number
  default     = 2048
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}