output "queue_name" {
  description = "Interruption queue name, Karpenter's settings.interruptionQueue"
  value       = module.interruption_queue.name
}

output "controller_role_arn" {
  description = "ARN of the Karpenter controller role, bound to kube-system/karpenter by Pod Identity"
  value       = module.karpenter_controller_role.role_arn
}
