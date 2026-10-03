output "vpc_id" {
  description = "Id of the prod01-usw2 VPC"
  value       = module.network.vpc.id
}

output "vpc_cidr" {
  description = "CIDR of the prod01-usw2 VPC"
  value       = module.network.vpc.cidr_block
}

output "azs" {
  description = "AZ names the subnet tiers span, index-aligned with every subnet list"
  value       = local.azs
}

output "public_subnets" {
  description = "Public subnet ids (ALBs, NAT), one per AZ"
  value       = module.network.public_subnets[*].id
}

output "private_subnets" {
  description = "Private subnet ids (EKS nodes and pods), one per AZ"
  value       = module.network.private_subnets[*].id
}

output "internal_subnets" {
  description = "Internal subnet ids, no default route, one per AZ"
  value       = module.network.internal_subnets[*].id
}

output "nat_public_ips" {
  description = "Public IPs of the NAT gateways, the VPC's egress addresses"
  value       = module.network.nat_gateway_public_ip
}

output "bastion_sg_id" {
  description = "Security group id of the bastion"
  value       = module.network.ec2_sg.id
}

output "bastion_instance_id" {
  description = "Instance id of the bastion, the SSM Session Manager target"
  value       = module.network.ec2_id
}

output "cluster_name" {
  description = "EKS cluster name the subnet discovery tags point at"
  value       = var.cluster_name
}
