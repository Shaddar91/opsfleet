#ECR repository for the of-failover Lambda image, in the function's region (region in terraform.tfvars), with the lifecycle policy in files/policies/lifecycle.json.

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
