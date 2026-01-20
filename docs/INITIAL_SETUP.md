# Initial Setup Guide

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.6.0 installed
- GitHub repository created
- Git configured locally

## Step-by-Step Setup

### 1. Clone and Setup Repository

```bash
git clone <your-repo-url>
cd terraform-vpc-project
```

### 2. Create Remote State Backend

```bash
./setup/scripts/setup-backend.sh
```

This creates:
- S3 bucket for Terraform state storage
- DynamoDB table for state locking
- Proper encryption and versioning

### 3. Setup GitHub OIDC Integration

```bash
./setup/scripts/setup-oidc.sh your-username/terraform-vpc-project
```

This creates:
- IAM OIDC identity provider for GitHub
- IAM role with necessary permissions
- Outputs the role ARN for GitHub secrets

### 4. Configure GitHub Repository

#### Add Repository Secret:
1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Add new repository secret:
   - Name: `AWS_ROLE_ARN`
   - Value: (output from step 3)

#### Create GitHub Environments:
1. Go to Settings → Environments
2. Create `stage` environment:
   - Add protection rule: Required reviewers (1)
   - Add deployment branch rule: `main` only
3. Create `production` environment:
   - Add protection rule: Required reviewers (2)
   - Add deployment branch rule: `main` only
   - Add wait timer: 5 minutes

### 5. Migrate State to Remote Backend

```bash
./setup/scripts/migrate-state.sh
```

This migrates existing local state files to the remote S3 backend.

### 6. Initial Deployment

```bash
# Format and validate code
terraform fmt -recursive
cd environments/dev
terraform plan -var-file="terraform-dev.tfvars"
terraform apply -var-file="terraform-dev.tfvars"
```

### 7. Enable Automated Deployments

```bash
git add .
git commit -m "Initial setup with remote state and OIDC"
git push origin main
```

## Verification

After setup, verify:

1. **S3 Bucket**: Check AWS console for `terraform-state-vpc-project` bucket
2. **DynamoDB Table**: Check for `terraform-locks` table
3. **IAM Role**: Verify `github-actions-terraform-role` exists
4. **GitHub Actions**: Check repository Actions tab for workflow runs
5. **Security Scans**: Review Security tab for scan results

## Troubleshooting

### Common Issues:

1. **AWS Permissions**: Ensure your AWS user has IAM, S3, DynamoDB, and EC2 permissions
2. **GitHub Secrets**: Verify `AWS_ROLE_ARN` secret is correctly set
3. **State Migration**: If migration fails, check backend configuration in environment files
4. **Workflow Failures**: Check Actions logs for specific error messages

### Support Commands:

```bash
# Check AWS configuration
aws sts get-caller-identity

# Validate Terraform configuration
terraform validate

# Check state backend
terraform state list

# Format all Terraform files
terraform fmt -recursive
```
