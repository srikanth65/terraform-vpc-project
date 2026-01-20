# Terraform VPC Multi-Environment Project

A production-ready Terraform project for deploying VPC infrastructure across multiple environments with comprehensive CI/CD pipeline, security scanning, and quality checks.

## 🏗️ Project Structure

```
terraform-vpc-project/
├── .github/workflows/
│   └── terraform-pipeline.yml    # Complete CI/CD pipeline
├── docs/
│   ├── INITIAL_SETUP.md          # Step-by-step setup guide
│   └── WORKFLOW_USAGE.md         # GitHub Actions usage
├── environments/
│   ├── dev/                      # Development environment
│   ├── stage/                    # Staging environment
│   └── prod/                     # Production environment
├── modules/vpc/
│   ├── main.tf                   # VPC, subnets, NAT, security groups
│   ├── variables.tf              # Input variables
│   └── outputs.tf                # VPC and security group IDs
├── setup/
│   ├── backend/                  # S3 + DynamoDB setup
│   ├── oidc/                     # GitHub OIDC integration
│   └── scripts/                  # Automated setup scripts
└── .tflint.hcl                   # TFLint configuration
```

## 🚀 Quick Start

### 1. GitHub Repository Setup
```bash
# Setup GitHub repository (automated)
./setup/scripts/setup-github-repo.sh your-username terraform-vpc-project

# Or follow manual setup guide
# See: docs/GITHUB_SETUP.md
```

### 2. Infrastructure Setup
```bash
# Run automated setup
./setup/scripts/setup-backend.sh
./setup/scripts/setup-oidc.sh your-username/terraform-vpc-project
./setup/scripts/migrate-state.sh
```

### 3. Configure GitHub
- Add `AWS_ROLE_ARN` secret to repository
- Create `stage` and `production` environments with approvals

### 4. Deploy
```bash
git add .
git commit -m "Initial setup"
git push origin main
```

📖 **Detailed Setup**: See [docs/INITIAL_SETUP.md](docs/INITIAL_SETUP.md)  
📖 **GitHub Setup**: See [docs/GITHUB_SETUP.md](docs/GITHUB_SETUP.md)

## ✨ Features

### Infrastructure
- **Multi-AZ VPC** with public/private subnets
- **NAT Gateways** for private subnet internet access
- **Layered Security Groups** (web → app → db)
- **VPC Flow Logs** for network monitoring
- **Environment-specific CIDR blocks**

### CI/CD Pipeline
- **Quality Checks**: Formatting, linting, validation
- **Security Scanning**: Checkov, TFSec, TFLint
- **Automated Planning**: Multi-environment support
- **Approval Workflows**: Stage and production gates
- **SARIF Integration**: Security results in GitHub

### Security & Compliance
- **OIDC Authentication**: No long-lived AWS credentials
- **Least Privilege IAM**: Scoped permissions
- **Encrypted State**: S3 + DynamoDB backend
- **Security Scanning**: Automated vulnerability detection
- **Audit Trail**: CloudTrail integration

## 🔄 Deployment Workflow

### Automatic Deployments
- **Push to `develop`** → Deploy to dev
- **Push to `main`** → Deploy dev → stage (approval) → prod (approval)
- **Pull Request** → Quality checks + plan preview

### Manual Deployments
- GitHub Actions workflow dispatch
- Environment selection (dev/stage/prod)
- Action selection (plan/apply/destroy)

📖 **Workflow Guide**: See [docs/WORKFLOW_USAGE.md](docs/WORKFLOW_USAGE.md)

## 🛡️ Quality Gates

### Code Quality
- ✅ Terraform formatting (`terraform fmt`)
- ✅ Configuration validation (`terraform validate`)
- ✅ Best practices linting (TFLint)
- ✅ AWS-specific rules

### Security Scanning
- ✅ Infrastructure security (Checkov)
- ✅ Terraform security (TFSec)
- ✅ SARIF report generation
- ✅ GitHub Security tab integration

### Deployment Safety
- ✅ Plan review in PRs
- ✅ Environment approvals
- ✅ State locking
- ✅ Rollback procedures

## 🌍 Environment Configuration

| Environment | CIDR Block | NAT Gateway | Flow Logs | Approval Required |
|-------------|------------|-------------|-----------|-------------------|
| **dev** | 10.0.0.0/16 | ❌ | ❌ | ❌ |
| **stage** | 10.1.0.0/16 | ✅ | ✅ | ✅ (1 reviewer) |
| **prod** | 10.2.0.0/16 | ✅ | ✅ | ✅ (2 reviewers) |

## 📊 Monitoring & Observability

- **VPC Flow Logs**: Network traffic analysis
- **CloudTrail**: API call auditing
- **GitHub Actions**: Deployment monitoring
- **Security Alerts**: Automated vulnerability detection

## 🔧 Local Development

```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan changes
cd environments/dev
terraform plan -var-file="terraform-dev.tfvars"

# Apply changes
terraform apply -var-file="terraform-dev.tfvars"
```

## 📚 Documentation

- [Initial Setup Guide](docs/INITIAL_SETUP.md) - Complete setup instructions
- [Workflow Usage](docs/WORKFLOW_USAGE.md) - GitHub Actions guide
- [Architecture Overview](modules/vpc/README.md) - Infrastructure details

## 🤝 Contributing

1. Create feature branch
2. Make changes with proper formatting
3. Create pull request
4. Review automated checks
5. Merge after approval

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
