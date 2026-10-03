resource "github_repository_file" "chart" {
  for_each = local.chart_files

  repository          = var.git_repository
  branch              = var.git_branch
  file                = "${var.git_path}/${each.key}"
  content             = each.value
  commit_author       = var.commit_author
  commit_email        = var.commit_email
  overwrite_on_create = false

  lifecycle {
    ignore_changes = [content, commit_message, commit_author, commit_email]
  }
}
