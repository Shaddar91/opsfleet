output "provider_arn" {
  description = "ARN of the account's GitHub Actions OIDC provider, created here or read; the per-repo CI roles trust it"
  value       = one(concat(aws_iam_openid_connect_provider.github[*].arn, data.aws_iam_openid_connect_provider.github[*].arn))
}
