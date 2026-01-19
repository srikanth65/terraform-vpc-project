# Setup Instructions

## 1. Create Remote State Backend

```bash
# Initialize and apply backend setup
terraform init
terraform apply setup-backend.tf
```

## 2. Setup GitHub OIDC Integration

```bash
# Update YOUR_GITHUB_USERNAME in github-oidc-setup.tf
# Then apply the OIDC setup
terraform apply github-oidc-setup.tf
```

## 3. Configure GitHub Repository

### Add Repository Secret:
- Go to GitHub repo → Settings → Secrets and variables → Actions
- Add secret: `AWS_ROLE_ARN` with the output from step 2

### Create GitHub Environments:
- Go to Settings → Environments
- Create `stage` environment with approval required
- Create `production` environment with approval required

## 4. Initialize Environments with Remote State

```bash
# For each environment, reinitialize with remote backend
cd environments/dev
terraform init -migrate-state

cd ../stage  
terraform init -migrate-state

cd ../prod
terraform init -migrate-state
```

## 5. Deploy

```bash
# Local deployment
cd environments/dev
terraform plan -var-file="terraform-dev.tfvars"
terraform apply -var-file="terraform-dev.tfvars"

# Or push to main branch for automated deployment
git add .
git commit -m "Add remote state and OIDC integration"
git push origin main
```

## Modern GitHub-AWS Integration Benefits

- **No long-lived credentials**: Uses temporary tokens via OIDC
- **Enhanced security**: Role-based access with conditions
- **Audit trail**: All actions logged in CloudTrail
- **Automatic rotation**: Tokens expire automatically
- **Least privilege**: Scoped permissions per repository
