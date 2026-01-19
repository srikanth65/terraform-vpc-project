# Terraform VPC Multi-Environment Project

## Structure
```
terraform-vpc-project/
├── .github/workflows/
│   ├── deploy.yml        # Automated deployment
│   └── security.yml      # Security scanning
├── modules/vpc/
│   ├── main.tf          # VPC, subnets, NAT, security groups
│   ├── variables.tf     # Input variables
│   └── outputs.tf       # VPC and security group IDs
└── environments/
    ├── dev/             # Development environment
    ├── stage/           # Staging environment
    └── prod/            # Production environment
```

## Features

### Infrastructure
- **VPC with public/private subnets** across multiple AZs
- **NAT Gateways** for private subnet internet access (configurable)
- **Security Groups** for web, app, and database tiers
- **VPC Flow Logs** for network monitoring (configurable)
- **Environment-specific CIDR blocks** to avoid conflicts

### Security
- Layered security groups (web → app → db)
- VPC Flow Logs for network monitoring
- Automated security scanning with Checkov and TFSec
- Least privilege access patterns

### Automation
- **GitHub Actions** for CI/CD pipeline
- **Environment promotion**: dev → stage → prod
- **Security scanning** on every PR
- **Manual deployment** option via workflow dispatch

## Usage

### Local Development
```bash
cd environments/dev
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### GitHub Actions Setup
1. Add AWS credentials to repository secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

2. Create GitHub environments:
   - `stage` (with approval required)
   - `production` (with approval required)

### Environment Configuration
Each environment uses `terraform.tfvars`:
- **Dev**: No NAT Gateway, no Flow Logs (cost optimization)
- **Stage/Prod**: Full features enabled

## Security Groups
- **Web SG**: Allows HTTP/HTTPS from internet
- **App SG**: Allows port 8080 from Web SG only
- **DB SG**: Allows port 3306 from App SG only
