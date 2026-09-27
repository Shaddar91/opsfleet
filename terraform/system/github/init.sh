#!/bin/bash
#Renders provider.auto.tf from ../provider.tf.tmpl and links the tier's shared files; run from a stack folder.
set -euo pipefail
CONF="${OPSFLEET_BACKEND_CONF:-${XDG_CONFIG_HOME:-$HOME/.config}/opsfleet/backend.env}"
[ -f "$CONF" ] && . "$CONF"
: "${STATE_BUCKET:?set STATE_BUCKET in the environment or in $CONF}"
export PARENT_DIR="$(basename "$(dirname "$(pwd)")")"
export DIR="$(basename "$(pwd)")"
export ENV="system"
export REGION="${REGION:-us-east-1}"
export STATE_BUCKET_REGION="${STATE_BUCKET_REGION:-us-east-1}"
export STATE_BUCKET
envsubst '${PARENT_DIR} ${DIR} ${ENV} ${REGION} ${STATE_BUCKET} ${STATE_BUCKET_REGION}' < ../provider.tf.tmpl > provider.auto.tf
ln -sf ../shared-variables.tf ./shared-variables.auto.tf
if [ -f ../secrets.auto.tfvars ]; then ln -sf ../secrets.auto.tfvars ./secrets.auto.tfvars; fi
terraform fmt
terraform init "$@"
