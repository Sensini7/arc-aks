output "secret_name" {
  value = kubernetes_secret.github_runner_config.metadata[0].name
}
