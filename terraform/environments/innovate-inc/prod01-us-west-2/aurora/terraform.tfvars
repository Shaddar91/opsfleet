application          = "aurora"
primary_environment  = "prod01-us"
instance_class       = "db.serverless"
serverlessv2_scaling = { min_capacity = 0.5, max_capacity = 1 }
deletion_protection  = false
skip_final_snapshot  = true
