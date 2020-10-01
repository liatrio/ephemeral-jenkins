##### Downscaler ###############
variable "downscaler_enabled" {
  default = false
}
variable "downscaler_values" {
}
variable "downscaler_version" {
  type = string
}
variable "downscaler_chart" {
  type = string
}
variable "downscaler_repository" {
  type = string
}
############################

##### Harbor ###############
variable "harbor_enabled" {
  default = false
}
variable "harbor_values" {
}
variable "harbor_version" {
  type = string
}
variable "harbor_chart" {
  type = string
}
variable "harbor_repository" {
  type = string
}
############################

##### Jaeger ###############
variable "jaeger_enabled" {
  default = false
}
variable "jaeger_values" {
}
variable "jaeger_version" {
  type = string
}
variable "jaeger_chart" {
  type = string
}
variable "jaeger_repository" {
  type = string
}
############################

##### Kube Janitor #########
variable "kube-janitor_enabled" {
  default = false
}
variable "kube-janitor_values" {
}
variable "kube-janitor_version" {
  type = string
}
variable "kube-janitor_chart" {
  type = string
}
variable "kube-janitor_repository" {
  type = string
}
############################
