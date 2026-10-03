output "release_name" {
  description = "Helm release name of Traefik"
  value       = helm_release.traefik.name
}

output "namespace" {
  description = "Namespace Traefik runs in"
  value       = helm_release.traefik.namespace
}

output "chart_version" {
  description = "Installed traefik chart version"
  value       = helm_release.traefik.version
}

output "status" {
  description = "Helm release status; deployed once the release is healthy"
  value       = helm_release.traefik.status
}

output "service_name" {
  description = "ClusterIP Service the TargetGroupBindings reference"
  value       = local.service_name
}

output "target_group_bindings" {
  description = "TargetGroupBinding name per ALB, public (edge) and internal"
  value       = { for alb, tgb in kubectl_manifest.target_group_binding : alb => tgb.name }
}
