resource "helm_release" "kube_downscaler" {
  count      = var.enabled ? 1 : 0
  name       = "kube-downscaler"
  version    = var.chart_version
  namespace  = var.namespace
  chart      = var.chart_name
  repository = var.repository
  timeout    = 600

  values = [
    templatefile("${var.chart_values}", {})
  ]
}
