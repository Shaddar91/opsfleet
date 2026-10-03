#GitHub repository of-helm.

module "repo" {
  source                     = "../../../modules/github/create-repo-1.0.1-merged"
  enable_canonical_gitignore = true

  project_name             = var.project_name
  project_description      = "Helm charts for the backend apps, with x86 and Graviton pinning values"
  visibility               = "public"
  default_branch           = "master"
  enable_branch_protection = var.enable_branch_protection
}
