output "alb_arn" {
  description = "ARN of the internal ALB"
  value       = aws_lb.internal.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the internal ALB, the LoadBalancer dimension of its CloudWatch metrics"
  value       = aws_lb.internal.arn_suffix
}

output "alb_dns_name" {
  description = "DNS name of the internal ALB; it resolves to private IPs only"
  value       = aws_lb.internal.dns_name
}

output "listener_http_arn" {
  description = "ARN of the HTTP listener that service listener rules attach to"
  value       = aws_lb_listener.http.arn
}

output "security_group_id" {
  description = "Security group of the internal ALB, to admit on the pod ports: 8000 for traffic, 8080 for health checks"
  value       = aws_security_group.alb.id
}

output "internal_ingress_target_group_arn" {
  description = "ARN of the ip target group the in-cluster TargetGroupBinding fills with Traefik pods"
  value       = aws_lb_target_group.internal_ingress.arn
}
