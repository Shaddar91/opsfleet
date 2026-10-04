# Global Accelerator: traffic dials and regional failover

This stack creates the accelerator and its listener. Each region's `edge` stack adds its public ALB as an endpoint group with a traffic dial, `global_accelerator_traffic_dial_percentage` in `prod01-us-east-1/edge/terraform.tfvars` and `prod01-us-west-2/edge/terraform.tfvars`, 100 in both. With both at 100, each user goes to the nearest healthy region.

Two things change the dials:

- Terraform: every apply of an `edge` stack sets that region's dial back to its `terraform.tfvars` value.
- The failover function `innovate-inc-failover-regional` in us-west-2: `failover` and `switchover` set the old writer region's dial to 0 and the new writer region's dial to 100.

## While us-west-2 holds the database writer

Do not put us-east-1 back to 100. us-east-1 is then the read-only copy, and its API cannot use it: its database address is the RDS Proxy's read/write endpoint, which refuses connections on a copy.

- Do not apply `prod01-us-east-1/edge` or `prod01-us-west-2/edge`. Terraform would set both dials back to 100 and send users to us-east-1 again.
- Set `dbMigrate.writerRegions: [us-west-2]` in of-helm (`charts/of-api/values.yaml`), so the schema step runs where the writer is.

Check which region holds the writer and whether the copy is in sync:

```bash
aws rds describe-global-clusters --region us-west-2 --global-cluster-identifier prod01-us-aurora-aurora-global \
  --query 'GlobalClusters[0].GlobalClusterMembers[].[DBClusterArn,IsWriter,SynchronizationStatus]' --output text
```

## Fail over to us-west-2

By hand, when us-east-1 is down. Without `"dry_run": false` the call only prints the steps it would take.

```bash
F=innovate-inc-failover-regional
aws lambda invoke --region us-west-2 --function-name $F --payload '{"action":"status"}' /tmp/out.json && cat /tmp/out.json
aws lambda invoke --region us-west-2 --function-name $F --payload '{"action":"failover"}' /tmp/out.json && cat /tmp/out.json
aws lambda invoke --region us-west-2 --function-name $F --cli-read-timeout 900 \
  --payload '{"action":"failover","dry_run":false}' /tmp/out.json && cat /tmp/out.json
```

`failover` sets the us-east-1 dial to 0, promotes us-west-2 (the last second or so of writes can be lost), waits up to 10 minutes for us-west-2 to hold the writer, then sets the us-west-2 dial to 100. With both regions healthy, use `{"action":"switchover","dry_run":false}` instead; it loses no data.

Automatically: the alarm `innovate-inc-failover-regional-us-east-1-unhealthy` invokes the function when the accelerator sees no healthy us-east-1 endpoint for 3 minutes. With `on_alarm = "status"` in `prod01-us-west-2/failover/lambda-regional-failover/terraform.tfvars` it only reports; `on_alarm = "failover"` makes it fail over.

## Switch back to us-east-1

Once the us-east-1 member shows `connected`:

```bash
aws lambda invoke --region us-west-2 --function-name innovate-inc-failover-regional --cli-read-timeout 900 \
  --payload '{"action":"switchover","target_region":"us-east-1","dry_run":false}' /tmp/out.json && cat /tmp/out.json
```

It loses no data, sets the us-west-2 dial to 0 and the us-east-1 dial to 100. Then:

1. Set `dbMigrate.writerRegions` back to `[us-east-1]` in of-helm.
2. Apply `prod01-us-west-2/edge` to put the us-west-2 dial back to 100, so us-west-2 serves reads again.
3. Check that write forwarding on the us-west-2 cluster shows `enabled`; if not, destroy and apply `prod01-us-west-2/aurora/forwarding/write-forwarding` once.
