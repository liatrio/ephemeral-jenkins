locals {
  jaeger_zipkin_port = 9411
  jaeger_query_port = 16686
}
resource "helm_release" "jeager" {
  count      = var.enabled ? 1 : 0
  name       = "jaeger"
  version    = var.chart_version
  namespace  = var.namespace
  chart      = var.chart_name
  repository = var.repository
  timeout    = "600"

  values = [
    templatefile("${var.chart_values}", {
      jaeger_zipkin_port = local.jaeger_zipkin_port
      jaeger_query_port  = local.jaeger_query_port
    })
  ]
}

