#Registry replication: every image pushed to a repository whose name starts with one of the prefixes is copied to each destination region of the same account. One configuration per registry.

resource "aws_ecr_replication_configuration" "main" {
  replication_configuration {
    rule {
      dynamic "destination" {
        for_each = var.destination_regions

        content {
          region      = destination.value
          registry_id = data.aws_caller_identity.current.account_id
        }
      }

      dynamic "repository_filter" {
        for_each = var.repository_prefixes

        content {
          filter      = repository_filter.value
          filter_type = "PREFIX_MATCH"
        }
      }
    }
  }
}
