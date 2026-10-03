output "alb_arn" {
  description = "ARN of the edge ALB, the Global Accelerator endpoint"
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "DNS name of the edge ALB"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Route53 zone id of the edge ALB, for alias records"
  value       = module.alb.alb_zone_id
}

output "alb_security_group_id" {
  description = "Security group of the edge ALB, to admit on the pod ports: 8000 for traffic, 8080 for health checks"
  value       = module.alb.sg_id
}

output "listener_https_arn" {
  description = "ARN of the HTTPS listener that listener rules attach to"
  value       = module.alb.https_listener_arn
}

output "ingress_target_group_arn" {
  description = "ARN of the ip target group the in-cluster TargetGroupBinding fills with Traefik pods"
  value       = aws_lb_target_group.ingress.arn
}

output "waf_acl_arn" {
  description = "ARN of the WAF web ACL associated with the edge ALB"
  value       = module.alb.waf_web_acl_arn
}

output "app_fqdn" {
  description = "Hostname the certificate, the host rule and the Global Accelerator record share"
  value       = local.app_fqdn
}

output "global_accelerator_endpoint_group_arn" {
  description = "ARN of this region's endpoint group on the accelerator, whose traffic dial the regional failover Lambda sets"
  value       = module.alb.global_accelerator_endpoint_group_arn
}
