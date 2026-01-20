# GitHub Workflows Usage Guide

## Workflow Overview

The CI/CD pipeline includes:
- **Quality Checks**: Formatting, linting, security scans
- **Planning**: Terraform plan for each environment
- **Deployment**: Automated deployment with approvals

## Workflow Triggers

### 1. Automatic Triggers

#### Push to Main Branch
```bash
git push origin main
```
- Runs quality checks
- Plans all environments
- Deploys to dev automatically
- Deploys to stage (with approval)
- Deploys to prod (with approval)

#### Push to Develop Branch
```bash
git push origin develop
```
- Runs quality checks
- Plans all environments
- Deploys to dev only

#### Pull Request to Main
```bash
gh pr create --title "Feature: Add new security group"
```
- Runs quality checks
- Plans affected environments
- Posts plan summary as PR comment

### 2. Manual Triggers

#### Deploy Specific Environment
1. Go to Actions tab in GitHub
2. Select "Terraform CI/CD Pipeline"
3. Click "Run workflow"
4. Choose:
   - Environment: `dev`, `stage`, or `prod`
   - Action: `plan`, `apply`, or `destroy`

## Environment Deployment Flow

### Development Environment
- **Trigger**: Push to `main` or `develop`
- **Approval**: None required
- **Auto-deploy**: Yes

### Staging Environment
- **Trigger**: Push to `main` (after dev success)
- **Approval**: Required (1 reviewer)
- **Auto-deploy**: After approval

### Production Environment
- **Trigger**: Push to `main` (after stage success)
- **Approval**: Required (2 reviewers)
- **Wait Time**: 5 minutes
- **Auto-deploy**: After approval and wait

## Quality Gates

### 1. Code Quality Checks
- **Terraform Format**: `terraform fmt -check`
- **Terraform Validate**: Syntax and configuration validation
- **TFLint**: Best practices and AWS-specific rules

### 2. Security Scans
- **Checkov**: Infrastructure security scanning
- **TFSec**: Terraform security analysis
- **SARIF Upload**: Results visible in Security tab

### 3. Plan Analysis
- **Resource Changes**: Add/Change/Destroy summary
- **Cost Impact**: Estimated resource costs
- **PR Comments**: Automated plan summaries

## Using the Workflow

### Standard Development Flow

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/new-security-group
   ```

2. **Make Changes**
   ```bash
   # Edit Terraform files
   terraform fmt -recursive
   ```

3. **Create Pull Request**
   ```bash
   git add .
   git commit -m "Add new security group for API"
   git push origin feature/new-security-group
   gh pr create --title "Add API security group"
   ```

4. **Review Plan in PR**
   - Check automated plan comment
   - Review security scan results
   - Address any quality issues

5. **Merge to Main**
   ```bash
   gh pr merge --squash
   ```

6. **Monitor Deployments**
   - Dev deploys automatically
   - Approve stage deployment
   - Approve production deployment

### Emergency Deployment

For urgent fixes:

1. **Direct Push to Main**
   ```bash
   git checkout main
   git pull origin main
   # Make urgent fix
   git add .
   git commit -m "URGENT: Fix security group rule"
   git push origin main
   ```

2. **Manual Workflow Trigger**
   - Use GitHub Actions UI
   - Select specific environment
   - Choose `apply` action

### Rollback Procedure

1. **Revert Commit**
   ```bash
   git revert <commit-hash>
   git push origin main
   ```

2. **Manual Destroy (if needed)**
   - Use workflow dispatch
   - Select environment
   - Choose `destroy` action

## Monitoring and Alerts

### GitHub Actions
- **Workflow Status**: Green/Red indicators
- **Email Notifications**: On failure
- **Slack Integration**: Configure webhooks

### Security Alerts
- **Security Tab**: View scan results
- **SARIF Reports**: Detailed findings
- **Dependency Alerts**: Automated updates

### AWS Monitoring
- **CloudTrail**: API call logs
- **VPC Flow Logs**: Network traffic
- **Cost Explorer**: Resource costs

## Best Practices

### Code Quality
- Always run `terraform fmt` before committing
- Use meaningful commit messages
- Keep changes small and focused
- Add comments for complex configurations

### Security
- Review security scan results
- Address high-severity findings
- Use least-privilege IAM policies
- Enable encryption for all resources

### Deployment
- Test in dev environment first
- Use feature flags for large changes
- Monitor deployments closely
- Have rollback plan ready

## Troubleshooting

### Common Workflow Issues

1. **Quality Checks Fail**
   ```bash
   terraform fmt -recursive
   terraform validate
   tflint --recursive
   ```

2. **Security Scans Fail**
   - Review Security tab findings
   - Fix high/critical issues
   - Add exceptions for false positives

3. **Plan Fails**
   - Check AWS permissions
   - Verify variable values
   - Review state file conflicts

4. **Apply Fails**
   - Check resource limits
   - Verify IAM permissions
   - Review dependency conflicts

### Getting Help

- **GitHub Issues**: Report bugs or feature requests
- **Actions Logs**: Detailed error messages
- **AWS Support**: For AWS-specific issues
- **Terraform Docs**: Configuration reference
