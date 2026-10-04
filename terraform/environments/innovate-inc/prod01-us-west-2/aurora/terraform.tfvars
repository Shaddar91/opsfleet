application         = "aurora"
primary_environment = "prod01-us"

#standby of the global database: db.r6g.large is the smallest class a global database takes, db.t* is refused; on/off is the aurora line in ../stacks
instance_class       = "db.r6g.large"
serverlessv2_scaling = null

deletion_protection = false
skip_final_snapshot = true

#reads stay in this region, Aurora forwards writes to the writer; the backends use the reader endpoint while this is on
write_forwarding = true
