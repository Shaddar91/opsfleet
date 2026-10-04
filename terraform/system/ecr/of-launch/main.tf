#Image repository for of-launch; the of-launch stack in prod01-us-east-1 reads it and its deploy workflow pushes here.

module "ecr" {
  source       = "../../../modules/ecr/ecr-1.0-merged"
  scan_on_push = true

  repository_name      = var.repository_name
  environment          = var.environment
  image_tag_mutability = "MUTABLE"
  encryption_type      = "AES256"
  force_delete         = var.force_delete
  lifecycle_policy     = file("${path.module}/files/policies/lifecycle.json")
}
