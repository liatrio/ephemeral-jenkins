resource "helm_release" "kube-janitor" {
  count      = var.enabled ? 1 : 0
  name       = "kube-janitor"
  version    = var.chart_version
  namespace  = var.namespace
  chart      = var.chart_name
  repository = var.repository
  timeout    = 600

  #values     = [var.essential_toleration_values]
  values = [
    templatefile("${var.chart_values}", {})
  ]

  #set {
  #  name  = "kubejanitor.expiration"
  #  value = 15
  #}
}
