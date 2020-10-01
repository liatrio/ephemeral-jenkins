resource "helm_release" "harbor" {
  count      = var.enabled ? 1 : 0
  name       = "harbor"
  namespace  = var.namespace
  version    = var.chart_version
  chart      = var.chart_name
  repository = var.repository
  timeout    = 600

  values = [
    templatefile("${var.chart_values}", {})
  ]
}
