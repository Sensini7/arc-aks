location   = "westus"
rg_name    = "arc-demo-rg"
aks_name   = "arcaksdemo"
dns_prefix = "arcaksdemo"
vm_size    = "Standard_B2s"
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
name_prefix             = "arc"
key_vault_name          = "arc-kv-unique-20250115" # Make this globally unique
vnet_address_space      = ["10.0.0.0/22"]
aks_subnet_cidr         = "10.0.1.0/24"
pe_subnet_cidr          = "10.0.2.0/24"
private_cluster_enabled = true
enable_host_encryption  = true