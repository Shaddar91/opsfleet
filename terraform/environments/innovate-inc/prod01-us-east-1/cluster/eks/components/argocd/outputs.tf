output "argocd_namespace" {
  description = "Namespace Argo CD runs in; argocd-configuration targets it"
  value       = helm_release.argo_cd.namespace
}

output "argocd_host" {
  description = "Host of the Argo CD UI"
  value       = local.argocd_host
}
