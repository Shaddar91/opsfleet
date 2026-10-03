#Default GITHUB_TOKEN permissions of a repository's workflows, and whether a workflow may open or approve pull requests.

resource "github_workflow_repository_permissions" "main" {
  repository                       = var.repository
  default_workflow_permissions     = var.default_workflow_permissions
  can_approve_pull_request_reviews = var.can_approve_pull_request_reviews
}
