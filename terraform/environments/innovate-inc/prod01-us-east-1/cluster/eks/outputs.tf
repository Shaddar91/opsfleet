output "cluster" {
  description = "The whole aws_eks_cluster object"
  value       = module.eks.cluster
}

output "cluster_name" {
  description = "EKS cluster name, also the karpenter.sh/discovery value"
  value       = module.eks.cluster_name
}

output "eks_cluster_name" {
  description = "EKS cluster name, under the module's second name"
  value       = module.eks.eks_cluster_name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "cluster_version" {
  description = "Kubernetes minor version of the control plane"
  value       = module.eks.cluster_version
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint, the host of the components tier's providers"
  value       = module.eks.public_endpoint
}

output "public_endpoint" {
  description = "Kubernetes API server endpoint, under the module's name"
  value       = module.eks.public_endpoint
}

output "cluster_ca" {
  description = "Base64 cluster CA certificate data; the components tier decodes it"
  value       = module.eks.certificate_authority
  sensitive   = true
}

output "certificate_authority" {
  description = "Base64 cluster CA certificate data, under the module's name"
  value       = module.eks.certificate_authority
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "EKS-created cluster security group, tagged karpenter.sh/discovery; Karpenter nodes carry only this one"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Node security group the module adds to managed node groups: ingress from the VPC CIDR only"
  value       = module.eks.sg_id
}

output "sg_id" {
  description = "Node security group id, under the module's name"
  value       = module.eks.sg_id
}

output "sg" {
  description = "The node security group module object"
  value       = module.eks.sg
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider for IRSA"
  value       = module.eks.oidc_k8_provider_arn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL of the cluster, with https://"
  value       = module.eks.cluster_oidc
}

output "cluster_oidc" {
  description = "OIDC issuer URL, under the module's name"
  value       = module.eks.cluster_oidc
}

output "oidc_k8_provider_arn" {
  description = "ARN of the IAM OIDC provider, under the module's name"
  value       = module.eks.oidc_k8_provider_arn
}

output "oidc_k8_provider_id" {
  description = "Id of the IAM OIDC provider"
  value       = module.eks.oidc_k8_provider_id
}

output "oidc_k8_provider_url" {
  description = "URL of the IAM OIDC provider, without https://"
  value       = module.eks.oidc_k8_provider_url
}

output "addon_versions" {
  description = "Installed version per managed add-on, the values to pin in addon_versions"
  value       = module.eks.addon_versions
}

output "tg_names" {
  description = "Instance Name tag each node group's launch template sets"
  value       = module.eks.tg_names
}

output "asg_names" {
  description = "Auto Scaling group name per managed node group"
  value       = module.eks.asg_names
}

output "eks_role_arn" {
  description = "Cluster IAM role ARN as the module received it"
  value       = module.eks.eks_role_arn
}

output "eks_node_role_arn" {
  description = "Managed node group IAM role ARN as the module received it"
  value       = module.eks.eks_node_role_arn
}

output "node_role_name" {
  description = "Managed node group IAM role name, derived by the module from its ARN"
  value       = module.eks.node_role_name
}

output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = module.cluster_role.role_arn
}

output "cluster_role_name" {
  description = "Name of the EKS cluster IAM role"
  value       = module.cluster_role.role_name
}

output "node_group_role_arn" {
  description = "ARN of the managed node group IAM role"
  value       = module.node_group_role.role_arn
}

output "node_group_role_name" {
  description = "Name of the managed node group IAM role"
  value       = module.node_group_role.role_name
}

output "karpenter_node_role_arn" {
  description = "ARN of the Karpenter node IAM role, mapped by the EC2_LINUX access entry"
  value       = module.karpenter_node_role.role_arn
}

output "karpenter_node_role_name" {
  description = "Name of the Karpenter node IAM role, for the EC2NodeClass spec.role"
  value       = module.karpenter_node_role.role_name
}
