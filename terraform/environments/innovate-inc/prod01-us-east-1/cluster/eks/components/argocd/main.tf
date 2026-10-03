#Argo CD on the ALB ingress; its repository, projects and applications come from the argocd-configuration stack, applied after this one.

resource "helm_release" "argo_cd" {
  name             = "argocd"
  repository       = var.argocd_chart_repository
  chart            = "argo-cd"
  version          = var.argo_cd_chart_version
  namespace        = var.argocd_namespace
  create_namespace = true
  values = [templatefile("${path.module}/files/values/argo-cd.yaml", {
    ARGOCD_HOST     = local.argocd_host
    CERTIFICATE_ARN = module.argocd_certificate.validated_arn
    ALB_GROUP       = local.cluster_name
  })]
}
