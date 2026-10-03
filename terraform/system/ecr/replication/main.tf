#Replication rule of the us-east-1 registry: images of the of-api and of-load repositories are copied to the regions in terraform.tfvars, into the replica repositories the *-usw2 stacks create.

module "replication" {
  source = "../../../modules/ecr/replication-1.0"

  destination_regions = var.destination_regions
  repository_prefixes = var.repository_prefixes
}
