#The deploy workflow and CodeDeploy files committed to the of-launch repo, and the Actions secrets they read, all from this stack's values.

resource "github_actions_secret" "of_launch" {
  for_each = local.of_launch_github_secrets

  repository      = var.gh_repo
  secret_name     = each.key
  plaintext_value = each.value
}

resource "github_repository_file" "of_launch" {
  for_each = local.of_launch_repo_files

  repository          = var.gh_repo
  branch              = var.gh_branch
  file                = each.key
  content             = each.value
  commit_message      = "Managed by Terraform: ${each.key}"
  commit_author       = "Terraform"
  commit_email        = "terraform@terraform.com"
  overwrite_on_create = true

  #the commit starts a deploy run, which needs every secret above
  depends_on = [github_actions_secret.of_launch]
}
