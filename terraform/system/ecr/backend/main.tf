#Backend ECR repository with the multi-arch lifecycle policy in files/policies/lifecycle.json.

module "ecr" {
  source = "../../../modules/ecr/ecr-1.0-merged"

  repository_name      = var.repository_name
  environment          = var.environment
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  encryption_type      = "AES256"
  force_delete         = var.force_delete
  lifecycle_policy     = file("${path.module}/files/policies/lifecycle.json")
}
