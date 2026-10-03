locals {
  thumbprint = substr(data.external.thumbprint.result["thumbprint"], 0, min(length(data.external.thumbprint.result["thumbprint"]), 40))
}
