output "kube_config" {
  value = azurerm_kubernetes_cluster.main.kube_config
}

output "name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "id" {
  value = azurerm_kubernetes_cluster.main.id
}

output "fqdn" {
  value = azurerm_kubernetes_cluster.main.fqdn
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.main.node_resource_group
}

output "identity" {
  value = azurerm_kubernetes_cluster.main.identity
}