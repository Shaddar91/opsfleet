//Argo CD deploys the app: its namespace, the chart files as a change trigger, and the Application; off for components Terraform deploys itself.
resource "kubectl_manifest" "application" {
  count = var.create_argocd_application ? 1 : 0

  yaml_body = templatefile(var.argo_application_path, {
    NAME             = local.name
    ARGOCD_NAMESPACE = var.argocd_namespace
    PROJECT          = var.argocd_project
    REPO_URL         = var.repo_url
    TARGET_REVISION  = var.target_revision
    CHART_PATH       = var.chart_path
    ARCHITECTURE     = var.architecture
    NAMESPACE        = kubernetes_namespace_v1.this[0].metadata[0].name
    TARGET_GROUP_ARN = aws_lb_target_group.this.arn
    CONTAINER_PORT   = var.container_port
    IMAGE_REPOSITORY = var.image_repository
  })
  wait       = true
  depends_on = [terraform_data.chart]

  lifecycle {
    precondition {
      condition     = alltrue([for v in [var.argo_application_path, var.argocd_namespace, var.repo_url, var.target_revision, var.chart_path, var.architecture] : v != null])
      error_message = "create_argocd_application needs argo_application_path, argocd_namespace, repo_url, target_revision, chart_path and architecture."
    }
  }
}

resource "kubernetes_namespace_v1" "this" {
  count = var.create_argocd_application ? 1 : 0

  metadata {
    name   = var.namespace
    labels = merge(var.namespace_labels, { "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled" })
  }
}

resource "terraform_data" "chart" {
  count = var.create_argocd_application ? 1 : 0

  input = var.chart_files
}

