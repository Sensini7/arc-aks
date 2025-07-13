resource "helm_release" "arc_runner_scale_set" {
  name       = var.release_name
  namespace  = var.namespace
  chart      = "gha-runner-scale-set"
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  version    = var.chart_version

  values = [yamlencode({
    githubConfigUrl    = var.github_config_url
    githubConfigSecret = var.github_config_secret_name
    runnerGroup        = var.runner_group
    minRunners         = var.min_runners
    maxRunners         = var.max_runners
    
    template = {
      spec = {
        containers = [{
          name    = "runner"
          image   = var.runner_image
          command = ["/home/runner/run.sh"]
        }]
      }
    }
  })]

  depends_on = [var.namespace_depends_on]
}