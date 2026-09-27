# cluster-05

EKS cluster with AL2023 managed node groups (x86_64 and Graviton, on-demand or spot), EKS access entries, the EKS-managed core add-ons, the IRSA OIDC provider and a node security group. IAM roles come in as ARNs; the module creates none.

## Usage

```hcl
module "eks" {
  source = "../../../../modules/kubernetes/cluster-05"

  environment        = var.environment
  application        = var.application
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = local.vpc_id
  cluster_subnet_ids = local.private_subnets

  cluster_role_arn    = module.cluster_role.role_arn
  node_role_arn       = module.node_role.role_arn
  authentication_mode = "API_AND_CONFIG_MAP"

  access_entries = merge(
    { for arn in var.admin_principal_arns : arn => {
      principal_arn = arn
      policy_associations = {
        admin = { policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy" }
      }
    } },
    { karpenter = { principal_arn = module.karpenter_node_role.role_arn, type = "EC2_LINUX" } },
  )

  node_groups = [
    {
      name           = "system"
      subnets        = local.private_subnets
      instance_types = ["m7i.large"]
      scaling        = { desired = 2, min = 2, max = 3 }
      labels         = { role = "system" }
    },
    {
      name           = "arm"
      subnets        = local.private_subnets
      ami_type       = "AL2023_ARM_64_STANDARD"
      capacity_type  = "SPOT"
      instance_types = ["m7g.large", "c7g.large"]
      scaling        = { desired = 0, min = 0, max = 5 }
      taints         = [{ key = "arch", value = "arm64", effect = "NO_SCHEDULE" }]
    },
  ]
}
```

## Node groups

| Field | Default | Notes |
|---|---|---|
| `name`, `subnets`, `instance_types`, `scaling` | required | names unique; `min <= desired <= max` |
| `capacity_type` | `ON_DEMAND` | `ON_DEMAND` or `SPOT` |
| `ami_type` | `AL2023_x86_64_STANDARD` | `AL2023_x86_64_STANDARD`, `AL2023_ARM_64_STANDARD`, `AL2023_x86_64_NVIDIA`, `AL2023_ARM_64_NVIDIA`, `AL2023_x86_64_NEURON` |
| `node_version`, `release_version` | `null` (cluster version, latest AMI release) | |
| `image_id` | `null` | custom AMI; excludes `ami_type`, `node_version`, `release_version` |
| `labels` | `{}` | |
| `taints` | `[]` | `{ key, value, effect }`; effect `NO_SCHEDULE`, `NO_EXECUTE` or `PREFER_NO_SCHEDULE` |
| `update_config` | `null` | exactly one of `max_unavailable`, `max_unavailable_percentage` |
| `ebs` | module `ebs` + `device_name` | `{ size, iops, throughput, type, device_name }` |
| `extra_security_group_ids` | module `extra_security_group_ids` | |
| `tags` | `{}` | node group resource tags |

Every instance type must run the group's architecture, taken from `ami_type` or, for `image_id`, from the AMI. A plan-time precondition names the group and the types that cannot run it.

## User data

`files/user_data.tpl` is the default template: MIME multipart, no `/etc/eks/bootstrap.sh`, arch-neutral.

- EKS-AMI groups: a shell part that sets the hostname `<environment>-<application>-<capacity>-<group>`. EKS merges its own nodeadm NodeConfig.
- `image_id` groups: EKS merges nothing, so a NodeConfig part adds the full cluster block, plus `--node-labels` and `--register-with-taints` so labels and taints exist when the node registers.

`user_data` replaces the template. The module merges these keys over `user_data_vars`: `NODE_GROUP_NAME`, `CAPACITY_TYPE`, `ENVIRONMENT`, `APPLICATION`, `ARCH` (`x86_64` or `arm64`), `AMI_TYPE` (`CUSTOM` for `image_id`), `CUSTOM_AMI` (bool), `CLUSTER_NAME`, `API_SERVER_ENDPOINT`, `CERTIFICATE_AUTHORITY`, `SERVICE_CIDR`, `KUBELET_FLAGS` (list).

## Access

- `authentication_mode`: `API` (default) or `API_AND_CONFIG_MAP`. Access entries cannot be switched off once enabled.
- `bootstrap_cluster_creator_admin_permissions = false`: the principal that runs Terraform must be in `access_entries`, or later tiers get 401/403. The flag is create-time; a change replaces the cluster.
- Entry types: `STANDARD` (groups, user name, policy associations with `cluster` or `namespace` scope) and `EC2_LINUX` (none of those). One principal per entry.
- EKS maps the managed node group role itself. An entry for `node_role_arn` fails the plan, so self-managed nodes (Karpenter) need their own role.

## Add-ons

`addons` is keyed by add-on name. Default: `vpc-cni`, `kube-proxy` and `eks-pod-identity-agent` before the node groups (`before_compute = true`), `coredns` after them. A null `version` resolves the EKS default for `cluster_version` (`most_recent = true` takes the newest). Pin from the `addon_versions` output after the first apply. `pod_identity = { role_arn, service_account }` wires an add-on to Pod Identity.

## Inputs

| Name | Type | Default |
|---|---|---|
| `environment`, `application` | `string` | required |
| `cluster_name` | `string` | `null` (`<environment>-<application>-eks`) |
| `cluster_version` | `string` | `"1.36"` |
| `cluster_role_arn`, `node_role_arn` | `string` | required, IAM role ARNs |
| `authentication_mode` | `string` | `"API"` |
| `bootstrap_cluster_creator_admin_permissions` | `bool` | `false` |
| `bootstrap_self_managed_addons` | `bool` | `true` (create-time) |
| `access_entries` | `map(object)` | `{}` |
| `addons` | `map(object)` | the four core add-ons |
| `upgrade_policy_support_type` | `string` | `null` (`STANDARD` or `EXTENDED`) |
| `vpc_id`, `cluster_subnet_ids` | `string`, `list(string)` | required |
| `endpoint_private_access`, `endpoint_public_access` | `bool` | `true`, `false` |
| `public_access_cidrs` | `list(string)` | `["0.0.0.0/0"]` |
| `karpenter_discovery_tag` | `bool` | `true`: cluster SG tag `karpenter.sh/discovery = <cluster name>` |
| `cluster_security_group_tags` | `map(string)` | `{}` |
| `node_groups` | `list(object)` | required |
| `node_group_timeouts` | `object` | create `30m`, update `2h`, delete `30m` |
| `rules_cidr` | `list(object)` | all ports and 22 from `0.0.0.0/0`; override it |
| `rules_sg` | `list(object)` | `[]` |
| `extra_security_group_ids` | `list(string)` | `[]` |
| `ebs`, `device_name` | `object`, `string` | 50 GiB gp3, `/dev/xvda` |
| `update_default_version` | `bool` | `true` |
| `capacity_reservation_preference` | `string` | `"none"` |
| `http_endpoint`, `http_tokens`, `http_put_response_hop_limit`, `http_protocol_ipv6`, `instance_metadata_tags` | | IMDSv2 required, hop limit 2 |
| `user_data`, `user_data_vars` | `string`, `map(any)` | `null` (module template), `{}` |

## Outputs

| Name | Value |
|---|---|
| `cluster` | whole cluster resource |
| `cluster_name`, `eks_cluster_name`, `cluster_arn`, `cluster_version` | cluster identity |
| `public_endpoint`, `certificate_authority` (sensitive) | API endpoint and CA data |
| `cluster_security_group_id` | EKS-created cluster SG |
| `sg_id`, `sg` | node SG id, node SG module |
| `eks_role_arn`, `eks_node_role_arn`, `node_role_name` | the input role ARNs, node role name |
| `tg_names`, `asg_names` | per group: launch template Name tag, node group ASG name |
| `addon_versions` | installed version per add-on |
| `cluster_oidc`, `oidc_k8_provider_arn`, `oidc_k8_provider_id`, `oidc_k8_provider_url` | OIDC issuer and IRSA provider |

## Requirements

Terraform >= 1.5, hashicorp/aws >= 5.81.0. No other provider.
