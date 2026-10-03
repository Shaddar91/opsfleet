variable "create_provider" {
  description = "Create the account's GitHub Actions OIDC provider; false reads the existing one instead, so destroy never deletes a provider other roles trust"
  type        = bool
}
