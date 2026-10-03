#GitHub repository of-load.

module "repo" {
  source                     = "../../../modules/github/create-repo-1.0.1-merged"
  enable_canonical_gitignore = true

  project_name             = var.project_name
  project_description      = "Stress API for pod and node autoscaling tests"
  visibility               = "public"
  default_branch           = "master"
  enable_branch_protection = var.enable_branch_protection
}
