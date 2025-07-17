# Basic configuration
location    = "westus"
rg_name     = "arc-demo-rg"
name_prefix = "arc"
# aks_name   = "arcaksdemo"
# dns_prefix = "arcaksdemo"
# vm_size    = "Standard_B2s"
#vm_size   = "Standard_D2s_v4"
# github_app_id   = "123456"
# github_app_installation_id = "654321"
# github_app_private_key     = "<PEM CONTENTS>"

# GitHub configuration
github_config_url       = "https://github.com/Sensini7/arc-aks"
runner_group            = "Default"
min_runners             = 0
max_runners             = 10
runner_image            = "ghcr.io/actions/actions-runner:latest"
arc_runner_release_name = "arc-runner-set"

# GitHub App credentials are still in github_app.auto.tfvars
# github_app_id   = "123456"
# github_app_installation_id = "654321"
# github_app_private_key     = "<PEM CONTENTS>"

# Phase 1 Security Configuration
# name_prefix             = "arc"
# key_vault_name          = "arc-kv-unique-20250115" # Make this globally unique
# vnet_address_space      = ["10.0.0.0/22"]
# aks_subnet_cidr         = "10.0.1.0/24"
# pe_subnet_cidr          = "10.0.2.0/24"
# private_cluster_enabled = true
# enable_host_encryption  = true

# Networking
vnet_address_space = ["10.0.0.0/16"]
aks_subnet_cidr    = "10.0.1.0/24"
pe_subnet_cidr     = "10.0.2.0/24"

# AKS configuration
aks_name                = "arcaksdemo"
dns_prefix              = "arcaksdemo"
private_cluster_enabled = true            # Start with false for initial setup
enable_host_encryption  = true            # Start with false for initial setup
service_cidr            = "172.16.0.0/16" # Non-overlapping with VNet
dns_service_ip          = "172.16.0.10"
vm_size                 = "Standard_B2s"

# Key Vault configuration
key_vault_name                   = "arc-kv-unique-20250115"
key_vault_network_default_action = "Allow" # Allow for initial setup

# Security (add your actual IP ranges)
allowed_ip_ranges    = [] # Empty for now, add your IPs later
authorized_ip_ranges = [] # Empty for now, add your IPs later
