aws_region         = "us-east-2"
environment        = "prod"
cidr_block         = "10.2.0.0/16"
public_subnets     = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnets    = ["10.2.10.0/24", "10.2.20.0/24"]
enable_nat_gateway = true
enable_flow_logs   = true
