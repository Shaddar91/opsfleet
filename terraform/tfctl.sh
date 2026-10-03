#!/usr/bin/env bash
#tfctl.sh: system tiers only (buckets, zones, OIDC, key, ECR, GitHub repos, access). The environments have their own script: environments/innovate-inc/tfctl.sh.
#roll, unroll, check and order walk every tier listed in ./rollout. ./tfctl.sh help prints the verbs.
set -euo pipefail
((BASH_VERSINFO[0] * 100 + BASH_VERSINFO[1] >= 404)) || { echo "tfctl: needs bash 4.4 or newer" >&2; exit 1; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="${OPSFLEET_ENV_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/opsfleet/${OPSFLEET_ACCOUNT:-personal}.env}"
if [ -z "${STATE_BUCKET:-}" ] && [ -f "$CONF" ]; then . "$CONF"; fi
: "${STATE_BUCKET:?set it in the environment or in $CONF}" "${STATE_BUCKET_REGION:?set it in the environment or in $CONF}" "${STATE_KEY_PREFIX:?set it in the environment or in $CONF}"
export STATE_BUCKET STATE_BUCKET_REGION STATE_KEY_PREFIX
BOOT_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/opsfleet"
IDS=()
SCOPE=()
APPROVE=()
declare -A LISTED=() EMPTY=() DURABLE=() DURABLE_ID=()
FORCE_DURABLE=0

usage() {
  cat <<'USAGE'
usage: ./tfctl.sh <tier> validate|plan|apply|output|destroy|status [stack|all] [--from <stack>] [--auto-approve] [--durable]
       ./tfctl.sh roll [--auto-approve] [--from <tier>/<stack>]
       ./tfctl.sh unroll [--auto-approve] [--from <tier>/<stack>]
       ./tfctl.sh check [--from <tier>/<stack>]
       ./tfctl.sh order
A tier is a system folder with a stacks file (system/s3, system/r53, system/iam, system, system/ecr, system/github, system/access).
Tiers run in rollout order and stacks in <tier>/stacks order; destroy and unroll run in reverse.

apply
  one stack        ./tfctl.sh system/ecr apply of-api
  a whole tier     ./tfctl.sh system/ecr apply all
  from a stack on  ./tfctl.sh system/ecr apply all --from frontend-web
  everything       ./tfctl.sh roll                   (add --auto-approve to skip the prompts)
  resume a roll    ./tfctl.sh roll --from system/ecr/of-api
destroy
  one stack        ./tfctl.sh system/ecr destroy of-api
  a whole tier     ./tfctl.sh system/ecr destroy all   (reverse order)
  everything       ./tfctl.sh unroll                 (every system tier is listed in ./durable, so unroll keeps them all)
  a durable tier   ./tfctl.sh system/ecr destroy all --durable   (refused without the flag)
  a stack is refused while a later stack in the order still holds resources; destroy those first
look before you touch
  ./tfctl.sh order                                   roll order, then the destroy order
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

load_tier() {
  local tier=$1 dir=$ROOT/$1 s
  [[ $tier != /* && /$tier/ != */../* && -f $dir/stacks ]] || die "no tier '$tier' (expected $tier/stacks under terraform/)"
  while IFS= read -r s; do
    [[ $s != */* ]] || die "$tier/stacks: '$s' is a path; list stack folder names only"
    [[ -z ${LISTED[$tier/$s]:-} ]] || die "$tier/stacks lists '$s' twice"
    [[ -d $dir/$s ]] || die "$tier/stacks lists '$s' but $tier/$s/ does not exist"
    [[ ! -e $dir/$s/init.sh ]] || die "$tier/$s holds its own init.sh: a nested tier goes in rollout, not in $tier/stacks"
    [[ -e $dir/$s/.bootstrap || -x $dir/init.sh ]] || die "$tier/$s needs an executable $tier/init.sh"
    LISTED[$tier/$s]=1
    IDS+=("$tier/$s")
    if [[ -n ${DURABLE[$tier]:-} ]]; then DURABLE_ID[$tier/$s]=1; fi
  done < <(read_list "$dir/stacks")
}

load_durable() {
  local t
  [[ -f $ROOT/durable ]] || return 0
  while IFS= read -r t; do
    t=${t#./}
    DURABLE[${t%/}]=1
  done < <(read_list "$ROOT/durable")
}

load_rollout() {
  local t
  local -A seen=()
  [[ -f $ROOT/rollout ]] || die "no rollout file next to tfctl.sh"
  load_durable
  while IFS= read -r t; do
    t=${t#./}
    t=${t%/}
    [[ -n $t && -z ${seen[$t]:-} ]] || die "rollout: '$t' is empty or listed twice"
    seen[$t]=1
    load_tier "$t"
  done < <(read_list "$ROOT/rollout")
}

in_rollout() {
  local t
  [[ -f $ROOT/rollout ]] || return 1
  while IFS= read -r t; do
    t=${t#./}
    if [[ ${t%/} == "$1" ]]; then return 0; fi
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

label() {
  if [[ -e $ROOT/$1/.bootstrap ]]; then printf '%s (bootstrap)\n' "$1"; else printf '%s\n' "$1"; fi
}

need_env() {
  command -v terraform >/dev/null || die "terraform is not on PATH"
}

#in_stack ID MODE [ARGS...]: in a subshell, cd into ID, init it (MODE real|validate|quiet|none), then terraform ARGS
in_stack() (
  local id=$1 mode=$2 out
  local -a init=(../init.sh)
  shift 2
  cd "$ROOT/$id" || exit
  #one init per state bucket: switching accounts needs no -reconfigure, and a changed key in one account still stops init
  export TF_DATA_DIR=".terraform/$STATE_BUCKET"
  if [[ -e .bootstrap ]]; then
    export TF_VAR_state_bucket_name="$STATE_BUCKET" TF_VAR_region="${STATE_BUCKET_REGION:-us-east-1}"
    init=(terraform init -reconfigure "-backend-config=path=$BOOT_STATE_DIR/$STATE_BUCKET/${id//\//-}.tfstate")
    if [[ $mode == validate ]]; then init=(terraform init); fi
    if [[ $mode == real || $mode == quiet ]]; then (umask 077 && mkdir -p "$BOOT_STATE_DIR/$STATE_BUCKET") || exit; fi
  fi
  if [[ $mode == validate ]]; then init+=(-backend=false); fi
  case $mode in
    none) ;;
    quiet) out=$("${init[@]}" -input=false 2>&1) || { printf '%s\n' "$out" >&2; exit 1; } ;;
    *) "${init[@]}" || exit ;;
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

banner() { printf '==> %s %s\n' "$1" "$(label "$2")"; }
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
  printf '%-44s %s\n' "$id" "$word"
}

unlisted() {
  local d
  for d in "$ROOT/$1"/*/; do
    d=${d%/}
    [[ -d $d && ! -e $d/init.sh ]] || continue
    compgen -G "$d/*.tf" >/dev/null || [[ -e $d/.bootstrap ]] || continue
    [[ -n ${LISTED[$1/${d##*/}]:-} ]] || printf '%-44s %s\n' "$1/${d##*/}" "not in stacks"
  done
}

#walk VERB ACTION START STEP [RESUME]: ACTION on IDS[START], IDS[START+STEP], ... until the first failure
walk() {
  local verb=$1 action=$2 start=$3 step=$4 resume=${5:-} i n=0 net=online
  if [[ $verb == check || $verb == validate ]]; then net=offline; fi
  if ((start >= 0 && start < ${#IDS[@]})); then need_env "$net"; fi
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
  local cmd=$1 from="" start id resume i
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
    for id in "${IDS[@]}"; do if [[ -n ${DURABLE_ID[$id]:-} ]]; then printf '  %s (durable)\n' "$(label "$id")"; else printf '  %s\n' "$(label "$id")"; fi; done
    printf 'unroll (destroy), last to first, durable tiers kept:\n'
    for ((i = ${#IDS[@]} - 1; i >= 0; i--)); do [[ -n ${DURABLE_ID[${IDS[i]}]:-} ]] || printf '  %s\n' "$(label "${IDS[i]}")"; done
    printf 'tfctl: %d stack(s), %d durable\n' "${#IDS[@]}" "${#DURABLE_ID[@]}" >&2
    tips system/ecr
    return
  fi
  if [[ $cmd == unroll ]]; then
    local -a kept=()
    for id in "${IDS[@]}"; do [[ -n ${DURABLE_ID[$id]:-} ]] || kept+=("$id"); done
    IDS=("${kept[@]}")
  fi
  SCOPE=("${IDS[@]}")
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
  local tier=${1#./} verb=${2:-} target="" from="" resume="" start id
  tier=${tier%/}
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
      if [[ ${id%/*} == "$tier" ]]; then IDS+=("$id"); fi
    done
  else
    load_tier "$tier"
    SCOPE=("${IDS[@]}")
  fi
  if [[ -n $target && $target != all ]]; then
    [[ -z $from ]] || bad_usage "--from applies to all, not to one stack"
    [[ -n ${LISTED[$tier/$target]:-} ]] || die "$tier/stacks does not list '$target'"
    IDS=("$tier/$target")
  fi
  start=0
  if [[ $verb == destroy ]]; then start=$((${#IDS[@]} - 1)); fi
  if [[ -n $from ]]; then start=$(index_of "$tier/${from#"$tier"/}") || die "$tier/stacks does not list '$from'"; fi
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
