#!/bin/bash
# Rebuild of-launch — taint SM + EC2, force-delete SM, terraform apply
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== of-launch Rebuild ==="
echo "This will:"
echo "  1. Taint both Secrets Manager secrets + random passwords"
echo "  2. Force-delete SM secrets from AWS (bypass recovery window)"
echo "  3. Taint the EC2 instance"
echo "  4. Run terraform apply to recreate everything"
echo ""
read -p "Are you sure? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Aborted."
  exit 0
fi

#Taint Secrets Manager resources
echo ""
echo ">>> Tainting Secrets Manager resources..."

terraform taint 'module.sm.aws_secretsmanager_secret.main'
terraform taint 'module.sm.aws_secretsmanager_secret_version.main'
terraform taint 'module.sm_seed.aws_secretsmanager_secret.main'
terraform taint 'module.sm_seed.aws_secretsmanager_secret_version.main'

#taint random passwords so new values get generated
terraform taint 'random_password.of_launch_db_password'
terraform taint 'random_password.of_launch_app_secret_key'

#Force-delete SM secrets from AWS (skip 7-day recovery window)
echo ""
echo ">>> Force-deleting Secrets Manager secrets from AWS..."

aws secretsmanager delete-secret \
  --secret-id "prod01-us-of-launch" \
  --force-delete-without-recovery \
  --region us-east-1 2>/dev/null || echo "  prod01-us-of-launch: already deleted or not found"

aws secretsmanager delete-secret \
  --secret-id "prod01-us-of-launch-seed" \
  --force-delete-without-recovery \
  --region us-east-1 2>/dev/null || echo "  prod01-us-of-launch-seed: already deleted or not found"

#Detach EBS volume from current instance before destroying it
echo ""
echo ">>> Detaching MySQL EBS volume..."

VOLUME_ID=$(terraform output -raw mysql_ebs_volume_id 2>/dev/null || true)
if [ -n "$VOLUME_ID" ]; then
  aws ec2 detach-volume --volume-id "$VOLUME_ID" --region us-east-1 --force 2>/dev/null \
    || echo "  Volume $VOLUME_ID: already detached or not found"
  echo "  Waiting for volume to detach..."
  aws ec2 wait volume-available --volume-ids "$VOLUME_ID" --region us-east-1 2>/dev/null || true
fi

#Taint EC2 instance
echo ""
echo ">>> Tainting EC2 instance..."

terraform taint 'module.of_launch_01.aws_instance.main'

#Apply
echo ""
echo ">>> Running terraform apply..."

terraform apply -auto-approve
