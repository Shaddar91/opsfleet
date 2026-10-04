#!/bin/bash
# Destroy of-launch Secrets — force-delete SM + taint TF resources
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Destroy of-launch Secrets ==="
echo "This will:"
echo "  1. Force-delete SM secrets from AWS (bypass recovery window)"
echo "  2. Taint SM + random_password resources in Terraform"
echo ""
echo "Secrets to delete:"
echo "  - prod01-us-of-launch"
echo "  - prod01-us-of-launch-seed"
echo ""
read -p "Are you sure? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Aborted."
  exit 0
fi

#Force-delete SM secrets from AWS
echo ""
echo ">>> Force-deleting Secrets Manager secrets..."

aws secretsmanager delete-secret \
  --secret-id "prod01-us-of-launch" \
  --force-delete-without-recovery \
  --region us-east-1 2>/dev/null \
  && echo "  Deleted: prod01-us-of-launch" \
  || echo "  prod01-us-of-launch: already deleted or not found"

aws secretsmanager delete-secret \
  --secret-id "prod01-us-of-launch-seed" \
  --force-delete-without-recovery \
  --region us-east-1 2>/dev/null \
  && echo "  Deleted: prod01-us-of-launch-seed" \
  || echo "  prod01-us-of-launch-seed: already deleted or not found"

#Taint TF resources for recreation on next apply
echo ""
echo ">>> Tainting Terraform resources..."

terraform taint 'module.sm.aws_secretsmanager_secret.main' 2>/dev/null \
  && echo "  Tainted: module.sm.aws_secretsmanager_secret.main" \
  || echo "  Already tainted or not in state: sm secret"

terraform taint 'module.sm.aws_secretsmanager_secret_version.main' 2>/dev/null \
  && echo "  Tainted: module.sm.aws_secretsmanager_secret_version.main" \
  || echo "  Already tainted or not in state: sm version"

terraform taint 'module.sm_seed.aws_secretsmanager_secret.main' 2>/dev/null \
  && echo "  Tainted: module.sm_seed.aws_secretsmanager_secret.main" \
  || echo "  Already tainted or not in state: seed secret"

terraform taint 'module.sm_seed.aws_secretsmanager_secret_version.main' 2>/dev/null \
  && echo "  Tainted: module.sm_seed.aws_secretsmanager_secret_version.main" \
  || echo "  Already tainted or not in state: seed version"

terraform taint 'random_password.of_launch_db_password' 2>/dev/null \
  && echo "  Tainted: random_password.of_launch_db_password" \
  || echo "  Already tainted or not in state: of_launch_db_password"

terraform taint 'random_password.of_launch_app_secret_key' 2>/dev/null \
  && echo "  Tainted: random_password.of_launch_app_secret_key" \
  || echo "  Already tainted or not in state: of_launch_app_secret_key"

echo ""
echo "Done. Next steps:"
echo "  1. Run: terraform plan    (review changes)"
echo "  2. Run: terraform apply   (recreate secrets)"
echo ""
echo "NOTE: After recreating secrets, the EC2 instance needs a restart"
echo "      to pick up new values (systemctl restart of-launch on the instance,"
echo "      or taint the instance and terraform apply)."
echo ""
echo "NOTE: If re-seeding is needed, delete the marker file on the instance:"
echo "      ssh instance 'rm -f /opt/of-launch/.users-seeded'"
