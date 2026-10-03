module "helm_to_git" {
  source = "../../../../../modules/kubernetes/services/service-0.3/modules/helm-to-git"

  chart_dir      = local.chart_dir
  git_repository = var.git_repository
  git_branch     = var.git_branch
  git_path       = var.git_path
  commit_author  = var.commit_author
  commit_email   = var.commit_email
}
