resource "kubernetes_secret" "github_runner_config" {
  metadata {
    name      = "github-config"
    namespace = var.namespace
  }

  string_data = {
    github_app_id              = var.github_app_id
    github_app_installation_id = var.github_app_installation_id
    github_app_private_key     = var.github_app_private_key
  }
  type = "Opaque"
}
