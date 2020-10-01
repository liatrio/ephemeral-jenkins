resource "kubernetes_namespace" "toolchain_ns" {
  count = 1
  metadata {
    name = "toolchain"
  }
}

module "downscaler" {
  source         = "../modules/common/downscaler"
  enabled        = var.downscaler_enabled
  chart_values   = var.downscaler_values
  chart_version  = var.downscaler_version
  namespace      = kubernetes_namespace.toolchain_ns[0].metadata[0].name
  chart_name     = var.downscaler_chart
  repository     = var.downscaler_repository
}

module "harbor" {
  source         = "../modules/common/harbor"

  enabled        = var.harbor_enabled
  chart_values   = var.harbor_values
  chart_version  = var.harbor_version
  namespace      = kubernetes_namespace.toolchain_ns[0].metadata[0].name
  chart_name     = var.harbor_chart
  repository     = var.harbor_repository
}

module "jaeger" {
  source         = "../modules/common/jaeger"

  enabled        = var.jaeger_enabled
  chart_values   = var.jaeger_values
  chart_version  = var.jaeger_version
  namespace      = kubernetes_namespace.toolchain_ns[0].metadata[0].name
  chart_name     = var.jaeger_chart
  repository     = var.jaeger_repository
}

module "kube-janitor" {
  source = "../modules/common/kube-janitor"

  enabled        = var.kube-janitor_enabled
  chart_values   = var.kube-janitor_values
  chart_version  = var.kube-janitor_version
  namespace      = kubernetes_namespace.toolchain_ns[0].metadata[0].name
  chart_name     = var.kube-janitor_chart
  repository     = var.kube-janitor_repository
}
