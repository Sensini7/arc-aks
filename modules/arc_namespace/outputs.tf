output "namespace_name" {
  value = kubernetes_namespace.arc.metadata[0].name
}
