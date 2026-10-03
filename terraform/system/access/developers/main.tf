#Developer group through iam/group (ReadOnlyAccess + a deny/assume policy) and the deploy role its members assume for the cluster.

module "group" {
  source        = "../../../modules/iam/group"
  custom_policy = true

  group       = var.group_name
  policy_list = ["arn:${local.partition}:iam::aws:policy/ReadOnlyAccess"]

  policy_file = templatefile("${path.module}/files/policies/group.json", {
    PARTITION       = local.partition
    ACCOUNT_ID      = local.account_id
    STATE_BUCKET    = local.state_bucket
    DEPLOY_ROLE_ARN = module.deploy_role.role_arn
  })
}

module "deploy_role" {
  source        = "../../../modules/iam/role"
  custom_policy = true

  name = "${var.group_name}-deploy"
  assume_role_policy = templatefile("${path.module}/files/trust/account.json", {
    PARTITION  = local.partition
    ACCOUNT_ID = local.account_id
  })
  policy_file = templatefile("${path.module}/files/policies/deploy.json", { CLUSTER_ARN = local.cluster_arn })
}
