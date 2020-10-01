### Toolchain ########
downscaler_enabled      = true
harbor_enabled          = false
jaeger_enabled          = false
kube-janitor_enabled    = true
######################

downscaler_values       = "./toolchain/downscaler.tpl"
downscaler_version      = "0.4.0"
downscaler_chart        = "incubator/kube-downscaler"
downscaler_repository   = "incubator" # http://storage.googleapis.com/kubernetes-charts-incubator

harbor_values           = "./toolchain/harbor.tpl"
harbor_version          = "1.4.0"
harbor_chart            = "harbor"
harbor_repository       = "harbor" # https://helm.goharbor.io

jaeger_values           = "./toolchain/jaeger.tpl"
jaeger_version          = "2.15.1"
jaeger_chart            = "jaegertracing/jaeger-operator"
jaeger_repository       = "jaegertracing" # https://jaegertracing.github.io/helm-charts

kube-janitor_values     = "./toolchain/kube-janitor.tpl"
kube-janitor_version    = "0.1.0"
kube-janitor_chart      = "themagicalkarp/kube-janitor"
kube-janitor_repository = "themagicalkarp" # https://themagicalkarp.github.io/charts
