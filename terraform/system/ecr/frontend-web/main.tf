#Frontend ECR repository for an of-web image, with the multi-arch lifecycle policy in files/policies/lifecycle.json.

module "ecr" {
  source       = "../../../modules/ecr/ecr-1.0-merged"
  scan_on_push = true

  repository_name      = var.repository_name
  environment          = var.environment
  image_tag_mutability = "IMMUTABLE"
  encryption_type      = "AES256"
  force_delete         = var.force_delete
  lifecycle_policy     = file("${path.module}/files/policies/lifecycle.json")
}
