# EKS with Karpenter on x86 and Graviton

Terraform for a dedicated VPC, an EKS cluster, and Karpenter launching x86 and Graviton (arm64) nodes on Spot. It deploys to `us-east-1` as the environment `prod01-us`.

## What it builds

- `environments/innovate-inc/prod01-us-east-1/network`: a VPC across three availability zones with public, private and internal subnets, one NAT gateway, an S3 gateway endpoint, and a Graviton Spot bastion reached through SSM Session Manager.
- `environments/innovate-inc/prod01-us-east-1/cluster/eks`: the EKS cluster `prod01-us-eks`, Kubernetes 1.36, in the private subnets. Two Spot node groups labeled `role=system`, one x86 and one Graviton, run the controllers. The identity that applies this stack becomes cluster admin, and the public API endpoint accepts only the IP it was applied from.
- `environments/innovate-inc/prod01-us-east-1/edge`: a public ALB with ACM, an HTTP to HTTPS redirect, WAF and access logs. `environments/innovate-inc/global/global-accelerator` fronts it with Global Accelerator, one endpoint group per region, and `global/frontend` is the CloudFront site; both are global services, so a second region only adds an endpoint group.
- `environments/innovate-inc/prod01-us-east-1/cluster/eks/components`: namespaces, AWS Load Balancer Controller, EBS CSI driver with a gp3 default StorageClass, metrics-server, external-dns, Argo CD, and Karpenter with one `EC2NodeClass` on Amazon Linux 2023 and the two NodePools below. Both NodePools allow Spot and On-Demand instances from the c, m and r categories, generation 6 or newer; Karpenter picks Spot first and falls back to On-Demand.

| NodePool | Arch | Taint | vCPU cap |
|---|---|---|---|
| `x86` | amd64 | none | 100 |
| `graviton` | arm64 | `arch=arm64:NoSchedule` | 50 |

`roll` also applies the rest of the environment tier (`internal-alb`) and the global tier (`global-accelerator`, `frontend`) and the `app-services` and `ci` tiers; `./tfctl.sh order` lists the system stacks and `environments/innovate-inc/tfctl.sh order` the environment ones.

## Layout

- A stack is one Terraform root with its own state. A tier is a folder of stacks that share its `init.sh`, `provider.tf.tmpl` and `shared-variables.tf`.
- `<tier>/stacks` lists the tier's stacks in apply order, and `rollout` lists the tiers in apply order: the account-wide `system/*` tiers (state, Ansible and artifact buckets, Route 53 zone, GitHub OIDC, SSH key, ECR, GitHub repositories), then `environments/innovate-inc/prod01-us-east-1` with its `cluster`, `cluster/eks/components`, `app-services` and `ci` tiers, and `system/access` last.
- `init.sh` renders the stack's `provider.auto.tf` from the template: provider versions, the S3 backend key and the upstream states the stack reads. `tfctl.sh` runs it for you.
- `system/s3/state-bucket` creates the state bucket, so its own state stays on your machine under `${XDG_STATE_HOME:-$HOME/.local/state}/opsfleet/`.
- `modules/` holds the modules the stacks call, such as `kubernetes/cluster-05` and `network/network-1.4.1`.

## Prerequisites

- Terraform 1.16.0 exactly (every `provider.tf.tmpl` pins it), bash 4.4 or newer, `envsubst`, the AWS CLI and kubectl. The Kubernetes, Helm and kubectl providers get their token from `aws eks get-token`.
- Credentials for an IAM user or role in the target account; `cluster/eks` refuses the root user.
- A state bucket of your own, given as `STATE_BUCKET`, `STATE_BUCKET_REGION` and `STATE_KEY_PREFIX`. No file in the repo names it: `tfctl.sh` and every `init.sh` take the three from the environment or from the env file `$OPSFLEET_ENV_FILE` points to, and stop if one is missing.
- Site values exported from that same file outside the repo. Building the network, cluster and Karpenter needs `TF_VAR_create_state_bucket` (`true` creates the bucket, `false` uses an existing one), `TF_VAR_ansible_bucket_name`, `TF_VAR_parent_zone_name` (an existing public Route 53 zone), `TF_VAR_domain_name` (a subdomain of it) and `TF_VAR_bastion_public_key`.
- The full rollout also needs `TF_VAR_create_provider` (`false` if the account already has a GitHub OIDC provider), `TF_VAR_github_owner`, `GITHUB_TOKEN`, `TF_VAR_edge_log_bucket_name`, `TF_VAR_web_bucket_name`, `TF_VAR_log_bucket_name`, and the `CHANGEME` values that `grep -rl CHANGEME --exclude=README.md .` lists. Each stack's `sensitive` variables take their values from its git-ignored `secrets.auto.tfvars`.

## Run it

From `terraform/`:

```bash
./tfctl.sh order     # every stack, in apply order
./tfctl.sh check     # init -backend=false and validate on every stack, no AWS calls
./tfctl.sh roll      # apply every stack in order; --auto-approve skips the prompts
```

After a failure, `roll`, `unroll` and `check` print the `--from` line that resumes at the failed stack. `./tfctl.sh <tier> validate|plan|apply|output|destroy|status [stack|all]` runs one verb on one tier or one stack, for example `./tfctl.sh environments/innovate-inc/prod01-us-east-1/cluster plan eks`. To build only the network, the cluster, Karpenter and developer access, apply in this order:

```bash
./tfctl.sh system/s3 apply state-bucket
./tfctl.sh system/s3 apply ansible-bucket
./tfctl.sh system/r53 apply all
./tfctl.sh system apply all
./tfctl.sh environments/innovate-inc/prod01-us-east-1 apply network
./tfctl.sh environments/innovate-inc/prod01-us-east-1/cluster apply eks
for s in namespaces karpenter-aws karpenter; do ./tfctl.sh environments/innovate-inc/prod01-us-east-1/cluster/eks/components apply "$s"; done
./tfctl.sh system/access apply all
```

## Run it from GitHub Actions

`.github/workflows/terraform.yml` runs one stack by hand (Actions, terraform, Run workflow: tier, stack, apply). The `plan` job runs on the default branch; with apply ticked, the `apply` job waits in the `terraform` environment until a reviewer approves it. Both jobs authenticate over GitHub OIDC, so no credentials are stored in GitHub, and the values a local run takes from the env file and `secrets.auto.tfvars` come from Vault at run time, masked. The roles come from `system/iam/terraform-ci` (ReadOnlyAccess to plan, AdministratorAccess to apply), and the logs show only resource addresses and totals.

## Run a pod on x86 or Graviton

Developers reach the cluster as the role `prod01-us-developers-deploy-role`, whose access entry grants edit rights in the `of` namespace and nothing cluster-wide. An admin adds the developer's IAM user to the `prod01-us-developers` group and hands over the `kubeconfig_command` that `./tfctl.sh system/access output developers` prints. The developer runs it with their own credentials, from the IP the API endpoint accepts (`public_access_cidrs` in `cluster/eks/locals.tf`).

Choose the architecture with a `nodeSelector` on `kubernetes.io/arch` and use an image built for it; `public.ecr.aws/nginx/nginx:stable` has both. Set it on x86 pods as well, because the Graviton system node group has no taint and a pod without a selector can land on arm64. The Graviton pod also tolerates the `arch=arm64:NoSchedule` taint on Karpenter's Graviton nodes. Save the two manifests as `hello-x86.yaml` and `hello-graviton.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata: {name: hello-x86, namespace: of}
spec:
  replicas: 2
  selector: {matchLabels: {app: hello-x86}}
  template:
    metadata: {labels: {app: hello-x86}}
    spec:
      nodeSelector:
        kubernetes.io/arch: amd64
      containers:
        - name: nginx
          image: public.ecr.aws/nginx/nginx:stable
          resources: {requests: {cpu: 100m, memory: 128Mi}}
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata: {name: hello-graviton, namespace: of}
spec:
  replicas: 2
  selector: {matchLabels: {app: hello-graviton}}
  template:
    metadata: {labels: {app: hello-graviton}}
    spec:
      nodeSelector:
        kubernetes.io/arch: arm64
      tolerations:
        - {key: arch, operator: Equal, value: arm64, effect: NoSchedule}
      containers:
        - name: nginx
          image: public.ecr.aws/nginx/nginx:stable
          resources: {requests: {cpu: 100m, memory: 128Mi}}
```

Apply both and check where the pods run:

```bash
kubectl apply -f hello-x86.yaml -f hello-graviton.yaml
kubectl -n of get pod -o wide
kubectl get node -L kubernetes.io/arch,karpenter.sh/nodepool,karpenter.sh/capacity-type
```

`get pod -o wide` names each pod's node, and `get node` shows that node's architecture, NodePool and capacity type. Listing nodes needs cluster-wide read, which the deploy role lacks, so a developer asks the pod instead: `kubectl -n of exec deploy/hello-graviton -- uname -m` prints `aarch64`, and `x86_64` for `hello-x86`. A pod can also land on a system node group that has room, and those nodes show no NodePool; add `karpenter.sh/capacity-type: spot` to the `nodeSelector` to keep a pod on Karpenter's Spot nodes.

## Tear down

```bash
kubectl delete -f hello-x86.yaml -f hello-graviton.yaml
./tfctl.sh unroll    # destroy every stack, last to first
```

`unroll` will not destroy a stack while a later one still holds resources. After the cluster-only build, run its commands in reverse with `destroy` in place of `apply` and the component loop as `karpenter karpenter-aws namespaces`. The state bucket is destroyed last, together with the state files in it (`force_destroy = true` in its `terraform.tfvars`), unless `TF_VAR_create_state_bucket` is `false`, in which case it stays.
