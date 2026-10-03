#!/usr/bin/env bash
#Starts ../tfctl.sh for this region: ./tfctl.sh apply|plan|destroy [<stack>|all] [--from <stack>] [--auto-approve], ./tfctl.sh order, ./tfctl.sh help
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TFCTL_ENTRY=$0 exec "$here/../tfctl.sh" "${here##*/}" "$@"
