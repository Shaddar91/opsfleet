output "qualified_arn" {
  description = "ARN with the published version, the one a CloudFront lambda_function_association takes"
  value       = aws_lambda_function.main.qualified_arn
}

output "arn" {
  description = "Unqualified function ARN"
  value       = aws_lambda_function.main.arn
}

output "version" {
  description = "Published version"
  value       = aws_lambda_function.main.version
}

output "function_name" {
  description = "Function name"
  value       = aws_lambda_function.main.function_name
}

output "role_arn" {
  description = "Execution role ARN"
  value       = module.role.role_arn
}
