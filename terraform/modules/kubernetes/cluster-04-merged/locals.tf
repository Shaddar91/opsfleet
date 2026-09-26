locals {
  thumbprint = substr(data.external.thumbprint.result["thumbprint"], 0, min(length(data.external.thumbprint.result["thumbprint"]), 40))
}

data "external" "thumbprint" {
  program = ["${path.module}/files/scripts/thumbprint.sh"]
}
