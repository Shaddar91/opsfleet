#!/usr/bin/env bash
#cleanup.sh: empties the edge and web log buckets named in the tier secrets files and force-deletes Secrets Manager secrets already scheduled for deletion, region by region.
#usage: ./cleanup.sh [--region <r>]... [--bucket <name|glob>]... [--secret <glob>]... [--buckets-only|--secrets-only] [--dry-run]
set -euo pipefail
((BASH_VERSINFO[0] * 100 + BASH_VERSINFO[1] >= 404)) || { echo "cleanup: needs bash 4.4 or newer" >&2; exit 1; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="${OPSFLEET_ENV_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/opsfleet/${OPSFLEET_ACCOUNT:-personal}.env}"
#shellcheck source=/dev/null
if [ -z "${STATE_BUCKET:-}" ] && [ -f "$CONF" ]; then . "$CONF"; fi
: "${STATE_BUCKET:?set it in the environment or in $CONF}"

REGIONS=()
BUCKET_GLOBS=()
SECRET_GLOBS=()
DRY=0
DO_BUCKETS=1
DO_SECRETS=1
FAILED=0

usage() {
  cat <<'USAGE'
usage: ./cleanup.sh [--region <r>]... [--bucket <name|glob>]... [--secret <glob>]... [--buckets-only|--secrets-only] [--dry-run]

  regions   default: every prod01-<region> folder beside this script
  buckets   default: edge_log_bucket_name of each selected region and log_bucket_name of global, read from their secrets.auto.tfvars
  secrets   default: every secret in the region whose deletion is already scheduled; --secret narrows by name glob
  --dry-run lists what would go and changes nothing

A bucket or region that does not exist is reported and skipped; the exit code is 1 only when a delete call fails.
USAGE
  exit "${1:-0}"
}

while (($#)); do
  case $1 in
    --region) REGIONS+=("$2"); shift 2 ;;
    --bucket) BUCKET_GLOBS+=("$2"); shift 2 ;;
    --secret) SECRET_GLOBS+=("$2"); shift 2 ;;
    --buckets-only) DO_SECRETS=0; shift ;;
    --secrets-only) DO_BUCKETS=0; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) usage ;;
    *) echo "cleanup: unknown argument $1" >&2; usage 2 ;;
  esac
done

if ((${#REGIONS[@]} == 0)); then
  for d in "$ROOT"/prod01-*/; do REGIONS+=("$(basename "$d" | sed 's/^prod01-//')"); done
fi

tfvar() { sed -nE "s/^[[:space:]]*$2[[:space:]]*=[[:space:]]*\"([^\"]*)\".*/\1/p" "$1" 2>/dev/null | head -1; }

if ((${#BUCKET_GLOBS[@]} == 0)); then
  for r in "${REGIONS[@]}"; do
    b=$(tfvar "$ROOT/prod01-$r/secrets.auto.tfvars" edge_log_bucket_name); [ -n "$b" ] && BUCKET_GLOBS+=("$b")
  done
  b=$(tfvar "$ROOT/global/secrets.auto.tfvars" log_bucket_name); [ -n "$b" ] && BUCKET_GLOBS+=("$b")
fi

say() { printf '%s\n' "$*"; }

matches_any() {
  local name=$1 g; shift
  (($# == 0)) && return 0
  #shellcheck disable=SC2053
  for g in "$@"; do [[ $name == $g ]] && return 0; done
  return 1
}

bucket_region() {
  local loc
  loc=$(aws s3api get-bucket-location --bucket "$1" --query LocationConstraint --output text 2>/dev/null) || return 1
  case $loc in None|null|"") echo us-east-1 ;; EU) echo eu-west-1 ;; *) echo "$loc" ;; esac
}

empty_bucket() {
  local bucket=$1 region objects total=0 chunk
  if ! region=$(bucket_region "$bucket"); then say "  $bucket: absent or not reachable, skipping"; return 0; fi
  objects=$(aws s3api list-object-versions --bucket "$bucket" --region "$region" --output json \
    --query '[Versions[].{Key:Key,VersionId:VersionId}, DeleteMarkers[].{Key:Key,VersionId:VersionId}][]' 2>/dev/null) || { say "  $bucket: listing failed"; FAILED=1; return 0; }
  total=$(jq 'length' <<<"$objects")
  if ((total == 0)); then say "  $bucket ($region): already empty"; return 0; fi
  if ((DRY)); then say "  $bucket ($region): would delete $total object versions and delete markers"; return 0; fi
  while read -r chunk; do
    aws s3api delete-objects --bucket "$bucket" --region "$region" --delete "$chunk" --output json >/dev/null \
      || { say "  $bucket: a delete batch failed"; FAILED=1; return 0; }
  done < <(jq -c '_nwise(1000) | {Objects: ., Quiet: true}' <<<"$objects")
  say "  $bucket ($region): deleted $total object versions and delete markers"
}

purge_secrets() {
  local region=$1 listing name arn count=0
  listing=$(aws secretsmanager list-secrets --region "$region" --include-planned-deletion --output json \
    --query 'SecretList[?DeletedDate!=null].[Name,ARN]' 2>/dev/null) || { say "  $region: Secrets Manager not reachable, skipping"; return 0; }
  while IFS=$'\t' read -r name arn; do
    [ -z "$name" ] && continue
    matches_any "$name" "${SECRET_GLOBS[@]}" || continue
    count=$((count + 1))
    if ((DRY)); then say "  $region: would force-delete $name"; continue; fi
    if aws secretsmanager delete-secret --region "$region" --secret-id "$arn" --force-delete-without-recovery --output text --query Name >/dev/null; then
      say "  $region: force-deleted $name"
    else
      say "  $region: delete failed for $name"; FAILED=1
    fi
  done < <(jq -r '.[] | @tsv' <<<"$listing")
  ((count == 0)) && say "  $region: nothing scheduled for deletion"
  return 0
}

((DRY)) && say "dry run: nothing is changed"
if ((DO_BUCKETS)); then
  say "log buckets:"
  if ((${#BUCKET_GLOBS[@]} == 0)); then say "  no bucket names resolved; pass --bucket"; fi
  while read -r b; do
    [ -z "$b" ] && continue
    matches_any "$b" "${BUCKET_GLOBS[@]}" && empty_bucket "$b"
  done < <(aws s3api list-buckets --query 'Buckets[].Name' --output text | tr '\t' '\n')
  for g in "${BUCKET_GLOBS[@]}"; do
    [[ $g == *[\*\?\[]* ]] && continue
    aws s3api head-bucket --bucket "$g" >/dev/null 2>&1 || say "  $g: absent, skipping"
  done
fi
if ((DO_SECRETS)); then
  say "secrets scheduled for deletion:"
  for r in "${REGIONS[@]}"; do purge_secrets "$r"; done
fi
exit $FAILED
