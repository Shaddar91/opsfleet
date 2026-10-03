output "plan_role_arn" {
  description = "Role the plan job assumes: ReadOnlyAccess, default branch only"
  value       = module.plan_role.role_arn
}

output "apply_role_arn" {
  description = "Role the apply job assumes: AdministratorAccess, approval environment only"
  value       = module.apply_role.role_arn
}
