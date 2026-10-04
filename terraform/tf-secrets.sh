#!/usr/bin/env bash
#tf-secrets.sh: keeps the git-ignored secrets.auto.tfvars files (and the account env file) in Secrets Manager, one secret per file named opsfleet-<tree path>; the list lives in system/secret-store/tfvars/terraform.tfvars.
#usage: ./tf-secrets.sh push|pull|diff|list [--region <prod01-...>] [--force] [--quiet] [path...]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST="$ROOT/system/secret-store/tfvars/terraform.tfvars"
CONF="${OPSFLEET_ENV_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/opsfleet/${OPSFLEET_ACCOUNT:-personal}.env}"
#shellcheck source=/dev/null
if [ -z "${STATE_BUCKET:-}" ] && [ -f "$CONF" ]; then . "$CONF"; fi
STORE_REGION="${OPSFLEET_SECRETS_REGION:-us-east-1}"

VERB=""
REGION=""
FORCE=0
QUIET=0
PATHS=()
MISSING=0

usage() {
  cat <<'USAGE'
usage: ./tf-secrets.sh push|pull|diff|list [--region <region folder>] [--force] [--quiet] [path...]

  push   upload each local file to its secret, skipping files whose stored value is already identical
  pull   write files missing locally from their secrets; --force also overwrites files that exist
  diff   report which files differ between disk and store, without contents
  list   show every known path, with store and local presence

  paths  default: every path in system/secret-store/tfvars/terraform.tfvars; --region keeps only the
         shared stacks' files and that region's; config/opsfleet.env maps to the account env file
USAGE
  exit "${1:-0}"
}

while (($#)); do
  case $1 in
    push|pull|diff|list) VERB=$1; shift ;;
    --region) REGION=$2; shift 2 ;;
    --force) FORCE=1; shift ;;
    --quiet) QUIET=1; shift ;;
    -h|--help) usage ;;
    -*) echo "tf-secrets: unknown option $1" >&2; usage 2 ;;
    *) PATHS+=("$1"); shift ;;
  esac
done
[ -n "$VERB" ] || usage 2
[ -f "$LIST" ] || { echo "tf-secrets: $LIST not found" >&2; exit 1; }

known_paths() { sed -nE 's/^\s*"([^"]+)",?\s*$/\1/p' "$LIST"; }

in_scope() {
  [ -z "$REGION" ] && return 0
  case $1 in
    config/*|system/*|environments/*/global/*) return 0 ;;
    environments/*/"$REGION"/*) return 0 ;;
    *) return 1 ;;
  esac
}

if ((${#PATHS[@]} == 0)); then
  while read -r p; do in_scope "$p" && PATHS+=("$p"); done < <(known_paths)
fi

local_file() {
  case $1 in
    config/*) printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/opsfleet/${OPSFLEET_ACCOUNT:-personal}.env" ;;
    *) printf '%s\n' "$ROOT/$1" ;;
  esac
}

secret_name() { printf 'opsfleet-%s\n' "$1"; }

stored() {
  aws secretsmanager get-secret-value --region "$STORE_REGION" --secret-id "$(secret_name "$1")" --query SecretString --output text 2>/dev/null
}

store_exists() {
  aws secretsmanager describe-secret --region "$STORE_REGION" --secret-id "$(secret_name "$1")" --query Name --output text >/dev/null 2>&1
}

say() { printf '%s\n' "$*"; }

for p in "${PATHS[@]}"; do
  f=$(local_file "$p")
  name=$(secret_name "$p")
  case $VERB in
    list)
      if store_exists "$p"; then s=store; else s=no-store; fi
      if [ -f "$f" ]; then l=local; else l=no-local; fi
      say "  $p  [$s, $l]  -> $name"
      ;;
    push)
      if [ ! -f "$f" ]; then say "  $p: no local file, skipped"; continue; fi
      if ! store_exists "$p"; then say "  $p: secret $name does not exist; apply system/secret-store first"; MISSING=1; continue; fi
      if [ "$(stored "$p")" = "$(cat "$f")" ]; then say "  $p: store already identical"; continue; fi
      aws secretsmanager put-secret-value --region "$STORE_REGION" --secret-id "$name" --secret-string "file://$f" --query VersionId --output text >/dev/null
      say "  $p: pushed"
      ;;
    pull)
      if [ -f "$f" ] && ((FORCE == 0)); then
        ((QUIET)) && continue
        if store_exists "$p" && [ "$(stored "$p")" != "$(cat "$f")" ]; then say "  $p: kept local (differs from store; --force overwrites)"; else say "  $p: kept local"; fi
        continue
      fi
      if ! content=$(stored "$p") || [ -z "$content" ]; then say "  $p: secret $name has no value in $STORE_REGION" >&2; MISSING=1; continue; fi
      mkdir -p "$(dirname "$f")"
      (umask 077 && printf '%s\n' "$content" > "$f")
      say "  $p: written"
      ;;
    diff)
      if [ ! -f "$f" ]; then say "  $p: local missing"; continue; fi
      if ! store_exists "$p"; then say "  $p: store missing"; continue; fi
      if [ "$(stored "$p")" = "$(cat "$f")" ]; then say "  $p: same"; else say "  $p: DIFFERS"; fi
      ;;
  esac
done
exit $MISSING
