output "name" {
  value       = aws_iam_group.main.name
  description = "The name of the IAM group"
}

output "group_name" {
  value       = aws_iam_group.main.name
  description = "The name of the IAM group (alias of `name`)"
}

output "arn" {
  value       = aws_iam_group.main.arn
  description = "The ARN of the IAM group"
}

output "id" {
  value       = aws_iam_group.main.id
  description = "The ID of the IAM group"
}

output "path" {
  value       = aws_iam_group.main.path
  description = "The path of the IAM group"
}
