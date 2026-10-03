#GitHub repository of-api.

module "repo" {
  source                     = "../../../modules/github/create-repo-1.0.1-merged"
  enable_canonical_gitignore = true

  project_name             = var.project_name
  project_description      = "Minimal stateless Flask API with multi-arch (amd64, arm64) image CI"
  visibility               = "public"
  default_branch           = "master"
  enable_branch_protection = var.enable_branch_protection
}
