# Regional failover function: example commands

The function `innovate-inc-failover-regional` lives in us-west-2, so every call goes to us-west-2, whichever way you switch. The commands are written for AWS CLI v1; with v2, add `--cli-binary-format raw-in-base64-out`.

## Switch the database writer from one region to the other

Both regions healthy, writer moves to us-west-2, no data lost:

```bash
aws lambda invoke --region us-west-2 --function-name innovate-inc-failover-regional --cli-read-timeout 900 \
  --payload '{"action":"switchover","target_region":"us-west-2","dry_run":false}' /tmp/out.json && cat /tmp/out.json
```

Both regions healthy, writer moves back to us-east-1, no data lost:

```bash
aws lambda invoke --region us-west-2 --function-name innovate-inc-failover-regional --cli-read-timeout 900 \
  --payload '{"action":"switchover","target_region":"us-east-1","dry_run":false}' /tmp/out.json && cat /tmp/out.json
```

us-east-1 is down, writer moves to us-west-2, the last second or so of writes can be lost:

```bash
aws lambda invoke --region us-west-2 --function-name innovate-inc-failover-regional --cli-read-timeout 900 \
  --payload '{"action":"failover","target_region":"us-west-2","dry_run":false}' /tmp/out.json && cat /tmp/out.json
```

Each one sets the old writer region's traffic dial to 0 and the new one's to 100. To see the steps without running them, send the same payload without `"dry_run":false`.

## Payload values

| Field | Values | Default |
|---|---|---|
| `action` | `ping`, `status`, `fence`, `switchover`, `failover` | `status` |
| `target_region` | the region that should hold the writer: `us-east-1` or `us-west-2` | `us-west-2` |
| `dry_run` | `true` prints the steps, `false` runs them | `true` |
| `wait_seconds` | how long to wait for the writer to move | `600` |
| `reason` | free text, written to the logs | `manual` |

`switchover` is refused while the target copy is still resyncing; `status` shows when it is `connected`. After a failover, us-east-1 rebuilds itself as the copy, which takes from minutes to hours.

## Look

```bash
aws lambda invoke --region us-west-2 --function-name innovate-inc-failover-regional \
  --payload '{"action":"status"}' /tmp/out.json && cat /tmp/out.json
```

Shows which region holds the writer, whether each copy is `connected`, and both dials.

## Fence only

Sets the writer region's dial to 0 without touching the database:

```bash
aws lambda invoke --region us-west-2 --function-name innovate-inc-failover-regional \
  --payload '{"action":"fence","dry_run":false}' /tmp/out.json && cat /tmp/out.json
```

## Alarm drill

The alarm invokes the function when the accelerator sees no healthy us-east-1 endpoint for 3 minutes. While `on_alarm = "status"` in `terraform.tfvars`, it only reports:

```bash
aws cloudwatch set-alarm-state --region us-west-2 --alarm-name innovate-inc-failover-regional-us-east-1-unhealthy \
  --state-value ALARM --state-reason drill
aws logs filter-log-events --region us-west-2 --log-group-name /aws/lambda/innovate-inc-failover-regional \
  --start-time $(( ($(date +%s) - 600) * 1000 )) --query 'events[].message' --output text
```

What to do after a switch, and why the edge stacks must not be applied while us-west-2 holds the writer, is in [the accelerator README](../../../global/global-accelerator/README.md).
