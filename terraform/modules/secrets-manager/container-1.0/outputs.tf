output "name" {
  description = "Secret name"
  value       = aws_secretsmanager_secret.main.name
}

output "arn" {
  description = "Secret ARN"
  value       = aws_secretsmanager_secret.main.arn
}
