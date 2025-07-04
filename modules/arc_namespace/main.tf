resource "kubernetes_namespace" "arc" {
  metadata {
    name = "arc"
    labels = { provisioned_by = "terraform" }
  }
}
