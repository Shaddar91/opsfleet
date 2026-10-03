#GitHub repository of-failover.

module "repo" {
  source                     = "../../../modules/github/create-repo-1.0.1-merged"
  enable_canonical_gitignore = true

  project_name             = var.project_name
  project_description      = "Lambda that fences a region on the accelerator and promotes the Aurora global database standby"
  visibility               = "private"
  default_branch           = "master"
  enable_branch_protection = var.enable_branch_protection
}
