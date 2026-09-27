#GitHub repository with an enforced default branch, an optional extra branch and branch protection

resource "github_repository" "main" {
  name               = var.project_name
  description        = var.project_description
  auto_init          = true
  visibility         = var.visibility
  has_issues         = var.has_issues
  archive_on_destroy = var.archive_on_destroy

  dynamic "template" {
    for_each = var.template == null ? [] : [var.template]
    content {
      owner                = template.value.owner
      repository           = template.value.repository
      include_all_branches = template.value.include_all_branches
    }
  }
}

resource "github_branch_default" "main" {
  repository      = github_repository.main.name
  branch          = var.default_branch
  rename          = true
  wait_for_rename = true
}

resource "github_branch" "extra" {
  count         = var.branch == null ? 0 : 1
  repository    = github_repository.main.name
  branch        = var.branch
  source_branch = var.default_branch

  #source_branch is create-only; an imported branch reports the branch it was first cut from
  lifecycle {
    ignore_changes = [source_branch]
  }

  depends_on = [github_branch_default.main]
}

resource "github_branch_protection" "main" {
  count         = var.enable_branch_protection ? 1 : 0
  repository_id = github_repository.main.node_id

  pattern          = coalesce(var.pattern, var.default_branch)
  enforce_admins   = var.enforce_admins
  allows_deletions = var.allows_deletions

  required_status_checks {
    strict = var.strict
  }
}
