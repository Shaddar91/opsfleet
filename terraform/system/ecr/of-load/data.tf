data "github_user" "owner" {
  username = var.github_owner
}

data "github_repository" "load" {
  full_name = "${var.github_owner}/${var.load_repository}"
}
