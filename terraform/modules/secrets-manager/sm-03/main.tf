#Secrets Manager secret and its version; with manage_values the version follows the map, without it the first value is kept and later changes ignored.
resource "aws_secretsmanager_secret" "main" {
  name        = "${var.environment}-${var.application}"
  description = var.description

  tags = {
    Name = "${var.environment}-${var.application}-secrets-manager"
  }
}

resource "aws_secretsmanager_secret_version" "managed" {
  count         = var.manage_values ? 1 : 0
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = templatefile("${path.module}/files/secret.json", { SECRETS = var.secrets })
}

resource "aws_secretsmanager_secret_version" "seeded" {
  count         = var.manage_values ? 0 : 1
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = templatefile("${path.module}/files/secret.json", { SECRETS = var.secrets })

  lifecycle {
    ignore_changes = [secret_string]
  }
}
