# GitHub Repository Setup Guide

## 1. Create GitHub Repository

### Option A: GitHub CLI (Recommended)
```bash
# Create repository
gh repo create terraform-vpc-project --public --description "Production-ready Terraform VPC with CI/CD pipeline"

# Clone and setup
git clone https://github.com/YOUR_USERNAME/terraform-vpc-project.git
cd terraform-vpc-project

# Add project files
git add .
git commit -m "Initial project setup"
git push origin main
```

### Option B: GitHub Web Interface
1. Go to https://github.com/new
2. Repository name: `terraform-vpc-project`
3. Description: `Production-ready Terraform VPC with CI/CD pipeline`
4. Choose Public/Private based on needs
5. Initialize with README: ❌ (we have our own)
6. Click "Create repository"

## 2. Repository Settings Configuration

### Branch Protection Rules
```bash
# Navigate to Settings → Branches → Add rule
```

**Main Branch Protection:**
- Branch name pattern: `main`
- ✅ Require a pull request before merging
- ✅ Require approvals: 1
- ✅ Dismiss stale PR approvals when new commits are pushed
- ✅ Require review from code owners
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- Required status checks:
  - `Quality & Security Checks`
  - `Terraform Plan (dev)`
  - `Terraform Plan (stage)`
  - `Terraform Plan (prod)`
- ✅ Require conversation resolution before merging
- ✅ Restrict pushes that create files larger than 100MB

**Develop Branch Protection:**
- Branch name pattern: `develop`
- ✅ Require a pull request before merging
- ✅ Require status checks to pass before merging
- Required status checks:
  - `Quality & Security Checks`
  - `Terraform Plan (dev)`

### Repository Secrets
Navigate to Settings → Secrets and variables → Actions

**Required Secrets:**
```
AWS_ROLE_ARN = arn:aws:iam::ACCOUNT_ID:role/github-actions-terraform-role
```

**Optional Secrets (for notifications):**
```
SLACK_WEBHOOK_URL = https://hooks.slack.com/services/...
TEAMS_WEBHOOK_URL = https://outlook.office.com/webhook/...
```

### Environment Configuration

#### Development Environment
- Name: `dev`
- Protection rules: None
- Deployment branches: Any branch

#### Staging Environment
- Name: `stage`
- Protection rules:
  - ✅ Required reviewers: 1
  - Reviewers: Add team leads or senior developers
  - ✅ Wait timer: 0 minutes
- Deployment branches: Selected branches
  - Add rule: `main`

#### Production Environment
- Name: `production`
- Protection rules:
  - ✅ Required reviewers: 2
  - Reviewers: Add senior developers and DevOps team
  - ✅ Wait timer: 5 minutes
- Deployment branches: Selected branches
  - Add rule: `main`

### Security Settings

#### Code Security and Analysis
Navigate to Settings → Code security and analysis

**Enable:**
- ✅ Dependency graph
- ✅ Dependabot alerts
- ✅ Dependabot security updates
- ✅ Code scanning (CodeQL)
- ✅ Secret scanning
- ✅ Push protection for secret scanning

#### Advanced Security (GitHub Enterprise)
- ✅ Secret scanning for partner patterns
- ✅ Dependency review
- ✅ Code scanning with third-party tools

## 3. Team and Access Management

### Create Teams
```bash
# Using GitHub CLI
gh api orgs/YOUR_ORG/teams -f name="terraform-admins" -f description="Terraform administrators"
gh api orgs/YOUR_ORG/teams -f name="infrastructure-reviewers" -f description="Infrastructure code reviewers"
```

### Team Permissions
- **terraform-admins**: Admin access
- **infrastructure-reviewers**: Write access
- **developers**: Read access

### CODEOWNERS File
```bash
# Create .github/CODEOWNERS
```

## 4. Repository Labels

### Create Custom Labels
```bash
# Using GitHub CLI
gh label create "terraform" --description "Terraform related changes" --color "7B68EE"
gh label create "infrastructure" --description "Infrastructure changes" --color "FF6347"
gh label create "security" --description "Security related changes" --color "FF4500"
gh label create "breaking-change" --description "Breaking changes" --color "DC143C"
gh label create "cost-impact" --description "Changes affecting AWS costs" --color "FFD700"
gh label create "urgent" --description "Urgent deployment needed" --color "FF0000"
```

## 5. Issue and PR Templates

### Issue Templates
Create `.github/ISSUE_TEMPLATE/`

### Pull Request Template
Create `.github/pull_request_template.md`

## 6. Repository Files Setup

### Required Files Checklist
- ✅ README.md (comprehensive project overview)
- ✅ .gitignore (Terraform and IDE files)
- ✅ LICENSE (choose appropriate license)
- ✅ SECURITY.md (security policy)
- ✅ CONTRIBUTING.md (contribution guidelines)
- ✅ .github/CODEOWNERS (code ownership)
- ✅ .github/workflows/ (CI/CD pipelines)
- ✅ docs/ (documentation)

## 7. Notification Setup

### Slack Integration
```yaml
# Add to workflow for notifications
- name: Slack Notification
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: failure
    webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### Email Notifications
- Settings → Notifications
- Configure for workflow runs, security alerts, and dependabot

## 8. Best Practices Implementation

### Branch Strategy
```
main (production)
├── develop (integration)
├── feature/vpc-updates
├── hotfix/security-patch
└── release/v1.2.0
```

### Commit Message Convention
```
type(scope): description

feat(vpc): add new security group for API gateway
fix(networking): resolve NAT gateway routing issue
docs(readme): update setup instructions
chore(deps): update terraform provider versions
```

### Tagging Strategy
```bash
# Semantic versioning
git tag -a v1.0.0 -m "Initial production release"
git tag -a v1.1.0 -m "Add monitoring features"
git tag -a v1.1.1 -m "Security patch"
```

### Code Review Guidelines
- Minimum 1 approval for non-main branches
- Minimum 2 approvals for production changes
- Required security scan pass
- All conversations resolved
- Up-to-date with target branch

## 9. Monitoring and Alerts

### GitHub Actions Monitoring
- Enable email notifications for failed workflows
- Set up Slack/Teams integration for real-time alerts
- Monitor workflow run times and success rates

### Security Monitoring
- Review Security tab regularly
- Set up alerts for new vulnerabilities
- Monitor Dependabot PRs and merge promptly

### Cost Monitoring
- Tag all resources with environment and project labels
- Set up AWS Cost Explorer alerts
- Review monthly cost reports

## 10. Compliance and Governance

### Documentation Requirements
- All infrastructure changes must be documented
- Security changes require additional review
- Breaking changes need migration guides

### Audit Trail
- All changes tracked in Git history
- Deployment logs in GitHub Actions
- AWS CloudTrail for resource changes

### Backup and Recovery
- State files backed up in S3 with versioning
- Regular testing of disaster recovery procedures
- Documented rollback procedures

## Quick Setup Script

```bash
#!/bin/bash
# Quick repository setup script

REPO_NAME="terraform-vpc-project"
GITHUB_USERNAME="your-username"

# Create repository
gh repo create $REPO_NAME --public --description "Production-ready Terraform VPC with CI/CD pipeline"

# Clone and setup
git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
cd $REPO_NAME

# Copy project files (assuming they're in current directory)
cp -r ../terraform-vpc-project/* .

# Initial commit
git add .
git commit -m "Initial project setup with Terraform VPC and CI/CD pipeline"
git push origin main

# Create develop branch
git checkout -b develop
git push origin develop

# Create labels
gh label create "terraform" --description "Terraform related changes" --color "7B68EE"
gh label create "infrastructure" --description "Infrastructure changes" --color "FF6347"
gh label create "security" --description "Security related changes" --color "FF4500"

echo "✅ Repository setup complete!"
echo "📝 Next steps:"
echo "1. Configure branch protection rules"
echo "2. Set up environments (stage, production)"
echo "3. Add AWS_ROLE_ARN secret"
echo "4. Run initial setup scripts"
```
