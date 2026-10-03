data "kubectl_file_documents" "crds" {
  for_each = fileset("${path.module}/files/crds", "*.yaml")

  content = file("${path.module}/files/crds/${each.value}")
}

data "aws_iam_policy_document" "lbc_assume" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}
