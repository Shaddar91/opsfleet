#!/bin/bash
#Bastion user-data, rendered by templatefile(): installs ansible-core, pulls the roles tarball and playbook from S3, runs the playbook locally.
set -euo pipefail
umask 022

LOG=/var/log/bastion-setup.log
WORKDIR=/opt/opsfleet-ansible
ANSIBLE_REV="${ansible_rev}"
export HOME="$${HOME:-/root}"

exec > >(tee -a "$LOG") 2>&1

log() {
  printf '%s bastion-setup: %s\n' "$(date -Is)" "$*"
}

trap 'log "FAILED rc=$? line=$LINENO"' ERR

fetch() {
  local attempt=1
  until aws s3 cp --only-show-errors --region "${aws_region}" "s3://${ansible_bucket}/$1" "$2"; do
    [ "$attempt" -ge 6 ] && return 1
    log "cannot read s3://${ansible_bucket}/$1, retry $attempt of 5"
    sleep $((attempt * 10))
    attempt=$((attempt + 1))
  done
}

log "start, ansible_rev $ANSIBLE_REV"
dnf install -y ansible-core tar gzip
command -v aws >/dev/null || dnf install -y awscli-2

install -d -m 0700 "$WORKDIR"
rm -rf "$WORKDIR/roles"
install -d -m 0700 "$WORKDIR/roles"
fetch "${roles_key}" "$WORKDIR/roles.tar.gz"
fetch "${playbook_key}" "$WORKDIR/bastion.yml"
tar --no-same-owner --no-same-permissions -xzf "$WORKDIR/roles.tar.gz" -C "$WORKDIR/roles"
rm -f "$WORKDIR/roles.tar.gz"

cd "$WORKDIR"
ansible-playbook --version </dev/null
ansible-playbook --connection=local -i localhost, bastion.yml </dev/null
printf '%s\n' "$ANSIBLE_REV" >"$WORKDIR/ansible_rev"
log "done, ansible_rev $ANSIBLE_REV"
