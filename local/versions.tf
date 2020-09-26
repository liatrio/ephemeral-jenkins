terraform {
  required_version = ">= 0.13"
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "1.3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
