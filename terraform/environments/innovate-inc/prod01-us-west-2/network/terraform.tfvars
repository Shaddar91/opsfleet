application            = "network"
vpc_cidr               = "10.144.0.0/16"
cluster_name           = "prod01-usw2-eks"
one_nat_gateway_per_az = false
bastion_instance_type  = "t4g.small"
bastion_spot           = true
bastion_allowed_cidrs  = []
