output "cluster" {
  value = aws_eks_cluster.main
}
output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}
output "cluster_arn" {
  value = aws_eks_cluster.main.arn
}
output "public_endpoint" {
  value = aws_eks_cluster.main.endpoint
}
output "cluster_name" {
  value = aws_eks_cluster.main.name
}
output "cluster_version" {
  value = aws_eks_cluster.main.version
}
output "cluster_security_group_id" {
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description = "The EKS-created cluster security group; sg_id is the node security group"
}

output "eks_role_arn" {
  value = var.cluster_role_arn
}

output "eks_node_role_arn" {
  value = var.node_role_arn
}

output "node_role_name" {
  value = local.node_role_name
}

output "sg_id" {
  value = module.ec2_sg.sg.id
}
output "sg" {
  value = module.ec2_sg
}

output "tg_names" {
  value = {
    for k, lt in aws_launch_template.main : k => (
      lookup(lt.tag_specifications[0].tags, "Name", "default-value")
    )
  }
}


output "asg_names" {
  value = {
    for k, ng in aws_eks_node_group.main : k => (
      try(ng.resources[0].autoscaling_groups[0].name, null)
    )
  }
}


output "cluster_oidc" {
  value = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "certificate_authority" {
  value     = aws_eks_cluster.main.certificate_authority[0].data
  sensitive = true
}

output "addon_versions" {
  value       = { for name, addon in merge(aws_eks_addon.before_compute, aws_eks_addon.after_compute) : name => addon.addon_version }
  description = "Installed version per managed add-on; pin these in tfvars after the first apply"
}

output "oidc_k8_provider_arn" {
  value       = aws_iam_openid_connect_provider.k8_oidc.arn
  description = "The ARN of the OIDC provider for EKS"
}

output "oidc_k8_provider_id" {
  value       = aws_iam_openid_connect_provider.k8_oidc.id
  description = "The ID of the OIDC provider for EKS"
}
output "oidc_k8_provider_url" {
  value       = aws_iam_openid_connect_provider.k8_oidc.url
  description = "The URL of the OIDC provider for EKS"
}
