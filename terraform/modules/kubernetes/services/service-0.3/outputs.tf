output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}

output "target_group_name" {
  value = aws_lb_target_group.this.name
}

output "fqdn" {
  value = var.fqdn
}

output "certificate_arn" {
  value = var.create_certificate ? module.certificate.validated_arn : null
}

output "listener_rule_arn" {
  value = aws_lb_listener_rule.this.arn
}

output "application_name" {
  value = local.name
}

output "namespace" {
  value = kubernetes_namespace_v1.this.metadata[0].name
}
