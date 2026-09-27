#One GitHub Actions OIDC role per repo through iam/role: trust from files/trust, least-privilege policy from files/policies/<repo>.json.tftpl.

locals {
  policy_vars = {
    ecr_repository_arn = local.ecr_repository_arn
    web_bucket_arn     = local.web_bucket_arn
    distribution_arn   = local.distribution_arn
    cluster_arn        = local.cluster_arn
  }
}

module "role" {
  source   = "../../../../modules/iam/role"
  for_each = toset(var.repos)

  name = "${var.environment}-${each.key}-ci"
  assume_role_policy = templatefile("${path.module}/files/trust/github-oidc.json.tftpl", {
    provider_arn = local.github_oidc_provider_arn
    owner        = split("/", local.repo_full_names[each.key])[0]
    owner_id     = local.github_owner_id
    repo         = split("/", local.repo_full_names[each.key])[1]
    repo_id      = local.repo_ids[each.key]
  })
  custom_policy = true
  policy_file   = templatefile("${path.module}/files/policies/${each.key}.json.tftpl", local.policy_vars)
}
