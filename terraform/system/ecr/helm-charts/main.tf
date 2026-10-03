#Helm chart ECR repository: of-helm pushes the of-api chart as an OCI artifact, helm push <chart>.tgz oci://<registry>/<namespace>.

module "ecr" {
  source       = "../../../modules/ecr/ecr-1.0-merged"
  scan_on_push = false

  repository_name      = var.repository_name
  environment          = var.environment
  image_tag_mutability = "IMMUTABLE"
  encryption_type      = "AES256"
  force_delete         = var.force_delete
  lifecycle_policy     = file("${path.module}/files/policies/lifecycle.json")
}
