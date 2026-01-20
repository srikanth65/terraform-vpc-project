# GitHub Actions Infrastructure Deployment Guide

## 🎯 Current Setup Status
✅ Repository created: `terraform-vpc-project`  
✅ Environments: `dev`, `stage`, `prod` folders  
✅ Branch created: `develop`  
✅ OIDC setup completed  
✅ Slack integration configured  

## 🚀 Deploy Infrastructure Steps

### Step 1: Verify GitHub Secrets
Go to **Settings** → **Secrets and variables** → **Actions**

Required secrets:
```
AWS_ROLE_ARN=arn:aws:iam::ACCOUNT_ID:role/github-actions-terraform-role
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
```

### Step 2: Create GitHub Environments
Go to **Settings** → **Environments**

**Create `stage` environment:**
- Protection rules: ✅ Required reviewers (1)
- Deployment branches: `main` only

**Create `production` environment:**
- Protection rules: ✅ Required reviewers (2)  
- Wait timer: 5 minutes
- Deployment branches: `main` only

### Step 3: Deploy to Development (Automatic)

```bash
# Make sure you're on develop branch
git checkout develop

# Add all files and commit
git add .
git commit -m "feat: initial infrastructure setup"

# Push to trigger dev deployment
git push origin develop
```

**Result**: Automatically deploys to `dev` environment

### Step 4: Deploy to All Environments

```bash
# Switch to main branch
git checkout main

# Merge develop into main
git merge develop

# Push to trigger full pipeline
git push origin main
```

**Result**: 
- Deploys to `dev` automatically
- Waits for approval for `stage`
- Waits for approval for `prod`

### Step 5: Approve Deployments

1. **Go to Actions tab** in GitHub
2. **Click on the running workflow**
3. **Review deployment** for stage environment
4. **Click "Review deployments"**
5. **Select environment** and **Approve**
6. **Repeat for production** (needs 2 approvals)

## 🔧 Manual Deployment (Alternative)

### Option 1: Workflow Dispatch
1. **Actions** → **Terraform CI/CD Pipeline**
2. **Run workflow** → **Choose branch: `main`**
3. **Select**:
   - Environment: `dev` / `stage` / `prod`
   - Action: `apply`

### Option 2: Environment-Specific Deployment
```bash
# Deploy only to dev
git checkout develop
git push origin develop

# Deploy to specific environment manually
# Use GitHub Actions UI with workflow dispatch
```

## 📊 Monitor Deployment

### Check Workflow Status
1. **Actions tab** → **Latest workflow run**
2. **View logs** for each job
3. **Check artifacts** for reports

### Verify Infrastructure
```bash
# Check AWS Console
# VPC → Your VPCs → Look for dev-vpc, stage-vpc, prod-vpc

# Or use AWS CLI
aws ec2 describe-vpcs --filters "Name=tag:Environment,Values=dev" --region us-east-2
```

### Slack Notifications
- ✅ Success notifications in your Slack channel
- ❌ Failure alerts with error details
- 📊 Deployment summaries

## 🚨 Troubleshooting

### Common Issues

**1. Workflow Not Triggering**
```bash
# Check branch name
git branch -a

# Ensure files are in correct paths
ls -la .github/workflows/
```

**2. AWS Permission Errors**
- Verify `AWS_ROLE_ARN` secret is correct
- Check OIDC role trust relationship
- Ensure role has necessary permissions

**3. Terraform Backend Errors**
```bash
# Run backend setup if not done
./setup/scripts/setup-backend.sh

# Check if S3 bucket exists
aws s3 ls | grep terraform-state
```

**4. Approval Not Working**
- Verify environments are created in Settings
- Check reviewer permissions
- Ensure branch protection rules

## 📋 Deployment Checklist

### Before First Deployment
- [ ] AWS_ROLE_ARN secret added
- [ ] SLACK_WEBHOOK_URL secret added  
- [ ] GitHub environments created (stage, production)
- [ ] Reviewers added to environments
- [ ] Backend S3 bucket created

### For Each Deployment
- [ ] Code committed to correct branch
- [ ] Workflow triggered successfully
- [ ] Quality checks passed
- [ ] Security scans completed
- [ ] Terraform plan reviewed
- [ ] Approvals obtained (stage/prod)

## 🎯 Expected Timeline

### Development Deployment
- **Trigger**: Push to `develop`
- **Duration**: ~5-10 minutes
- **Approval**: None required

### Full Pipeline (main branch)
- **Quality Checks**: 2-3 minutes
- **Planning**: 2-3 minutes  
- **Dev Deployment**: 3-5 minutes
- **Stage Approval**: Manual (your timing)
- **Stage Deployment**: 3-5 minutes
- **Prod Approval**: Manual (your timing)
- **Prod Deployment**: 3-5 minutes

**Total**: 15-25 minutes + approval time

## 🔍 Verification Commands

### Check Deployment Status
```bash
# GitHub CLI
gh run list --workflow=terraform-pipeline.yml

# View specific run
gh run view RUN_ID

# Check deployment logs
gh run view RUN_ID --log
```

### Verify AWS Resources
```bash
# List VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0],Tags[?Key==`Environment`].Value|[0]]' --output table --region us-east-2

# List subnets
aws ec2 describe-subnets --query 'Subnets[*].[SubnetId,Tags[?Key==`Name`].Value|[0],AvailabilityZone]' --output table --region us-east-2

# List security groups
aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId,GroupName,Tags[?Key==`Environment`].Value|[0]]' --output table --region us-east-2
```

## 🎉 Success Indicators

### Workflow Success
- ✅ All jobs show green checkmarks
- ✅ Slack notifications received
- ✅ No error messages in logs

### Infrastructure Created
- ✅ VPCs created in AWS Console
- ✅ Subnets in multiple AZs
- ✅ Security groups with proper rules
- ✅ Internet Gateway attached
- ✅ Route tables configured

### Security Compliance
- ✅ Security scans passed
- ✅ No high-severity vulnerabilities
- ✅ Proper resource tagging
- ✅ Encrypted state storage

Ready to deploy! Start with pushing to `develop` branch for your first deployment. 🚀
