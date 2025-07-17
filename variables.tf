variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "aks_name" {
  description = "AKS cluster name"
  type        = string
}

variable "dns_prefix" {
  description = "AKS DNS prefix"
  type        = string
}

variable "node_count" {
  description = "AKS node count"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "AKS VM size"
  type        = string
  default     = "Standard D2s v6"
}

variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID"
  type        = string
}

variable "github_app_private_key" {
  description = "GitHub App Private Key (PEM, base64 encoded if possible)"
  type        = string
}

# New variables for ARC Runner Scale Set
variable "github_config_url" {
  description = "GitHub repository or organization URL"
  type        = string
  default     = "https://github.com/Sensini7/arc-aks"
}

variable "runner_group" {
  description = "GitHub runner group"
  type        = string
  default     = "Default"
}

variable "min_runners" {
  description = "Minimum number of runners"
  type        = number
  default     = 0
}

variable "max_runners" {
  description = "Maximum number of runners"
  type        = number
  default     = 10
}

variable "runner_image" {
  description = "Container image for the runners"
  type        = string
  default     = "ghcr.io/actions/actions-runner:latest"
}

variable "arc_runner_release_name" {
  description = "Helm release name for the runner scale set"
  type        = string
  default     = "arc-runner-set"
}

# New Phase 1 variables
variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "arc"
}

variable "vnet_address_space" {
  description = "Virtual network address space"
  type        = list(string)
  default     = ["10.0.0.0/22"]
}

variable "aks_subnet_cidr" {
  description = "AKS subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "pe_subnet_cidr" {
  description = "Private endpoints subnet CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "key_vault_name" {
  description = "Key Vault name"
  type        = string
}

variable "private_cluster_enabled" {
  description = "Enable private AKS cluster"
  type        = bool
  default     = true
}

variable "enable_host_encryption" {
  description = "Enable host-based encryption"
  type        = bool
  default     = true
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP CIDR ranges for secure access"
  type        = list(string)
  default     = []
}

variable "key_vault_network_default_action" {
  description = "Default action for Key Vault network ACLs (Allow/Deny)"
  type        = string
  default     = "Allow"
}

variable "authorized_ip_ranges" {
  description = "Authorized IP ranges for AKS API server access"
  type        = list(string)
  default     = []
}

variable "service_cidr" {
  description = "Service CIDR for AKS cluster"
  type        = string
  default     = "172.16.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP for AKS cluster"
  type        = string
  default     = "172.16.0.10"

}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "demo"
    Project     = "arc-demo"
    ManagedBy   = "terraform"
  }
}
