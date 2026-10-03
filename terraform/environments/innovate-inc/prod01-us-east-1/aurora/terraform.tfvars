application                        = "aurora"
engine_version                     = "17.11"
instance_class                     = "db.serverless"
serverlessv2_scaling               = { min_capacity = 0.5, max_capacity = 1 }
database_name                      = "of"
master_username                    = "of"
master_user_secret_replica_regions = ["us-west-2"]
deletion_protection                = false
skip_final_snapshot                = true
backup_retention_period            = 1
