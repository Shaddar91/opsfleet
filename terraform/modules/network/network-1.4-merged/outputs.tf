output "vpc" {
  value = aws_vpc.main
}

output "private_subnets" {
  value = aws_subnet.private
}

output "public_subnets" {
  value = aws_subnet.public
}

output "bastion_subnets" {
  value = aws_subnet.bastion
}

output "internal_subnets" {
  value = aws_subnet.internal
}

output "lambda_subnets" {
  value = aws_subnet.lambda
}

output "private_rt_table" {
  value = aws_route_table.nat.id
}

output "public_rt_table" {
  value = aws_route_table.public.id
}

output "internal_rt_table" {
  value = aws_route_table.internal.id
}

output "ec2_vpce_sg_id" {
  value = length(module.ec2) > 0 ? module.ec2[0] : null
}

output "aws_internet_gateway" {
  value = aws_internet_gateway.main.id
}


output "bastion_public_ip" {
  value = length(module.ec2) > 0 ? module.ec2[0].public_ip : null
}

output "bastion_private_ip" {
  value = length(module.ec2) > 0 ? module.ec2[0].private_ip : null
}

output "ec2_id" {
  value = length(module.ec2) > 0 ? module.ec2[0].ec2_id : null
}

output "ec2_sg" {
  value = length(module.ec2_sg) > 0 ? module.ec2_sg[0].sg : null
}

output "ec2_bastion_role_name" {
  value = length(module.ec2) > 0 ? module.ec2[0].iam_role.name : null
}

output "ec2_bastion_role_arn" {
  value = length(module.ec2) > 0 ? module.ec2[0].iam_role.arn : null
}

output "aws_nat_gateway" {
  description = "NAT Gateway ID (null if create_nat_gateway is false)"
  value       = var.create_nat_gateway ? aws_nat_gateway.main[0].id : null
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway public IP (null if create_nat_gateway is false)"
  value       = var.create_nat_gateway ? aws_eip.nat[0].public_ip : null
}

output "internal_zone" {
  value = var.create_internal_hosted_zone ? aws_route53_zone.internal_zone : null
}

output "internal_zone_id" {
  value = var.create_internal_hosted_zone ? aws_route53_zone.internal_zone[0].id : null
}

output "flow_logs_log_group_arn" {
  description = "CloudWatch log group ARN for VPC flow logs"
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "flow_logs_iam_role_arn" {
  description = "IAM role ARN for VPC flow logs"
  value       = var.flow_logs_iam_role_arn != null ? var.flow_logs_iam_role_arn : module.flow_logs_role[0].role_arn
}

output "flow_logs_kms_key_arn" {
  description = "KMS key ARN for flow logs encryption (null if not enabled or using external key)"
  value       = var.flow_logs_kms_encryption && var.flow_logs_kms_key_id == null ? aws_kms_key.flow_logs[0].arn : null
}

output "s3_endpoint_id" {
  description = "S3 Gateway Endpoint ID (null if not enabled)"
  value       = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].id : null
}

output "ec2_endpoint_sg_id" {
  description = "Security group ID of the EC2 interface endpoint (null if not enabled)"
  value       = var.enable_ec2_endpoint ? module.ec2_endpoint_sg[0].sg_id : null
}

output "tgw_attachment_id" {
  description = "Transit Gateway VPC Attachment ID (null if not enabled)"
  value       = var.enable_tgw_attachment ? aws_ec2_transit_gateway_vpc_attachment.main[0].id : null
}
