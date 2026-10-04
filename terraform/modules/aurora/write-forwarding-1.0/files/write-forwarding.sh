#!/usr/bin/env bash
#write-forwarding.sh on|off: turns global write forwarding on or off for CLUSTER in REGION and waits until AWS reports it; off on a missing cluster is done.
set -euo pipefail
case ${1:-} in
  on) flag=--enable-global-write-forwarding target=enabled ;;
  off) flag=--no-enable-global-write-forwarding target=disabled ;;
  *) echo "usage: write-forwarding.sh on|off" >&2; exit 2 ;;
esac
status() { aws rds describe-db-clusters --region "$REGION" --db-cluster-identifier "$CLUSTER" --query 'DBClusters[0].GlobalWriteForwardingStatus' --output text; }
if ! s=$(status 2>/dev/null); then
  if [[ $1 == off ]]; then exit 0; fi
  echo "cluster $CLUSTER not found in $REGION" >&2
  exit 1
fi
if [[ $s != "$target" ]]; then
  aws rds modify-db-cluster --region "$REGION" --db-cluster-identifier "$CLUSTER" $flag --apply-immediately >/dev/null
fi
for _ in $(seq 60); do
  s=$(status)
  if [[ $s == "$target" || ($1 == off && $s == None) ]]; then exit 0; fi
  sleep 10
done
echo "write forwarding on $CLUSTER is still $s after 10 minutes" >&2
exit 1
