# write-forwarding-1.0

Global write forwarding on an Aurora secondary cluster, as a resource of its own. The AWS provider only has forwarding as an argument of `aws_rds_cluster`, so a stack cannot add it after the cluster and remove it before the cluster. This module fills that gap with one `terraform_data` resource:

- on create it runs `files/write-forwarding.sh on`: turns forwarding on and waits until AWS reports `enabled`;
- on destroy it runs `files/write-forwarding.sh off`: turns forwarding off and waits until AWS reports `disabled`. A cluster that no longer exists counts as off.

Put it in its own stack that runs after the cluster's stack and is destroyed before it, and have the cluster's module ignore `enable_global_write_forwarding` (as `aurora-secondary-1.0.2` does), so the two never fight over the setting.

## Inputs

| Name | Description |
|---|---|
| `region` | Region of the secondary cluster |
| `cluster_identifier` | Identifier of the secondary cluster |

## Requirements

The machine running Terraform needs the AWS CLI and credentials that may call `rds:DescribeDBClusters` and `rds:ModifyDBCluster` on the cluster. A failed or timed-out step (10 minutes) fails the apply or destroy, so it is visible.

## Example

```hcl
module "write_forwarding" {
  source = "../../../../../../modules/aurora/write-forwarding-1.0"
  count  = local.write_forwarding ? 1 : 0

  region             = var.region
  cluster_identifier = local.cluster_identifier
}
```
