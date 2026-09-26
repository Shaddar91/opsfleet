output "role" {
  value = aws_iam_role.main
}
output "instance_profile" {
  value = aws_iam_instance_profile.main
}
output "role_arn" {
  value = aws_iam_role.main.arn
}
output "role_name" {
  value = aws_iam_role.main.name
}