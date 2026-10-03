output "application_name" {
  description = "Argo CD Application name, also the Helm release and so the chart's Service, service account and SecretProviderClass name"
  value       = module.service.application_name
}

output "namespace" {
  description = "Namespace the API runs in"
  value       = module.service.namespace
}

output "service_url" {
  description = "In-cluster URL of the API on its ClusterIP Service, port 80; of-load checks bearer tokens against it"
  value       = "http://${module.service.application_name}.${module.service.namespace}.svc.cluster.local"
}

output "app_secret_arn" {
  description = "ARN of the app settings secret"
  value       = module.app_secret.arn
}

output "secrets_role_arn" {
  description = "Role the API pods assume by Pod Identity to read their secrets"
  value       = module.secrets_role.role_arn
}
