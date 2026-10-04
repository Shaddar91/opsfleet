#The dashboard's permissions on the instance role: of-web builds and bucket, CloudFront, its CodeDeploy application, the of-launch and of-api images, its secrets and MySQL backups.

resource "aws_iam_policy" "of_launch_dashboard" {
  name = "${local.name}-dashboard-policy"
  policy = templatefile("${path.module}/files/policies/of-launch-dashboard-policy.json", {
    REGION              = var.region
    ACCOUNT_ID          = local.account_id
    ARTIFACT_BUCKET_ARN = local.artifact_bucket_arn
    WEB_BUCKET_ARN      = local.web_bucket_arn
    BACKUP_BUCKET_ARN   = local.backup_bucket_arn
    APPLICATION         = var.application
    CODEDEPLOY_APP      = module.codedeploy.app.name
    ECR_OF_LAUNCH_ARN   = local.ecr_of_launch_arn
    ECR_OF_API_ARN      = local.ecr_of_api_arn
    CLUSTER_NAME        = local.cluster_name
    SECRET_PREFIX       = local.name
  })
}

resource "aws_iam_role_policy_attachment" "of_launch_dashboard" {
  role       = module.of_launch_01.iam_role.name
  policy_arn = aws_iam_policy.of_launch_dashboard.arn
}
