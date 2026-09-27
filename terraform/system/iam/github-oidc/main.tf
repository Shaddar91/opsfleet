#GitHub Actions OIDC provider for the account, or a read of the existing one when create_provider is false.

locals {
  github_oidc_url = "https://token.actions.githubusercontent.com"
  audience        = "sts.amazonaws.com"
}

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

data "aws_iam_openid_connect_provider" "github" {
  count = var.create_provider ? 0 : 1

  url = local.github_oidc_url

  lifecycle {
    postcondition {
      condition     = contains(self.client_id_list, local.audience)
      error_message = "The existing GitHub OIDC provider does not list the sts.amazonaws.com audience, so roles that trust it cannot be assumed from GitHub Actions."
    }
  }
}
