# Branch Structure and GitHub Actions Guide

## ✅ Correct Branch Structure

```
main (production deployments)
├── develop (integration branch)
├── feature/your-feature-name
├── hotfix/urgent-fixes
└── release/version-number
```

## 🔧 Fix Your Current Setup

You currently have `dev`, `stage`, `prod` branches, but you need:

```bash
# Keep main branch
git checkout main

# Create develop branch (not dev)
git checkout -b develop
git push origin develop

# Delete environment-specific branches (these are folders, not branches)
git branch -d dev stage prod  # if they exist as branches
git push origin --delete dev stage prod  # if they exist remotely
```

**Important**: `dev`, `stage`, `prod` are **environment folders**, not branches!

## 🚀 How to Run GitHub Actions Workflows

### 1. Automatic Triggers

#### Deploy to Development
```bash
# Push to develop branch
git checkout develop
git add .
git commit -m "feat: add new feature"
git push origin develop
```
**Result**: Deploys to `dev` environment only

#### Deploy to All Environments
```bash
# Push to main branch
git checkout main
git merge develop  # or create PR and merge
git push origin main
```
**Result**: 
- Deploys to `dev` automatically
- Deploys to `stage` (requires approval)
- Deploys to `prod` (requires approval)

#### Pull Request Testing
```bash
# Create feature branch
git checkout -b feature/new-security-rules
git add .
git commit -m "feat: add new security rules"
git push origin feature/new-security-rules

# Create PR to main
gh pr create --title "Add new security rules" --base main
```
**Result**: Runs quality checks and shows plan preview

### 2. Manual Workflow Triggers

#### Main Pipeline (Manual)
1. Go to **Actions** tab in GitHub
2. Select **"Terraform CI/CD Pipeline"**
3. Click **"Run workflow"**
4. Choose:
   - **Environment**: `dev`, `stage`, or `prod`
   - **Action**: `plan`, `apply`, or `destroy`

#### Generate Reports
1. Go to **Actions** tab
2. Select **"Generate Infrastructure Report"**
3. Click **"Run workflow"**
4. Choose:
   - **Environment**: `dev`, `stage`, `prod`, or `all`
   - **Report Type**: `summary`, `detailed`, `security`, or `cost`

### 3. Environment-Specific Deployments

#### Development Environment
```bash
# Method 1: Push to develop
git checkout develop
git push origin develop

# Method 2: Manual workflow
# Actions → Terraform CI/CD Pipeline → Run workflow
# Environment: dev, Action: apply
```

#### Staging Environment
```bash
# Method 1: Push to main (requires approval)
git checkout main
git push origin main
# Then approve in GitHub UI

# Method 2: Manual workflow
# Actions → Terraform CI/CD Pipeline → Run workflow
# Environment: stage, Action: apply
```

#### Production Environment
```bash
# Method 1: Push to main (requires 2 approvals)
git checkout main
git push origin main
# Then get 2 approvals in GitHub UI

# Method 2: Manual workflow
# Actions → Terraform CI/CD Pipeline → Run workflow
# Environment: prod, Action: apply
```

## 📋 Workflow Execution Order

### Automatic Flow (Push to main)
```
1. Quality Checks (format, lint, security)
2. Plan (all environments)
3. Deploy Dev (automatic)
4. Deploy Stage (wait for approval)
5. Deploy Prod (wait for 2 approvals + 5min delay)
6. Generate Report (non-blocking)
```

### Manual Flow
```
1. Select workflow
2. Choose environment and action
3. Workflow runs for selected environment only
```

## 🛡️ Environment Approvals Setup

### Required GitHub Settings

#### 1. Create Environments
Go to **Settings → Environments**:

**Stage Environment:**
- Protection rules: ✅ Required reviewers (1)
- Deployment branches: `main` only

**Production Environment:**
- Protection rules: ✅ Required reviewers (2)
- Wait timer: 5 minutes
- Deployment branches: `main` only

#### 2. Add Reviewers
- Add team members as required reviewers
- Stage: 1 reviewer minimum
- Production: 2 reviewers minimum

## 🔍 Monitoring Workflow Runs

### Check Status
1. Go to **Actions** tab
2. See all workflow runs
3. Click on specific run for details
4. View logs for each job

### Download Reports
1. Go to completed workflow run
2. Scroll to **Artifacts** section
3. Download report files

### View Security Results
1. Go to **Security** tab
2. View **Code scanning alerts**
3. Review SARIF reports from Checkov/TFSec

## 🚨 Troubleshooting

### Common Issues

#### 1. Workflow Not Triggering
- Check branch names (`develop`, not `dev`)
- Verify file paths in trigger conditions
- Ensure AWS_ROLE_ARN secret is set

#### 2. Approval Not Working
- Verify environments are created in Settings
- Check reviewer permissions
- Ensure deployment branch rules

#### 3. Security Scans Failing
- Review Security tab for specific issues
- Check if IP restrictions are too broad
- Verify resource configurations

### Debug Commands
```bash
# Check current branch
git branch -a

# Verify remote branches
git ls-remote origin

# Check workflow files
ls -la .github/workflows/

# Test locally
terraform fmt -recursive
terraform validate
```

## 📝 Quick Reference

### Branch Commands
```bash
# Switch to main
git checkout main

# Create and switch to develop
git checkout -b develop

# Create feature branch
git checkout -b feature/my-feature

# Push changes
git add .
git commit -m "your message"
git push origin branch-name
```

### Workflow Triggers
- **develop** → dev environment
- **main** → dev → stage → prod (with approvals)
- **PR** → quality checks only
- **Manual** → selected environment
