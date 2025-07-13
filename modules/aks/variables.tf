variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "dns_prefix" {
  type = string
}
variable "node_count" {
  type = number
}
variable "vm_size" {
  type = string
}

# New variables to integrate Vnet
variable "vnet_subnet_id" {
  type = string
}

variable "private_cluster_enabled" {
  type    = bool
  default = true
}

variable "private_dns_zone_id" {
  type    = string
  default = "System"
}

variable "disk_encryption_set_id" {
  type    = string
  default = null
}

variable "enable_host_encryption" {
  type    = bool
  default = true
}

variable "workload_identity_enabled" {
  type    = bool
  default = true
}

variable "oidc_issuer_enabled" {
  type    = bool
  default = true
}

variable "azure_rbac_enabled" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
