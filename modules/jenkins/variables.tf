variable "product_name" {
  default = "springtrader-marketsummary"
}

variable "pipelines" {
  default = [{
    repo = "springtrader-marketsummary",
    org  = "liatrio"
  }]
}

variable "plugins" {
  default = [
    "job-dsl:1.77"
  ]
}

variable "pod_template" {}
