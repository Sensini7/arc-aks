output "kube_config" {
  value = azurerm_kubernetes_cluster.this.kube_config
}
output "resource_group_name" {
  value = module.resource_group.name
}
output "aks_cluster_name" {
  value = module.aks.name
}