data "aws_partition" "current" {}

data "github_user" "owner" {
  username = var.github_owner
}

data "github_repository" "repo" {
  full_name = "${var.github_owner}/${var.repository}"
}
