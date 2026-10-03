#prod01-us EKS cluster on kubernetes/cluster-05: private subnets, a public endpoint open to the Terraform runner's IP only, the runner as admin, a Karpenter node access entry, one Graviton and one x86 spot node group.

#The ARNs pass through terraform_data so the cluster and node groups are created after, and destroyed before, the roles' policy attachments.

module "eks" {
  source                        = "../../../../../modules/kubernetes/cluster-05"
  endpoint_private_access       = true
  endpoint_public_access        = true
  bootstrap_self_managed_addons = true

  environment     = var.environment
  application     = var.application
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id              = local.vpc_id
  cluster_subnet_ids  = local.private_subnets
  public_access_cidrs = local.public_access_cidrs

  cluster_role_arn    = terraform_data.cluster_role_arn.output
  node_role_arn       = terraform_data.node_group_role_arn.output
  authentication_mode = "API_AND_CONFIG_MAP"

  access_entries = merge(
    { admin = {
      principal_arn = local.admin_principal_arn
      policy_associations = {
        admin = { policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy" }
      }
    } },
    { karpenter = { principal_arn = module.karpenter_node_role.role_arn, type = "EC2_LINUX" } },
    { for arn in var.admin_principal_arns : "admin-${element(split("/", arn), length(split("/", arn)) - 1)}" => {
      principal_arn = arn
      policy_associations = {
        admin = { policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy" }
      }
    } },
  )

  addons = {
    for name, addon in local.addons : name => merge(addon, {
      version = lookup(var.addon_versions, name, null)
    })
  }
  node_groups = local.node_groups

  rules_cidr = [
    { type = "ingress", from_port = 0, to_port = 0, protocol = "-1", cidrs = [local.vpc_cidr] },
    { type = "egress", from_port = 0, to_port = 0, protocol = "-1", cidrs = ["0.0.0.0/0"] },
  ]
}

resource "terraform_data" "cluster_role_arn" {
  input      = module.cluster_role.role_arn
  depends_on = [module.cluster_role]

  lifecycle {
    precondition {
      condition     = can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:(role|user)/.+", local.admin_principal_arn))
      error_message = "Run Terraform as an IAM user or role: EKS access entries do not accept ${local.admin_principal_arn}."
    }
  }
}

resource "terraform_data" "node_group_role_arn" {
  input      = module.node_group_role.role_arn
  depends_on = [module.node_group_role]
}
