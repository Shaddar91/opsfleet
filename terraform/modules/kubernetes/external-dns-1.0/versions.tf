terraform {
  required_version = ">= 1.5"

  required_providers {
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.81.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0"
    }
  }
}
