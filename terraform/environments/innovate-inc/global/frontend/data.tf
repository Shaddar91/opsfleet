data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "github_user" "owner" {
  username = var.github_owner
}

data "github_repository" "web" {
  full_name = "${var.github_owner}/${var.web_repository}"
}
