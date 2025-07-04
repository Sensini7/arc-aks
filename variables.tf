variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "sa_name" {
  description = "Storage account name"
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
  default     = "Standard_DS2_v2"
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
