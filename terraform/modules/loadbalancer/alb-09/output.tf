#----------------------------------------------------------
#ALB Outputs
#----------------------------------------------------------

output "alb" {
  description = "The ALB resource"
  value       = aws_lb.main
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.main.arn
}

output "alb_id" {
  description = "ID of the ALB (use this for GA endpoint attachment)"
  value       = aws_lb.main.id
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB (for Route53 alias records)"
  value       = aws_lb.main.zone_id
}

#----------------------------------------------------------
#Listener Outputs
#----------------------------------------------------------

output "http_listener" {
  description = "HTTP listener (redirects to HTTPS)"
  value       = var.accept_http ? aws_lb_listener.http[0] : null
}

output "http_listener_arn" {
  description = "ARN of HTTP listener"
  value       = var.accept_http ? aws_lb_listener.http[0].arn : null
}

output "https_listener" {
  description = "HTTPS listener"
  value       = aws_lb_listener.https
}

output "https_listener_arn" {
  description = "ARN of HTTPS listener (use this for listener rules)"
  value       = aws_lb_listener.https.arn
}

#----------------------------------------------------------
#Security Group Outputs
#----------------------------------------------------------

output "sg" {
  description = "ALB security group"
  value       = module.alb_sg.sg
}

output "sg_id" {
  description = "ALB security group ID"
  value       = module.alb_sg.sg.id
}

#----------------------------------------------------------
#S3 Logging Outputs
#----------------------------------------------------------

output "log_bucket" {
  description = "S3 bucket for ALB logs"
  value       = module.alb_log_bucket.s3
}

output "log_bucket_name" {
  description = "Name of S3 bucket for ALB logs"
  value       = module.alb_log_bucket.s3.bucket
}

#----------------------------------------------------------
#WAF Outputs
#----------------------------------------------------------

output "waf_enabled" {
  description = "Whether WAF is enabled"
  value       = var.enable_waf
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL (null if WAF disabled)"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].arn : null
}

output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL (null if WAF disabled)"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].id : null
}

#----------------------------------------------------------
#Certificate Outputs
#----------------------------------------------------------

output "certificate_arn" {
  description = "ARN of the ACM certificate (null if using existing certificate)"
  value       = length(module.cert) > 0 ? module.cert[0].arn : var.certificate_arn
}

#----------------------------------------------------------
#Global Accelerator Outputs
#----------------------------------------------------------

output "global_accelerator_created" {
  description = "Whether Global Accelerator was created in this module"
  value       = var.create_global_accelerator
}

output "global_accelerator_arn" {
  description = "ARN of the Global Accelerator (null if not created)"
  value       = var.create_global_accelerator ? aws_globalaccelerator_accelerator.main[0].id : null
}

output "global_accelerator_dns_name" {
  description = "DNS name of the Global Accelerator (null if not created)"
  value       = var.create_global_accelerator ? aws_globalaccelerator_accelerator.main[0].dns_name : null
}

output "global_accelerator_hosted_zone_id" {
  description = "Hosted zone ID of the Global Accelerator (null if not created)"
  value       = var.create_global_accelerator ? aws_globalaccelerator_accelerator.main[0].hosted_zone_id : null
}

output "global_accelerator_ip_sets" {
  description = "IP sets of the Global Accelerator (null if not created)"
  value       = var.create_global_accelerator ? aws_globalaccelerator_accelerator.main[0].ip_sets : null
}

output "global_accelerator_listener_arn" {
  description = "ARN of the Global Accelerator listener (null if not created)"
  value       = var.create_global_accelerator ? aws_globalaccelerator_listener.main[0].id : null
}

output "global_accelerator_endpoint_group_arn" {
  description = "ARN of the Global Accelerator endpoint group (null if not created)"
  value       = var.create_global_accelerator ? aws_globalaccelerator_endpoint_group.main[0].id : null
}

#----------------------------------------------------------
#Configuration Info
#----------------------------------------------------------

output "is_internal" {
  description = "Whether the ALB is internal (private)"
  value       = var.internal
}

output "route53_record_created" {
  description = "Whether Route53 record was created in this module"
  value       = var.create_route53_record
}

output "using_external_global_accelerator" {
  description = "Whether Route53 points to external Global Accelerator"
  value       = var.use_external_global_accelerator
}

#----------------------------------------------------------
#Route53 Target Info (useful for debugging/external management)
#----------------------------------------------------------

output "route53_target_dns" {
  description = "The DNS name that Route53 points to (GA or ALB depending on config)"
  value       = local.route53_target_dns
}

output "route53_target_zone_id" {
  description = "The hosted zone ID that Route53 uses for alias (GA or ALB depending on config)"
  value       = local.route53_target_zone
}
