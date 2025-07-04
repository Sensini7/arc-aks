output "kube_config" {
  description = "Kube config block for AKS"
  value       = module.aks.kube_config
  sensitive   = true
}

output "arc_namespace" {
  description = "ARC Namespace"
  value       = module.arc_namespace.namespace_name
}
