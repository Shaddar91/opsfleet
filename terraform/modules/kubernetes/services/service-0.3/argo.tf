resource "kubernetes_namespace_v1" "this" {
  metadata {
    name   = var.namespace
    labels = merge(var.namespace_labels, { "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled" })
  }
}

resource "terraform_data" "chart" {
  input = var.chart_files
}

resource "kubectl_manifest" "application" {
  yaml_body = templatefile(var.argo_application_path, {
    NAME             = local.name
    ARGOCD_NAMESPACE = var.argocd_namespace
    PROJECT          = var.argocd_project
    REPO_URL         = var.repo_url
    TARGET_REVISION  = var.target_revision
    CHART_PATH       = var.chart_path
    ARCHITECTURE     = var.architecture
    NAMESPACE        = kubernetes_namespace_v1.this.metadata[0].name
    TARGET_GROUP_ARN = aws_lb_target_group.this.arn
    CONTAINER_PORT   = var.container_port
  })
  wait       = true
  depends_on = [terraform_data.chart]
}
