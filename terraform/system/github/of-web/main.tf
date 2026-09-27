#GitHub repository of-web.

module "repo" {
  source = "../../../modules/github/create-repo-1.0.1-merged"

  project_name               = var.project_name
  project_description        = "Minimal stateless React (Vite) web app with CI"
  visibility                 = "private"
  default_branch             = "master"
  enable_canonical_gitignore = true
  enable_branch_protection   = var.enable_branch_protection
}
