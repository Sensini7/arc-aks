# Get current client config
data "azurerm_client_config" "current" {}

module "resource_group" {
  source   = "./modules/resource_group"
  name     = var.rg_name
  location = var.location
}

# Phase 1: Network Infrastructure.
module "networking" {
  source = "./modules/networking"

  name_prefix         = var.name_prefix
  location            = var.location
  resource_group_name = module.resource_group.name
  vnet_address_space  = var.vnet_address_space
  aks_subnet_cidr     = var.aks_subnet_cidr
  pe_subnet_cidr      = var.pe_subnet_cidr

  tags = {
    Environment = "Production"
    Project     = "ARC-AKS"
    Phase       = "1"
  }
}

# Phase 1: Key Vault Infrastructure
module "key_vault" {
  source = "./modules/key_vault"

  name                = var.key_vault_name
  location            = var.location
  resource_group_name = module.resource_group.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  tags = {
    Environment = "Production"
    Project     = "ARC-AKS"
    Phase       = "1"
  }
}

# Phase 1: Key Vault Private Endpoint
module "key_vault_private_endpoint" {
  source = "./modules/private_endpoint"

  name                = "${var.name_prefix}-kv-pe"
  location            = var.location
  resource_group_name = module.resource_group.name
  subnet_id           = module.networking.private_endpoints_subnet_id
  target_resource_id  = module.key_vault.key_vault_id
  subresource_names   = ["vault"]

  tags = {
    Environment = "Production"
    Project     = "ARC-AKS"
    Phase       = "1"
  }
}

# Phase 1: Workload Identity
module "workload_identity" {
  source = "./modules/identity"

  name                = "${var.name_prefix}-workload-identity"
  location            = var.location
  resource_group_name = module.resource_group.name

  tags = {
    Environment = "Production"
    Project     = "ARC-AKS"
    Phase       = "1"
  }
}

# Enhanced AKS with Phase 1 security
module "aks" {
  source = "./modules/aks"

  name                      = var.aks_name
  resource_group_name       = module.resource_group.name
  location                  = var.location
  dns_prefix                = var.dns_prefix
  node_count                = var.node_count
  vm_size                   = var.vm_size
  vnet_subnet_id            = module.networking.aks_subnet_id
  private_cluster_enabled   = var.private_cluster_enabled
  disk_encryption_set_id    = module.key_vault.disk_encryption_set_id
  enable_host_encryption    = var.enable_host_encryption
  workload_identity_enabled = true
  oidc_issuer_enabled       = true
  azure_rbac_enabled        = true

  tags = {
    Environment = "Production"
    Project     = "ARC-AKS"
    Phase       = "1"
  }
}

# Kubernetes and Helm providers (updated for private cluster)
provider "kubernetes" {
  host                   = module.aks.kube_config[0].host
  client_certificate     = base64decode(module.aks.kube_config[0].client_certificate)
  client_key             = base64decode(module.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = module.aks.kube_config[0].host
    client_certificate     = base64decode(module.aks.kube_config[0].client_certificate)
    client_key             = base64decode(module.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(module.aks.kube_config[0].cluster_ca_certificate)
  }
}

# Existing ARC modules (will be enhanced in later phases)
module "arc_namespace" {
  source = "./modules/arc_namespace"
}

module "arc_controller" {
  source               = "./modules/arc_controller"
  namespace            = module.arc_namespace.namespace_name
  namespace_depends_on = [module.arc_namespace]
}

module "github_secret" {
  source                     = "./modules/github_secret"
  namespace                  = module.arc_namespace.namespace_name
  github_app_id              = var.github_app_id
  github_app_installation_id = var.github_app_installation_id
  github_app_private_key     = var.github_app_private_key
}

module "arc_runner_scaleset" {
  source                    = "./modules/arc_runner_scaleset"
  namespace                 = module.arc_namespace.namespace_name
  namespace_depends_on      = [module.arc_controller, module.github_secret]
  github_config_url         = var.github_config_url
  github_config_secret_name = module.github_secret.secret_name
  release_name              = var.arc_runner_release_name
  runner_group              = var.runner_group
  min_runners               = var.min_runners
  max_runners               = var.max_runners
  runner_image              = var.runner_image
}