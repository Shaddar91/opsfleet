output "release_name" {
  description = "Helm release name of metrics-server"
  value       = helm_release.metrics_server.name
}

output "namespace" {
  description = "Namespace metrics-server runs in"
  value       = helm_release.metrics_server.namespace
}

output "chart_version" {
  description = "Installed metrics-server chart version"
  value       = helm_release.metrics_server.version
}

output "status" {
  description = "Helm release status; deployed once the release is healthy"
  value       = helm_release.metrics_server.status
}
