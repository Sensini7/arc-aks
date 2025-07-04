module "resource_group" {
  source   = "./modules/resource_group"
  name     = var.rg_name
  location = var.location
}

module "aks" {
  source              = "./modules/aks"
  name                = var.aks_name
  resource_group_name = module.resource_group.name
  location            = var.location
  dns_prefix          = var.dns_prefix
  node_count          = var.node_count
  vm_size             = var.vm_size
}

provider "kubernetes" {
  host                   = module.aks.kube_config[0].host
  client_certificate     = base64decode(module.aks.kube_config[0].client_certificate)
  client_key             = base64decode(module.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.aks.kube_config[0].host
    client_certificate     = base64decode(module.aks.kube_config[0].client_certificate)
    client_key             = base64decode(module.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(module.aks.kube_config[0].cluster_ca_certificate)
  }
}

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
