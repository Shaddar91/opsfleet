output "application_name" {
  description = "Argo CD Application name, also the Helm release and so the chart's Service, service account and SecretProviderClass name"
  value       = module.service.application_name
}

output "app_secret_arn" {
  description = "ARN of the app settings secret"
  value       = module.app_secret.arn
}

output "secrets_role_arn" {
  description = "Role the stress API pods assume by Pod Identity to read their secret"
  value       = module.secrets_role.role_arn
}
