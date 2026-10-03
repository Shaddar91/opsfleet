output "function_name" {
  description = "Name of the function"
  value       = aws_lambda_function.main.function_name
}

output "function_arn" {
  description = "ARN of the function"
  value       = aws_lambda_function.main.arn
}

output "invoke_arn" {
  description = "Invoke ARN of the function, for API Gateway and EventBridge targets"
  value       = aws_lambda_function.main.invoke_arn
}

output "role_arn" {
  description = "ARN of the execution role"
  value       = module.role.role_arn
}

output "log_group_name" {
  description = "Name of the function's log group"
  value       = aws_cloudwatch_log_group.main.name
}
