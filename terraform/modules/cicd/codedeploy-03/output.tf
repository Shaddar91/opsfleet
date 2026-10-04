output "deployment_group" {
  value = aws_codedeploy_deployment_group.main
}

output "app" {
  value = aws_codedeploy_app.main
}

output "app_arn" {
  value = aws_codedeploy_app.main.arn
}