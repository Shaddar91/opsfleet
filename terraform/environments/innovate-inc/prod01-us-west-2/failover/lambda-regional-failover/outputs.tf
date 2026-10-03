output "function_name" {
  description = "Name of the failover function, for aws lambda invoke"
  value       = module.failover.function_name
}

output "function_arn" {
  description = "ARN of the failover function, the target of an alarm rule"
  value       = module.failover.function_arn
}

output "config_secret_arn" {
  description = "ARN of the secret holding the function's targets"
  value       = module.config.arn
}
