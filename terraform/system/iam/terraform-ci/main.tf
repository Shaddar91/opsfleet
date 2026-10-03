#The repository's Terraform pipeline roles over GitHub OIDC: plan (ReadOnlyAccess) for its default branch, apply (AdministratorAccess) only for jobs in the approval environment.

module "plan_role" {
  source = "../../../modules/iam/role"

  name = "${data.github_repository.repo.name}-terraform-plan"
  assume_role_policy = templatefile("${path.module}/files/trust/github-oidc.json", {
    PROVIDER_ARN = local.github_oidc_provider_arn
    SUBJECT      = "${local.subject_prefix}:ref:refs/heads/${data.github_repository.repo.default_branch}"
  })
  policy_list = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/ReadOnlyAccess"]
}

module "apply_role" {
  source = "../../../modules/iam/role"

  name = "${data.github_repository.repo.name}-terraform-apply"
  assume_role_policy = templatefile("${path.module}/files/trust/github-oidc.json", {
    PROVIDER_ARN = local.github_oidc_provider_arn
    SUBJECT      = "${local.subject_prefix}:environment:${var.apply_environment}"
  })
  policy_list = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/AdministratorAccess"]
}
