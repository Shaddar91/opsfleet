#of-helm's pipeline: the Snyk token its workflow reads as an Actions secret, then the workflow itself, committed to the default branch.

module "helm_actions" {
  source = "../../../modules/github/actions-secrets-1.0"

  repository = module.repo.repo_name
  secrets = {
    SNYK_TOKEN = var.snyk_token
  }
}

module "helm_workflow" {
  source = "../../../modules/github/repository-files-1.0"

  repository = module.repo.repo_name
  branch     = "master"
  files = {
    ".github/workflows/ci.yml" = file("${path.module}/files/workflows/of-helm.yml")
  }

  #the commit starts a run on the default branch, which needs the secret above
  depends_on = [module.helm_actions]
}
