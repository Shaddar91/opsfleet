output "alb_tg" {
  value = aws_lb_target_group.alb_tg
}

output "cert" {
  value = aws_lb_listener_certificate.cert
}

output "rule" {
  value = aws_lb_listener_rule.rule
}