#Canonical .gitignore from files/gitignore-canonical.txt, committed by Terraform

resource "github_repository_file" "canonical_gitignore" {
  count               = var.enable_canonical_gitignore ? 1 : 0
  repository          = github_repository.main.name
  branch              = coalesce(var.canonical_gitignore_branch, var.default_branch)
  file                = ".gitignore"
  content             = file("${path.module}/files/gitignore-canonical.txt")
  commit_message      = "Add canonical .gitignore (managed by Terraform)"
  commit_author       = var.commit_author
  commit_email        = var.commit_email
  overwrite_on_create = var.overwrite_on_create

  depends_on = [github_branch_default.main, github_branch.extra]
}
