data "aws_caller_identity" "current" {}

data "aws_subnet" "of_launch" {
  id = local.private_subnets[0]
}

data "github_user" "owner" {
  username = var.github_owner
}

data "github_repository" "of_launch" {
  full_name = "${var.github_owner}/${var.gh_repo}"
}
