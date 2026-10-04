# prod01-us-west-2 aurora: the standby copy and write forwarding

This stack creates the us-west-2 cluster of the Aurora global database: a read-only copy of the us-east-1 writer, its RDS Proxy, its database secret and its internal DNS names. With write forwarding on, the us-west-2 backends read from this copy and Aurora passes their writes to the writer in us-east-1.

## The switch

`write_forwarding = true` in `terraform.tfvars` drives four things:

| What | Where | With `true` | With `false` |
|---|---|---|---|
| Forwarding on the cluster | `forwarding/write-forwarding` (its own state) | turned on after this stack, off before it is destroyed | not turned on |
| The backends' database address (`host` in the database secret) | `locals.tf`, `secrets.tf` | the reader endpoint (`-ro` name) | the RDS Proxy (`-pool` name) |
| Database port 5432 from the pods' private subnets | `data.tf`, `locals.tf`, `main.tf` | allowed | only the proxy |
| The `write_forwarding` output | `outputs.tf` | read by `forwarding/` | read by `forwarding/` |

The reader endpoint is needed because the proxy's read/write endpoint refuses every connection while this cluster is the copy. The pods then connect to the database directly, so their subnets get the database port.

## Why forwarding has its own state

Terraform has no resource for write forwarding on its own; it is a setting on the cluster. So:

- this stack creates the cluster with forwarding off and ignores that setting from then on (`aurora-secondary-1.0.2`);
- `forwarding/write-forwarding` owns it through `modules/aurora/write-forwarding-1.0`: on when created, off when destroyed;
- the region rollout applies `aurora/forwarding` right after this stack and destroys it right before, so forwarding is always off before the cluster leaves the global database, and Terraform's state matches AWS at every step.

## Common tasks

Turn forwarding off without destroying anything: set `write_forwarding = false`, apply `forwarding/write-forwarding` (it removes its resource, which turns forwarding off), then apply this stack (the backends go back to the proxy). Restart the API pods afterwards, since they read the database address only when they start.

Check what AWS reports:

```bash
aws rds describe-db-clusters --region us-west-2 --db-cluster-identifier prod01-usw2-aurora-aurora-cluster \
  --query 'DBClusters[0].GlobalWriteForwardingStatus' --output text
```

After a failover and the switch back, check that forwarding shows `enabled` again; if not, destroy and apply `forwarding/write-forwarding` once. The failover commands are in `../failover/lambda-regional-failover/README.md`.
