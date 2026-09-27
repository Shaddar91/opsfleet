#ECR repository with optional lifecycle and cross-account pull policies

resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.kms_key_arn
  }

  tags = merge(
    {
      Name        = var.repository_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

resource "aws_ecr_lifecycle_policy" "this" {
  count = var.lifecycle_policy == null ? 0 : 1

  repository = aws_ecr_repository.this.name
  policy     = var.lifecycle_policy
}

resource "aws_ecr_repository_policy" "this" {
  count = var.enable_cross_account_access ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy = templatefile("${path.module}/files/policies/cross-account-pull.json", {
    account_ids = var.allowed_account_ids
  })
}
