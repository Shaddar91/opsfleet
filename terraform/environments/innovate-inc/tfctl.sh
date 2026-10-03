#!/usr/bin/env bash
#tfctl.sh: innovate-inc only. Runs a stack's init.sh (its own, or the tier's ../init.sh) plus a terraform verb over the stacks listed in <tier>/stacks, in order.
#Tiers are folders under this one ("." or "root" is this folder itself); roll, unroll, check and order walk every tier in ./rollout. ./tfctl.sh help prints the verbs.
set -euo pipefail
((BASH_VERSINFO[0] * 100 + BASH_VERSINFO[1] >= 404)) || { echo "tfctl: needs bash 4.4 or newer" >&2; exit 1; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="${OPSFLEET_ENV_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/opsfleet/${OPSFLEET_ACCOUNT:-personal}.env}"
if [ -z "${STATE_BUCKET:-}" ] && [ -f "$CONF" ]; then . "$CONF"; fi
: "${STATE_BUCKET:?set it in the environment or in $CONF}" "${STATE_BUCKET_REGION:?set it in the environment or in $CONF}" "${STATE_KEY_PREFIX:?set it in the environment or in $CONF}"
export STATE_BUCKET STATE_BUCKET_REGION STATE_KEY_PREFIX
IDS=()
SCOPE=()
APPROVE=()
declare -A LISTED=() EMPTY=() DURABLE=() DURABLE_ID=() MANUAL_ID=()
FORCE_DURABLE=0

usage() {
  cat <<'USAGE'
usage: ./tfctl.sh <tier> validate|plan|apply|output|destroy|status [stack|all] [--from <stack>] [--auto-approve] [--durable]
       ./tfctl.sh roll [--auto-approve] [--from <tier>/<stack>]
       ./tfctl.sh unroll [--auto-approve] [--from <tier>/<stack>]
       ./tfctl.sh check [--from <tier>/<stack>]
       ./tfctl.sh order
innovate-inc only: tiers are folders under environments/innovate-inc with a stacks file, named relative to it
(global; <region>: network, edge, internal-alb; <region>/cluster; .../cluster/eks/components; .../app-services; .../ci;
<region> is prod01-us-east-1 or prod01-us-west-2).
Tiers run in rollout order and stacks in <tier>/stacks order; destroy and unroll run in reverse.

apply
  one stack        ./tfctl.sh prod01-us-east-1/cluster/eks/components apply karpenter
  a whole tier     ./tfctl.sh prod01-us-east-1/cluster/eks/components apply all
  from a stack on  ./tfctl.sh prod01-us-east-1/cluster/eks/components apply all --from metrics-server
  everything       ./tfctl.sh roll                   (add --auto-approve to skip the prompts)
  resume a roll    ./tfctl.sh roll --from prod01-us-east-1/cluster/eks
destroy
  one stack        ./tfctl.sh prod01-us-east-1/cluster/eks/components destroy karpenter
  a whole tier     ./tfctl.sh prod01-us-east-1/cluster/eks/components destroy all   (reverse order)
  everything       ./tfctl.sh unroll                 (bottom up: prod01-us-west-2, then prod01-us-east-1, then global;
                                                      each region ci, app-services, components, eks, internal-alb, edge, network)
  a stack is refused while a later stack in the order still holds resources; destroy those first
look before you touch
  ./tfctl.sh order                                   the roll order
  ./tfctl.sh prod01-us-east-1 status                 the regional root stacks (network, edge, internal-alb); any tier the same way
  ./tfctl.sh <tier> status                           clean | drifted | not deployed, per stack
  ./tfctl.sh <tier> plan all                         plans without applying
USAGE
}

tips() {
  local tier=${1:-<tier>}
  cat >&2 <<TIPS
tips: apply one     ./tfctl.sh $tier apply <stack>        destroy one   ./tfctl.sh $tier destroy <stack>
      apply tier    ./tfctl.sh $tier apply all            destroy tier  ./tfctl.sh $tier destroy all
      apply all     ./tfctl.sh roll                       destroy all   ./tfctl.sh unroll
      ./tfctl.sh help for --from, --auto-approve and the guard on destroy
TIPS
}

die() {
  printf 'tfctl: %s\n' "$*" >&2
  exit 1
}

bad_usage() {
  printf 'tfctl: %s\n' "$*" >&2
  usage >&2
  exit 2
}

read_list() {
  local line
  while IFS= read -r line || [[ -n $line ]]; do
    line=${line%%#*}
    line=${line//[[:space:]]/}
    if [[ -n $line ]]; then printf '%s\n' "$line"; fi
  done <"$1"
}

#tier_prefix TIER: "" for the root tier ("."), otherwise "TIER/"; stack ids are <prefix><stack>
tier_prefix() { if [[ $1 == . ]]; then printf ''; else printf '%s/' "$1"; fi; }

load_tier() {
  local tier=$1 dir=$ROOT/$1 s p
  [[ $tier != /* && /$tier/ != */../* && -f $dir/stacks ]] || die "no tier '$tier' (expected $tier/stacks under $(basename "$ROOT")/)"
  p=$(tier_prefix "$tier")
  while IFS= read -r s; do
    [[ $s != */* ]] || die "$tier/stacks: '$s' is a path; list stack folder names only"
    [[ -z ${LISTED[$p$s]:-} ]] || die "$tier/stacks lists '$s' twice"
    [[ -d $dir/$s ]] || die "$tier/stacks lists '$s' but $tier/$s/ does not exist"
    [[ -f $dir/$s/init.sh || -f $dir/init.sh ]] || die "$tier/$s needs $tier/$s/init.sh or $tier/init.sh"
    LISTED[$p$s]=1
    IDS+=("$p$s")
    if [[ -n ${DURABLE[$tier]:-} ]]; then DURABLE_ID[$p$s]=1; fi
  done < <(read_list "$dir/stacks")
  #<tier>/manual lists stacks the walks skip; they run only when named: ./tfctl.sh <tier> apply <stack>
  if [[ -f $dir/manual ]]; then
    while IFS= read -r s; do
      [[ -n ${LISTED[$p$s]:-} ]] || die "$tier/manual lists '$s' but $tier/stacks does not"
      MANUAL_ID[$p$s]=1
    done < <(read_list "$dir/manual")
  fi
}

#drop_manual: IDS without the manual stacks (SCOPE keeps them, so the destroy guard still sees them)
drop_manual() {
  local -a kept=()
  local id
  for id in "${IDS[@]}"; do [[ -n ${MANUAL_ID[$id]:-} ]] || kept+=("$id"); done
  IDS=("${kept[@]}")
}

load_durable() {
  local t
  [[ -f $ROOT/durable ]] || return 0
  while IFS= read -r t; do
    if [[ $t != . ]]; then t=${t#./}; t=${t%/}; fi
    DURABLE[$t]=1
  done < <(read_list "$ROOT/durable")
}

load_rollout() {
  local t
  local -A seen=()
  [[ -f $ROOT/rollout ]] || die "no rollout file next to tfctl.sh"
  load_durable
  while IFS= read -r t; do
    if [[ $t != . ]]; then t=${t#./}; t=${t%/}; fi
    [[ -n $t && -z ${seen[$t]:-} ]] || die "rollout: '$t' is empty or listed twice"
    seen[$t]=1
    load_tier "$t"
  done < <(read_list "$ROOT/rollout")
}

in_rollout() {
  local t
  [[ -f $ROOT/rollout ]] || return 1
  while IFS= read -r t; do
    if [[ $t != . ]]; then t=${t#./}; t=${t%/}; fi
    if [[ $t == "$1" ]]; then return 0; fi
  done < <(read_list "$ROOT/rollout")
  return 1
}

index_of() {
  local i
  for i in "${!IDS[@]}"; do
    if [[ ${IDS[i]} == "$1" ]]; then
      printf '%s\n' "$i"
      return 0
    fi
  done
  return 1
}

need_env() {
  command -v terraform >/dev/null || die "terraform is not on PATH"
}

#in_stack ID MODE [ARGS...]: in a subshell, cd into ID, init it (MODE real|validate|quiet|none), then terraform ARGS
in_stack() (
  local id=$1 mode=$2 out init=../init.sh
  shift 2
  cd "$ROOT/$id" || exit
  if [[ -f ./init.sh ]]; then init=./init.sh; fi
  case $mode in
    none) ;;
    validate)
      #the tier init.sh re-renders provider.auto.tf from the template and passes -backend=false on to terraform init
      out=$(bash "$init" -backend=false -input=false 2>&1) || { printf '%s\n' "$out" >&2; exit 1; } ;;
    quiet) out=$(bash "$init" 2>&1) || { printf '%s\n' "$out" >&2; exit 1; } ;;
    *) bash "$init" || exit ;;
  esac
  if (($#)); then terraform "$@"; fi
)

#prints the number of managed resources in ID's state; state list exits 1 until the first apply writes a state
state_count() {
  local id=$1 out
  in_stack "$id" quiet || return
  if ! out=$(in_stack "$id" none state list 2>&1); then
    [[ $out == *"No state file was found"* ]] || { printf '%s\n' "$out" >&2; return 1; }
    out=
  fi
  awk '$0 != "" && !/^(module\.[^.]+\.)*data\./ { n++ } END { print n + 0 }' <<<"$out"
}

guard() {
  local id=$1 p j n
  for p in "${!SCOPE[@]}"; do
    if [[ ${SCOPE[p]} == "$id" ]]; then break; fi
  done
  for ((j = ${#SCOPE[@]} - 1; j > p; j--)); do
    if [[ -n ${EMPTY[${SCOPE[j]}]:-} ]]; then continue; fi
    n=$(state_count "${SCOPE[j]}") || return
    if ((n)); then
      printf 'tfctl: refusing to destroy %s: %s still holds %d resource(s)\n' "$id" "${SCOPE[j]}" "$n" >&2
      return 1
    fi
    EMPTY[${SCOPE[j]}]=1
  done
}

banner() { printf '==> %s %s\n' "$1" "$2"; }
act_validate() { banner validate "$1" && in_stack "$1" validate validate; }
act_plan() { banner plan "$1" && in_stack "$1" real plan; }
act_apply() { banner apply "$1" && in_stack "$1" real apply "${APPROVE[@]}"; }
act_output() { banner output "$1" && in_stack "$1" quiet output; }
act_destroy() { banner destroy "$1" && guard "$1" && in_stack "$1" real destroy "${APPROVE[@]}" && EMPTY[$1]=1; }

act_status() {
  local id=$1 n out rc=0 word=clean
  n=$(state_count "$id") || return
  if ((n == 0)); then
    word="not deployed"
  else
    out=$(in_stack "$id" none plan -detailed-exitcode -lock=false -input=false 2>&1) || rc=$?
    case $rc in
      0) ;;
      2) word=drifted ;;
      *) printf '%s\n' "$out" >&2; return 1 ;;
    esac
  fi
  printf '%-56s %s\n' "$id" "$word"
}

unlisted() {
  local d
  local p
  p=$(tier_prefix "$1")
  for d in "$ROOT/$1"/*/; do
    d=${d%/}
    [[ -d $d && ! -e $d/stacks ]] || continue
    compgen -G "$d/*.tf" >/dev/null || continue
    [[ -n ${LISTED[$p${d##*/}]:-} ]] || printf '%-56s %s\n' "$p${d##*/}" "not in stacks"
  done
}

#walk VERB ACTION START STEP [RESUME]: ACTION on IDS[START], IDS[START+STEP], ... until the first failure
walk() {
  local verb=$1 action=$2 start=$3 step=$4 resume=${5:-} i n=0
  if ((start >= 0 && start < ${#IDS[@]})); then need_env; fi
  for ((i = start; i >= 0 && i < ${#IDS[@]}; i += step)); do
    if ! "$action" "${IDS[i]}"; then
      printf 'tfctl: %s failed at %s\n' "$verb" "${IDS[i]}" >&2
      if [[ -n $resume ]]; then printf 'tfctl: resume with: %s --from %s\n' "$resume" "${IDS[i]}" >&2; fi
      exit 1
    fi
    n=$((n + 1))
  done
  printf 'tfctl: %s done, %d stack(s)\n' "$verb" "$n"
}

cmd_global() {
  local cmd=$1 from="" start id resume
  shift
  while (($#)); do
    case $1 in
      --auto-approve)
        [[ $cmd == roll || $cmd == unroll ]] || bad_usage "$cmd takes no --auto-approve"
        APPROVE=(-auto-approve -input=false) ;;
      --from)
        [[ $cmd != order && $# -ge 2 ]] || bad_usage "--from <tier>/<stack> applies to roll, unroll and check"
        from=${2%/}
        shift ;;
      *) bad_usage "unknown argument '$1'" ;;
    esac
    shift
  done
  load_rollout
  if [[ $cmd == order ]]; then
    printf 'roll (apply), first to last:\n'
    for id in "${IDS[@]}"; do if [[ -n ${DURABLE_ID[$id]:-} ]]; then printf '  %s (durable)\n' "$id"; elif [[ -n ${MANUAL_ID[$id]:-} ]]; then printf '  %s (manual, skipped)\n' "$id"; else printf '  %s\n' "$id"; fi; done
    printf 'unroll (destroy), last to first, durable tiers kept:\n'
    for ((i = ${#IDS[@]} - 1; i >= 0; i--)); do [[ -n ${DURABLE_ID[${IDS[i]}]:-} || -n ${MANUAL_ID[${IDS[i]}]:-} ]] || printf '  %s\n' "${IDS[i]}"; done
    if ((${#MANUAL_ID[@]})); then printf 'manual, run only by name:\n'; for id in "${!MANUAL_ID[@]}"; do printf '  %s\n' "$id"; done; fi
    printf 'tfctl: %d stack(s), %d durable, %d manual\n' "${#IDS[@]}" "${#DURABLE_ID[@]}" "${#MANUAL_ID[@]}" >&2
    tips prod01-us-east-1/cluster/eks/components
    return
  fi
  if [[ $cmd == unroll ]]; then
    local -a kept=()
    for id in "${IDS[@]}"; do [[ -n ${DURABLE_ID[$id]:-} ]] || kept+=("$id"); done
    IDS=("${kept[@]}")
  fi
  SCOPE=("${IDS[@]}")
  if [[ $cmd == roll || $cmd == unroll ]]; then drop_manual; fi
  start=0
  if [[ $cmd == unroll ]]; then start=$((${#IDS[@]} - 1)); fi
  if [[ -n $from ]]; then start=$(index_of "${from#./}") || die "--from $from: not in roll order (./tfctl.sh order)"; fi
  resume="./tfctl.sh $cmd"
  if ((${#APPROVE[@]})); then resume+=" --auto-approve"; fi
  case $cmd in
    roll) walk roll act_apply "$start" 1 "$resume" ;;
    unroll) walk unroll act_destroy "$start" -1 "$resume" ;;
    check) walk check act_validate "$start" 1 "$resume" ;;
  esac
}

cmd_tier() {
  local tier=$1 verb=${2:-} target="" from="" resume="" start id p
  if [[ $tier == root || $tier == ./ ]]; then tier=.; fi
  if [[ $tier != . ]]; then tier=${tier#./}; tier=${tier%/}; fi
  p=$(tier_prefix "$tier")
  case $verb in
    validate | plan | apply | output | destroy | status) ;;
    *) bad_usage "unknown command '$*'" ;;
  esac
  shift 2
  while (($#)); do
    case $1 in
      --from)
        (($# >= 2)) || bad_usage "--from needs a stack name"
        from=$2
        shift ;;
      --auto-approve)
        [[ $verb == apply || $verb == destroy ]] || bad_usage "$verb takes no --auto-approve"
        APPROVE=(-auto-approve -input=false) ;;
      --durable)
        [[ $verb == destroy ]] || bad_usage "--durable applies to destroy"
        FORCE_DURABLE=1 ;;
      -*) bad_usage "unknown option '$1'" ;;
      *)
        [[ -z $target ]] || bad_usage "one stack or all, not both '$target' and '$1'"
        target=$1 ;;
    esac
    shift
  done
  if [[ $verb == destroy ]] && in_rollout "$tier"; then
    load_rollout
    if [[ -n ${DURABLE[$tier]:-} && $FORCE_DURABLE == 0 ]]; then die "$tier is durable (./durable): unroll keeps it; add --durable to destroy it anyway"; fi
    SCOPE=()
    for id in "${IDS[@]}"; do [[ -n ${DURABLE_ID[$id]:-} && ${id%/*} != "$tier" ]] || SCOPE+=("$id"); done
    IDS=()
    for id in "${SCOPE[@]}"; do
      if [[ $tier == . && $id != */* ]] || [[ $tier != . && ${id%/*} == "$tier" ]]; then IDS+=("$id"); fi
    done
  else
    load_tier "$tier"
    SCOPE=("${IDS[@]}")
  fi
  if [[ -n $target && $target != all ]]; then
    [[ -z $from ]] || bad_usage "--from applies to all, not to one stack"
    [[ -n ${LISTED[$p$target]:-} ]] || die "$tier/stacks does not list '$target'"
    IDS=("$p$target")
  elif [[ $verb == apply || $verb == destroy ]]; then
    drop_manual
  fi
  start=0
  if [[ $verb == destroy ]]; then start=$((${#IDS[@]} - 1)); fi
  if [[ -n $from ]]; then start=$(index_of "$p${from#"$p"}") || die "$tier/stacks does not list '$from'"; fi
  if [[ -z $target || $target == all ]]; then resume="./tfctl.sh $tier $verb all"; if ((${#APPROVE[@]})); then resume+=" --auto-approve"; fi; fi
  if [[ $verb == status ]]; then unlisted "$tier"; fi
  if [[ $verb == destroy ]]; then walk destroy act_destroy "$start" -1 "$resume"; else walk "$verb" "act_$verb" "$start" 1 "$resume"; fi
  if [[ $verb == status || $verb == plan ]]; then tips "$tier"; fi
}

main() {
  (($#)) || bad_usage "no command given"
  case $1 in
    -h | --help | help) usage ;;
    order | check | roll | unroll) cmd_global "$@" ;;
    *) cmd_tier "$@" ;;
  esac
}

main "$@"
