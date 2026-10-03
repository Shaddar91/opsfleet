#GitHub Actions OIDC provider for the account, or a read of the existing one when create_provider is false.

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_provider ? 1 : 0

  url            = local.github_oidc_url
  client_id_list = [local.audience]

  tags = {
    Name        = "github-actions-oidc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
