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
  value = module.ec2
}

output "aws_internet_gateway" {
  value = aws_internet_gateway.main.id
}


output "bastion_public_ip" {
  value = module.ec2.public_ip
}

output "bastion_private_ip" {
  value = module.ec2.private_ip
}

output "ec2_id" {
  value = module.ec2.ec2_id
}

output "ec2_sg" {
  value = module.ec2_sg.sg
}

output "aws_nat_gateway" {
  value = aws_nat_gateway.main.id
}

output "internal_zone" {
  value = var.create_internal_hosted_zone ? aws_route53_zone.internal_zone : null
}

output "internal_zone_id" {
  value = var.create_internal_hosted_zone ? aws_route53_zone.internal_zone[0].id : null
}

//=============================================================================
// Transit Gateway Outputs
//=============================================================================

output "tgw_attachment_id" {
  description = "Transit Gateway VPC Attachment ID (null if not enabled)"
  value       = var.enable_tgw_attachment ? aws_ec2_transit_gateway_vpc_attachment.main[0].id : null
}

output "tgw_attachment_state" {
  description = "Transit Gateway VPC Attachment state (null if not enabled)"
  value       = var.enable_tgw_attachment ? aws_ec2_transit_gateway_vpc_attachment.main[0].state : null
}