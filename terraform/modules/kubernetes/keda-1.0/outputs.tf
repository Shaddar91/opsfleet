output "role_arn" {
  description = "IAM role of the KEDA operator"
  value       = module.keda_role.role_arn
}

output "namespace" {
  description = "Namespace of the KEDA release"
  value       = local.namespace
}
