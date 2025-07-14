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

variable "authorized_ip_ranges" {
  description = "Authorized IP ranges for API server access"
  type        = list(string)
  default     = []
}

variable "service_cidr" {
  description = "Service CIDR for the cluster"
  type        = string
  default     = "172.16.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP"
  type        = string
  default     = "172.16.0.10"
}

variable "network_plugin" {
  description = "Network plugin for AKS"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy for AKS"
  type        = string
  default     = "azure"
}

variable "default_node_pool_name" {
  description = "Name of the default node pool"
  type        = string
  default     = "default"
}

variable "max_surge" {
  description = "Maximum surge for node pool upgrades"
  type        = string
  default     = "10%"
}
