output "kube_config" {
  description = "Kube config block for AKS"
  value       = module.aks.kube_config
  sensitive   = true
}

output "arc_namespace" {
  description = "ARC Namespace"
  value       = module.arc_namespace.namespace_name
}

output "resource_group_name" {
  value = module.resource_group.name
}

output "aks_cluster_name" {
  value = module.aks.name
}
