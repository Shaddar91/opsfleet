data "github_user" "owner" {
  username = var.github_owner
}

data "github_repository" "api" {
  full_name = "${var.github_owner}/${var.api_repository}"
}
