resource "helm_release" "arc_systems" {
  name       = "arc-systems"
  namespace  = var.namespace
  chart      = "gha-runner-scale-set-controller"
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  version    = "0.12.1"

  values = [yamlencode({
    metrics = {
      controllerManagerAddr = ":8080"
      listenerAddr          = ":8080"
      listenerEndpoint      = "/metrics"
    }
    podAnnotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = "8080"
      "prometheus.io/path"   = "/metrics"
      "prometheus.io/scheme" = "http"
    }
  })]

}
