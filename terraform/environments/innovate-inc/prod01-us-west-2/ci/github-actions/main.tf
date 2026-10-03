#Per repo, by name: the AWS_ROLE_ARN secret, the repo's own secrets and the variables its workflows read, through actions-secrets-1.0.

module "actions" {
  source   = "../../../../../modules/github/actions-secrets-1.0"
  for_each = toset(var.repos)

  repository = each.key
  secrets = merge(
    { AWS_ROLE_ARN = local.role_arns[each.key] },
    lookup(local.repo_secrets, each.key, {}),
  )
  variables = merge(
    { AWS_REGION = var.region, DEPLOY_ENABLED = var.deploy_enabled },
    lookup(local.repo_variables, each.key, {}),
  )
}
