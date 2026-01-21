aws_region         = "us-east-2"
environment        = "stage"
cidr_block         = "10.1.0.0/16"
public_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnets    = ["10.1.10.0/24", "10.1.20.0/24"]
enable_nat_gateway = true
enable_flow_logs   = true
