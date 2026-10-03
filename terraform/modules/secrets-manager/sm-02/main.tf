#Secrets Manager secret and its version.
resource "aws_secretsmanager_secret" "main" {
  name        = "${var.environment}-${var.application}"
  description = var.description

  tags = {
    Name = "${var.environment}-${var.application}-secrets-manager"
  }
}

resource "aws_secretsmanager_secret_version" "main" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = templatefile("${path.module}/files/secret.json", { SECRETS = var.secrets })

  lifecycle {
    ignore_changes = [secret_string]
  }
}
