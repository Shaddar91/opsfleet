application    = "aurora"
engine_version = "18.6"

#single region, today
# create_global_cluster = false
# instance_class        = "db.t4g.medium"

#global database: comment the pair above, uncomment these, apply, then roll out prod01-us-west-2
create_global_cluster = true
instance_class        = "db.r6g.large"

serverlessv2_scaling    = null
database_name           = "ofdb"
master_username         = "ofadmin"
deletion_protection     = false
skip_final_snapshot     = true
backup_retention_period = 1
