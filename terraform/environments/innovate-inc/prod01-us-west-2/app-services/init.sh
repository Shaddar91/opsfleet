#!/bin/bash
#Renders provider.auto.tf from ../provider.tf.tmpl and links the tier's shared files; run from a stack folder.
set -euo pipefail
CONF="${OPSFLEET_ENV_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/opsfleet/${OPSFLEET_ACCOUNT:-personal}.env}"
if [ -z "${STATE_BUCKET:-}" ] && [ -f "$CONF" ]; then . "$CONF"; fi
: "${STATE_BUCKET:?set it in the environment or in $CONF}" "${STATE_BUCKET_REGION:?set it in the environment or in $CONF}" "${STATE_KEY_PREFIX:?set it in the environment or in $CONF}"
export STATE_BUCKET STATE_BUCKET_REGION STATE_KEY_PREFIX
export PARENT_DIR="$(basename "$(dirname "$(pwd)")")"
export DIR="$(basename "$(pwd)")"
export ENV="prod01-usw2"
export REGION="${REGION:-us-west-2}"
envsubst '${PARENT_DIR} ${DIR} ${ENV} ${REGION} ${STATE_BUCKET} ${STATE_KEY_PREFIX} ${STATE_BUCKET_REGION}' < ../provider.tf.tmpl > provider.auto.tf
ln -sf ../shared-variables.tf ./shared-variables.auto.tf
if [ -f ../secrets.auto.tfvars ]; then ln -sf ../secrets.auto.tfvars ./secrets.auto.tfvars; fi
terraform fmt
terraform init "$@"
