output "arn" {
  value = var.enabled ? aws_acm_certificate.main[0].arn : null
}

output "validated_arn" {
  value = var.enabled ? aws_acm_certificate_validation.main[0].certificate_arn : null
}