# aurora-secondary-1.0.2

A secondary cluster joined to an Aurora global database, with its instances, subnet group, cluster parameter group, security group and internal DNS names.

The only change from 1.0.1: the cluster ignores `enable_global_write_forwarding` after creation. That lets a separate stack own write forwarding through `write-forwarding-1.0`, turning it on after this module's stack and off before it, without this module undoing it on the next apply. Set `enable_global_write_forwarding = false` here when that stack is used.
