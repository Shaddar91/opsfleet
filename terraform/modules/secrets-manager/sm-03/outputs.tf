#Secrets Manager module outputs.
output "secrets_manager" {
  description = "Secret identifiers for downstream consumers."
  value = {
    arn  = aws_secretsmanager_secret.main.arn
    name = aws_secretsmanager_secret.main.name
  }
}

output "arn" {
  description = "ARN of the managed secret."
  value       = aws_secretsmanager_secret.main.arn
}

output "name" {
  description = "Name of the managed secret."
  value       = aws_secretsmanager_secret.main.name
}
