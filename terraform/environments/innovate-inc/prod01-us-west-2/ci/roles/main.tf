#One GitHub Actions OIDC role per repo through iam/role: trust from files/trust, least-privilege policy from files/policies/<repo>.json.tftpl.

module "role" {
  source        = "../../../../../modules/iam/role"
  custom_policy = true

  for_each = toset(var.repos)

  name = "${var.environment}-${each.key}-ci"
  assume_role_policy = templatefile("${path.module}/files/trust/github-oidc.json", {
    PROVIDER_ARN = local.github_oidc_provider_arn
    OWNER        = split("/", local.repo_full_names[each.key])[0]
    OWNER_ID     = local.github_owner_id
    REPO         = split("/", local.repo_full_names[each.key])[1]
    REPO_ID      = local.repo_ids[each.key]
  })
  policy_file = templatefile("${path.module}/files/policies/${each.key}.json", local.policy_vars)
}
