#prod01-us EKS cluster on kubernetes/cluster-05: private subnets, admin and Karpenter node access entries, the system node group.

#The ARNs pass through terraform_data so the cluster and node groups are created after, and destroyed before, the roles' policy attachments.
resource "terraform_data" "cluster_role_arn" {
  input      = module.cluster_role.role_arn
  depends_on = [module.cluster_role]
}

resource "terraform_data" "node_group_role_arn" {
  input      = module.node_group_role.role_arn
  depends_on = [module.node_group_role]
}

module "eks" {
  source = "../../../../modules/kubernetes/cluster-05"

  environment     = var.environment
  application     = var.application
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                  = local.vpc_id
  cluster_subnet_ids      = local.private_subnets
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = var.public_access_cidrs

  cluster_role_arn              = terraform_data.cluster_role_arn.output
  node_role_arn                 = terraform_data.node_group_role_arn.output
  authentication_mode           = "API_AND_CONFIG_MAP"
  bootstrap_self_managed_addons = true

  access_entries = merge(
    { for arn in var.admin_principal_arns : arn => {
      principal_arn = arn
      policy_associations = {
        admin = { policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy" }
      }
    } },
    { karpenter = { principal_arn = module.karpenter_node_role.role_arn, type = "EC2_LINUX" } },
  )

  addons      = { for name, addon in local.addons : name => merge(addon, { version = lookup(var.addon_versions, name, null) }) }
  node_groups = local.node_groups

  rules_cidr = [
    { type = "ingress", from_port = 0, to_port = 0, protocol = "-1", cidrs = [local.vpc_cidr] },
    { type = "egress", from_port = 0, to_port = 0, protocol = "-1", cidrs = ["0.0.0.0/0"] },
  ]
}
