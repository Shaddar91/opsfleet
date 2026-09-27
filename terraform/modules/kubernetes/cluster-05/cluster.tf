resource "aws_eks_cluster" "main" {
  name                          = local.cluster_name
  role_arn                      = var.cluster_role_arn
  version                       = var.cluster_version
  bootstrap_self_managed_addons = var.bootstrap_self_managed_addons

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin_permissions
  }

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    subnet_ids              = var.cluster_subnet_ids
  }

  dynamic "upgrade_policy" {
    for_each = var.upgrade_policy_support_type == null ? [] : [var.upgrade_policy_support_type]
    content {
      support_type = upgrade_policy.value
    }
  }
}
