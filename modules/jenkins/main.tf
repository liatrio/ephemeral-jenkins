//resource "random_password" "jenkins_admin_password" {
//  length  = 10
//  special = false
//}

module "jenkins_namespace" {
  source    = "../common/namespace"
  namespace = "${var.product_name}-jenkins"
  annotations = {
    name                                 = "${var.product_name}-jenkins"
  }
  resource_request_cpu = "100m"
  resource_limit_cpu   = "250m"

}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  chart      = "jenkins"
  repository = "https://charts.jenkins.io"
  namespace  = module.jenkins_namespace.name
  timeout    = "600"
  version    = "2.7.0"

  //set_sensitive {
  //  name  = "master.adminPassword"
  //  value = random_password.jenkins_admin_password.result
  //}

  values = [data.template_file.jenkins_values.rendered]
}

resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "${var.product_name}-jenkins"
    namespace = module.jenkins_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

  }

  automount_service_account_token = true
}

resource "kubernetes_role" "jenkins_kubernetes_credentials" {
  metadata {
    name      = "jenkins-kubernetes-credentials"
    namespace = module.jenkins_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Jenkins' Kubernetes Credentials plugin to read secrets"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "watch", "list"]
  }
  rule {
    api_groups = ["stable.liatr.io", "sdm.liatr.io"]
    resources  = ["builds"]
    verbs      = ["create", "update", "patch", "get", "watch", "list"]
  }
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "get", "watch", "list"]
  }
}

data "template_file" "jenkins_values" {
  template = file("${path.module}/jenkins-values.tpl")

  vars = {
    product_name = var.product_name
    plugins      = join(",", var.plugins)
  }
}

// Bind Kubernetes secrets role to Jenkins service account
resource "kubernetes_role_binding" "jenkins_kubernetes_credentials" {
  metadata {
    name      = "jenkins-kubernetes-credentials"
    namespace = module.jenkins_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.jenkins_kubernetes_credentials.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = module.jenkins_namespace.name
  }
}

resource "kubernetes_cluster_role" "jenkins_kubernetes_credentials" {
  metadata {
    name = "${var.product_name}-jenkins-kubernetes-credentials"

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Jenkins' Kubernetes Credentials plugin to manage builds"
    }
  }

  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["create", "get", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "jenkins_kubernetes_credentials" {
  metadata {
    name = "${var.product_name}-jenkins-kubernetes-credentials"

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Jenkins' Kubernetes Credentials plugin to read secrets"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.jenkins_kubernetes_credentials.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = module.jenkins_namespace.name
  }
}

resource "kubernetes_role" "ci_role" {
  metadata {
    name      = "ci-production-role"
    namespace = module.jenkins_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "ci"
      "app.kubernetes.io/instance"   = "ci"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Continous Integration tools to get pods in production namespace"
    }
  }

  rule {
    api_groups = ["", "extensions", "apps", "batch"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["networking.istio.io"]
    resources  = ["*"]
    verbs      = ["list", "watch", "create", "patch", "get", "delete", "update"]
  }

  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["*"]
  }

}

resource "kubernetes_role_binding" "jenkins_ci_rolebinding" {
  metadata {
    name      = "jenkins-ci-rolebinding"
    namespace = module.jenkins_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
    }

    annotations = {
      description = "Permission required for Jenkins' to get pods in production namespace"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.ci_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = module.jenkins_namespace.name
  }
}

resource "kubernetes_config_map" "jcasc_pipelines_configmap" {
  metadata {
    name      = "jenkins-casc"
    namespace = module.jenkins_namespace.name

    labels = {
      "jenkins-jenkins-config"       = "true"
    }
  }
  data = {
    "jobs.yaml" = trim(replace(jsonencode(chomp(replace(templatefile("${path.module}/pipelines.tpl", {pipelines=var.pipelines}), "/,]}$/", "]}"))), "/\\\\\"/", "\""), "\"")
  }
}

resource "kubernetes_config_map" "jcasc_shared_libraries_configmap" {
  metadata {
    name      = "jenkins-jenkins-config-shared-libraries"
    namespace = module.jenkins_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
      "jenkins-jenkins-config"       = "true"
    }
  }
  data = {
    "shared-libraries.yaml" = templatefile("${path.module}/shared-libraries.tpl", {})
  }
}

resource "kubernetes_config_map" "jcasc_pod_templates_configmap" {
  metadata {
    name      = "jenkins-jenkins-config-pod-templates"
    namespace = module.jenkins_namespace.name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/instance"   = "jenkins"
      "app.kubernetes.io/component"  = "jenkins-master"
      "app.kubernetes.io/managed-by" = "Terraform"
      "jenkins-jenkins-config"       = "true"
    }
  }
  data = {
    "pod-templates.yaml" = templatefile("${path.module}/pod-templates.tpl", {
      namespace = module.jenkins_namespace.name
    })
  }
}
