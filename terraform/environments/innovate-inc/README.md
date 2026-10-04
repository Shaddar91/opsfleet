# tfctl

For the region work, this assignment included, use the region runner below; `terraform/tfctl.sh` is only for the account-wide system tiers, set up once per account.

Two runners. System tiers (buckets, zones, OIDC, key, ECR, GitHub repos, access): `terraform/tfctl.sh`. A region: `terraform/environments/innovate-inc/<region>/tfctl.sh`. Both read `STATE_BUCKET`, `STATE_BUCKET_REGION` and `STATE_KEY_PREFIX` from the environment or from the account env file (`$OPSFLEET_ENV_FILE`, default `${XDG_CONFIG_HOME:-$HOME/.config}/opsfleet/<account>.env`).

## Secrets first

Every `secrets.auto.tfvars` and the account env file are git-ignored. Their copies live in Secrets Manager, one secret per file, in the store region (`OPSFLEET_SECRETS_REGION`, default `us-east-1`). The list of files is `system/secret-store/tfvars/terraform.tfvars`. `terraform/tf-secrets.sh` moves them:

```bash
./tf-secrets.sh pull config/opsfleet.env      # fresh machine: the account env file, needs only AWS credentials
./tf-secrets.sh pull                          # every file missing locally; --force also overwrites existing ones
./tf-secrets.sh pull --region prod01-us-east-1   # the shared stacks' files and that region's
./tf-secrets.sh push                          # after editing a secrets file; unchanged files are skipped
./tf-secrets.sh diff                          # which files differ between disk and store
./tf-secrets.sh list                          # every known file, with store and local presence
```

A region `apply` or `plan` runs `pull --region <region>` by itself and stops if a file is missing in both places. The system runner does not pull: run `./tf-secrets.sh pull` before `roll` or a tier apply.

Order of the regions: prod01-us-east-1 first, prod01-us-west-2 after it. The west aurora stack joins the global database through the east state, and the failover tier reads both regions' aurora and edge states.

## A region

Run from the region folder (`prod01-us-east-1`, `prod01-us-west-2`). A stack is its path under the region, as `order` prints it. Without `--auto-approve` every stack prompts.

```bash
./tfctl.sh order                                     # stack ids, apply order
./tfctl.sh plan all                                  # plan every stack, change nothing
./tfctl.sh plan aurora                               # plan one stack
./tfctl.sh apply --auto-approve                      # every stack in order
./tfctl.sh apply aurora --auto-approve               # one stack only
./tfctl.sh apply all --from aurora --auto-approve    # aurora, then every stack after it
./tfctl.sh destroy aurora --auto-approve             # one stack
./tfctl.sh destroy --auto-approve                    # every stack, last to first
```

`apply` and `destroy` with no stack walk the whole list. In prod01-us-east-1 the walk also applies the two shared stacks listed in `prod01-us-east-1/shared` (the hosted zones and `global-accelerator`) when their plan has changes; a single-stack apply does not. prod01-us-west-2 has no `shared` file and never plans, applies or destroys them.

## After a failure

The walk stops at the failed stack and prints the line that continues from it:

```
tfctl: apply failed at aurora
tfctl: resume with: ./tfctl.sh apply all --auto-approve --from aurora
```

Fix the cause, run that line. Stacks before the failed one are left alone. The failed stack keeps what it managed to create, so the rerun adds only what is missing.

`--from` needs `all`; `--from` with a single stack name is refused.

## System tiers

Run from `terraform/`, after `./tf-secrets.sh pull`. Tiers: `system/s3`, `system/r53`, `system/iam`, `system`, `system/ecr`, `system/github`, `system/access`.

```bash
./tfctl.sh order                                     # every system stack, apply order
./tfctl.sh <tier> status                             # clean | drifted | not deployed, per stack
./tfctl.sh <tier> plan all
./tfctl.sh <tier> apply <stack> --auto-approve
./tfctl.sh <tier> apply all --from <stack> --auto-approve
./tfctl.sh roll --auto-approve [--from <tier>/<stack>]   # every tier in order
./tfctl.sh <tier> destroy <stack> --auto-approve
./tfctl.sh <tier> destroy all --durable --auto-approve   # refused without --durable
./tfctl.sh unroll --auto-approve                     # every tier, reverse order; tiers listed in terraform/durable are kept (today: all of them)
```

## Messages and what to do

| Message | Do |
|---|---|
| `resume with: ... --from <stack>` | Fix the cause, run that line. |
| `'<x>' is not in the <region> order` | Use the id as `order` prints it: `cluster/eks/components/karpenter`, not `karpenter`. |
| `--from applies to all, not to one stack` | Add `all`: `apply all --from <stack>`. |
| `refusing to destroy <x>: <y> still holds N resource(s)` | Destroy `<y>` first, or run `destroy` with no stack to walk backwards. |
| `a secrets.auto.tfvars file this region needs is missing locally and in Secrets Manager` | The file is in neither place. Recreate it locally, then `./tf-secrets.sh push`. `./tf-secrets.sh list` shows which one. |
| `set it in the environment or in <path>.env` | The account env file is missing: `./tf-secrets.sh pull config/opsfleet.env`, or export the three `STATE_*` variables. |
| `Unsupported attribute ... "accelerator_..."` on a region stack | `global-accelerator` is not applied. Run `prod01-us-east-1/tfctl.sh apply ../global/global-accelerator --auto-approve`, then retry. A full prod01-us-east-1 apply does this by itself. |
| `is deployed and up to date, skipped` | A shared stack with no changes; nothing to do. |
