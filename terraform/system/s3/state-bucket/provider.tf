provider "aws" {
  region = var.region
}

terraform {
  required_version = "1.16.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }
  }
  #tfctl.sh sets the state path outside the repo; without it, state lands in this folder
  backend "local" {}
}
