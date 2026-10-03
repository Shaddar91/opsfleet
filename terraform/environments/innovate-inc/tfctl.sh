#!/usr/bin/env bash
#tfctl.sh: one innovate-inc region at a time; prod01-us-east-1/tfctl.sh and prod01-us-west-2/tfctl.sh start it for their folder.
#apply walks the shared stacks every region needs, then the region's tiers (<region>/rollout, each tier's stacks file); destroy walks back.
set -euo pipefail
((BASH_VERSINFO[0] * 100 + BASH_VERSINFO[1] >= 404)) || { echo "tfctl: needs bash 4.4 or newer" >&2; exit 1; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="${OPSFLEET_ENV_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/opsfleet/${OPSFLEET_ACCOUNT:-personal}.env}"
if [ -z "${STATE_BUCKET:-}" ] && [ -f "$CONF" ]; then . "$CONF"; fi
: "${STATE_BUCKET:?set it in the environment or in $CONF}" "${STATE_BUCKET_REGION:?set it in the environment or in $CONF}" "${STATE_KEY_PREFIX:?set it in the environment or in $CONF}"
export STATE_BUCKET STATE_BUCKET_REGION STATE_KEY_PREFIX
#shared stacks, relative to a region folder, in apply order: the hosted zones, then the accelerator that publishes into them
SHARED=(../../../system/r53/opsfleet ../global/global-accelerator)
#global stacks that also hold a shared stack's outputs; sibling regions are added at run time
declare -A EXTRA_USERS=([../../../system/r53/opsfleet]=../global/frontend)
REGION='' REGION_DIR='' ENTRY='' HOLDER=''
WALK=0
IDS=()
SCOPE=()
ELSEWHERE=()
APPROVE=()
declare -A LISTED=() EMPTY=() IS_SHARED=()

usage() {
  cat <<'USAGE'
usage: ./tfctl.sh apply|plan|destroy [<stack>|all] [--from <stack>] [--auto-approve]
       ./tfctl.sh order
Run it from a region folder (prod01-us-east-1/tfctl.sh, prod01-us-west-2/tfctl.sh). From environments/innovate-inc name the
region first: ./tfctl.sh prod01-us-east-1 apply. A stack is its path under the region: network, cluster/eks,
cluster/eks/components/karpenter, app-services/of-load.

apply walks the region's tiers in <region>/rollout order, each tier in its stacks file order, after the two stacks every region
needs: the hosted zones (../../../system/r53/opsfleet) and the accelerator (../global/global-accelerator). A shared stack is
applied only when its plan shows changes, so the second region finds it and moves on. destroy walks the same list backwards and
keeps a shared stack while another region, or global/frontend for the zones, still holds resources. Any destroy is refused while
a later stack still holds resources. The buckets, keys, ECR and GitHub stacks belong to terraform/tfctl.sh; ci/ and
global/frontend are not walked: run them by hand (cd <stack> && ../init.sh && terraform apply).

apply
  everything       ./tfctl.sh apply                       (--auto-approve skips the prompts)
  one stack        ./tfctl.sh apply cluster/eks
  resume           ./tfctl.sh apply all --from cluster/eks/components/karpenter
plan               ./tfctl.sh plan [<stack>|all]          changes nothing
destroy
  everything       ./tfctl.sh destroy                     app-services, components, eks, internal-alb, edge, network, then the shared stacks
  one stack        ./tfctl.sh destroy cluster/eks
order              ./tfctl.sh order                       the list, first to last
USAGE
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

#load_region DIR PREFIX ARRAY: appends DIR's stacks as PREFIX<tier>/<stack>, tier by tier from DIR/rollout and each tier's stacks file
load_region() {
  local dir=$1 prefix=$2 name=${1##*/} t s p
  local -n out=$3
  local -A seen=()
  [[ -f $dir/rollout ]] || die "no region '$name' (expected $name/rollout under ${ROOT##*/}/)"
  while IFS= read -r t; do
    if [[ $t != . ]]; then t=${t#./}; t=${t%/}; fi
    [[ -n $t && -z ${seen[$t]:-} ]] || die "$name/rollout: '$t' is empty or listed twice"
    seen[$t]=1
    [[ $t != /* && /$t/ != */../* && -f $dir/$t/stacks ]] || die "$name/rollout lists '$t' but $name/$t/stacks does not exist"
    [[ -f $dir/$t/init.sh ]] || die "$name/$t needs an init.sh"
    if [[ $t == . ]]; then p=; else p=$t/; fi
    while IFS= read -r s; do
      [[ $s != */* ]] || die "$name/$t/stacks: '$s' is a path; list stack folder names only"
      [[ -d $dir/$t/$s ]] || die "$name/$t/stacks lists '$s' but $name/$t/$s/ does not exist"
      [[ -z ${LISTED[$prefix$p$s]:-} ]] || die "$name/$t/stacks lists '$s' twice"
      LISTED[$prefix$p$s]=1
      out+=("$prefix$p$s")
    done < <(read_list "$dir/$t/stacks")
  done < <(read_list "$dir/rollout")
}

#siblings: the other region folders, each one with a rollout file
siblings() {
  local d
  for d in "$ROOT"/*/; do
    d=${d%/}
    if [[ -f $d/rollout && $d != "$REGION_DIR" ]]; then printf '%s\n' "${d##*/}"; fi
  done
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

#in_stack ID MODE [ARGS...]: in a subshell, cd into ID under the region folder, run the tier's init.sh (MODE real|quiet|none), then terraform ARGS
in_stack() (
  local id=$1 mode=$2 out
  shift 2
  cd "$REGION_DIR/$id" || exit
  case $mode in
    none) ;;
    quiet) out=$(bash ../init.sh 2>&1) || { printf '%s\n' "$out" >&2; exit 1; } ;;
    *) bash ../init.sh || exit ;;
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

#up_to_date ID: 0 when ID's plan shows no changes, 1 when it has changes or no state yet, 2 when the plan itself fails
up_to_date() {
  local id=$1 out rc=0
  in_stack "$id" quiet || return 2
  out=$(in_stack "$id" none plan -detailed-exitcode -input=false 2>&1) || rc=$?
  case $rc in
    0) return 0 ;;
    2) return 1 ;;
    *) printf '%s\n' "$out" >&2; return 2 ;;
  esac
}

#holder ID: sets HOLDER to the first stack after ID in SCOPE, or for a shared ID anywhere else, that still holds resources; empty when none does
holder() {
  local id=$1 p j u n
  local -a users=() extra=()
  HOLDER=''
  for p in "${!SCOPE[@]}"; do
    if [[ ${SCOPE[p]} == "$id" ]]; then break; fi
  done
  for ((j = ${#SCOPE[@]} - 1; j > p; j--)); do users+=("${SCOPE[j]}"); done
  if [[ -n ${IS_SHARED[$id]:-} ]]; then
    read -ra extra <<<"${EXTRA_USERS[$id]:-}"
    users+=("${extra[@]}" "${ELSEWHERE[@]}")
  fi
  for u in "${users[@]}"; do
    if [[ -n ${EMPTY[$u]:-} ]]; then continue; fi
    n=$(state_count "$u") || return
    if ((n)); then
      HOLDER="$u still holds $n resource(s)"
      return 0
    fi
    EMPTY[$u]=1
  done
}

banner() { printf '==> %s %s\n' "$1" "$2"; }
act_plan() { banner plan "$1" && in_stack "$1" real plan; }

act_apply() {
  local id=$1 rc=0
  banner apply "$id"
  if [[ -n ${IS_SHARED[$id]:-} ]]; then
    up_to_date "$id" || rc=$?
    ((rc != 2)) || return 1
    if ((rc == 0)); then printf 'tfctl: %s is deployed and up to date, skipped\n' "$id"; return 0; fi
  fi
  in_stack "$id" real apply "${APPROVE[@]}"
}

#a shared stack still in use is kept by a walk and refused by name; any other stack in use is refused
act_destroy() {
  local id=$1
  banner destroy "$id"
  holder "$id" || return
  if [[ -n $HOLDER ]]; then
    if [[ -n ${IS_SHARED[$id]:-} && $WALK == 1 ]]; then
      printf 'tfctl: keeping %s: %s\n' "$id" "$HOLDER"
      return 0
    fi
    printf 'tfctl: refusing to destroy %s: %s\n' "$id" "$HOLDER" >&2
    return 1
  fi
  in_stack "$id" real destroy "${APPROVE[@]}" && EMPTY[$id]=1
}

#walk VERB ACTION START STEP [RESUME]: ACTION on IDS[START], IDS[START+STEP], ... until the first failure
walk() {
  local verb=$1 action=$2 start=$3 step=$4 resume=${5:-} i n=0
  if ((start >= 0 && start < ${#IDS[@]})); then command -v terraform >/dev/null || die "terraform is not on PATH"; fi
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

order() {
  local id
  printf 'apply, first to last; destroy walks it last to first:\n'
  for id in "${IDS[@]}"; do
    if [[ -n ${IS_SHARED[$id]:-} ]]; then printf '  %s (shared: applied when its plan has changes, kept on destroy while anything else uses it)\n' "$id"; else printf '  %s\n' "$id"; fi
  done
  printf 'tfctl: %d stack(s)\n' "${#IDS[@]}" >&2
}

cmd() {
  local verb=$1 target="" from="" resume="" start s
  shift
  while (($#)); do
    case $1 in
      --from)
        (($# >= 2)) || bad_usage "--from needs a stack"
        from=${2#./}
        from=${from%/}
        shift ;;
      --auto-approve)
        [[ $verb != plan ]] || bad_usage "plan takes no --auto-approve"
        APPROVE=(-auto-approve -input=false) ;;
      -*) bad_usage "unknown option '$1'" ;;
      *)
        [[ -z $target ]] || bad_usage "one stack or all, not both '$target' and '$1'"
        target=${1#./}
        target=${target%/} ;;
    esac
    shift
  done
  SCOPE=("${IDS[@]}")
  if [[ -n $target && $target != all ]]; then
    [[ -z $from ]] || bad_usage "--from applies to all, not to one stack"
    [[ -n ${LISTED[$target]:-} ]] || die "'$target' is not in the $REGION order ($ENTRY order)"
    IDS=("$target")
  fi
  start=0
  if [[ $verb == destroy ]]; then start=$((${#IDS[@]} - 1)); fi
  if [[ -n $from ]]; then start=$(index_of "$from") || die "--from $from: not in the $REGION order ($ENTRY order)"; fi
  if [[ -z $target || $target == all ]]; then
    WALK=1
    resume="$ENTRY $verb all"
    if ((${#APPROVE[@]})); then resume+=" --auto-approve"; fi
  fi
  if [[ $verb == destroy ]]; then
    for s in $(siblings); do load_region "$ROOT/$s" "../$s/" ELSEWHERE; done
    walk destroy act_destroy "$start" -1 "$resume"
  else
    walk "$verb" "act_$verb" "$start" 1 "$resume"
  fi
}

main() {
  local s
  (($#)) || bad_usage "no region given"
  case $1 in -h | --help | help) usage; return ;; esac
  REGION=${1#./}
  REGION=${REGION%/}
  REGION_DIR=$ROOT/$REGION
  ENTRY=${TFCTL_ENTRY:-$0 $REGION}
  shift
  [[ $REGION != */* && -f $REGION_DIR/rollout ]] || die "no region '$REGION' (expected $REGION/rollout under ${ROOT##*/}/)"
  for s in "${SHARED[@]}"; do
    [[ -d $REGION_DIR/$s && -f $REGION_DIR/$s/../init.sh ]] || die "shared stack $s is missing or has no init.sh beside it"
    IS_SHARED[$s]=1
    LISTED[$s]=1
    IDS+=("$s")
  done
  load_region "$REGION_DIR" "" IDS
  (($#)) || bad_usage "no command given"
  case $1 in
    -h | --help | help) usage ;;
    order) order ;;
    apply | plan | destroy) cmd "$@" ;;
    *) bad_usage "unknown command '$1'" ;;
  esac
}

main "$@"
