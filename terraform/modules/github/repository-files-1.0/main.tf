#Files Terraform owns on one branch of a repository, such as GitHub Actions workflows; it overwrites a file already at that path

resource "github_repository_file" "this" {
  for_each            = var.files
  repository          = var.repository
  branch              = var.branch
  file                = each.key
  content             = each.value
  commit_message      = "Managed by Terraform: ${each.key}"
  overwrite_on_create = true
}
