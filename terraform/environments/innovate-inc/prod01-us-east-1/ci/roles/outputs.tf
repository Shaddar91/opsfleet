output "role_arns" {
  description = "CI role ARN per repo, keyed by repo name: the AWS_ROLE_ARN secret the github-actions stack sets"
  value       = { for repo, role in module.role : repo => role.role_arn }
}
