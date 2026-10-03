data "github_user" "owner" {
  username = var.github_owner
}

data "github_repository" "failover" {
  full_name = "${var.github_owner}/${var.failover_repository}"
}
