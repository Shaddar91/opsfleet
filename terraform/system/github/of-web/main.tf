#GitHub repository of-web.

module "repo" {
  source                      = "../../../modules/github/create-repo-1.0.1-merged"
  enable_canonical_gitignore  = true
  vulnerability_alerts        = true
  dependabot_security_updates = true
  secret_scanning             = true

  project_name             = var.project_name
  project_description      = "Minimal stateless React (Vite) web app with CI"
  visibility               = "public"
  default_branch           = "master"
  enable_branch_protection = var.enable_branch_protection
}
