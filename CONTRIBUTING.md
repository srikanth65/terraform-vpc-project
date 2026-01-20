# Contributing to Terraform VPC Project

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Follow security best practices

## Getting Started

1. **Fork the repository**
2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/terraform-vpc-project.git
   ```
3. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### 1. Local Development Setup
```bash
# Install dependencies
terraform --version  # Ensure >= 1.6.0
aws --version        # Ensure AWS CLI is configured

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Run security checks
tflint --recursive
```

### 2. Making Changes

#### Terraform Code Standards
- Use snake_case for resource names
- Add meaningful descriptions to all variables
- Include appropriate tags on all resources
- Follow the established module structure
- Use data sources instead of hardcoded values when possible

#### Required Checks Before Committing
```bash
# Format all files
terraform fmt -recursive

# Validate syntax
find . -name "*.tf" -exec dirname {} \; | sort -u | while read dir; do
  (cd "$dir" && terraform init -backend=false && terraform validate)
done

# Run linting
tflint --recursive

# Check for security issues
checkov -d . --framework terraform
```

### 3. Commit Message Format
```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(vpc): add support for IPv6 subnets
fix(security): resolve overly permissive security group rule
docs(readme): update setup instructions
chore(deps): update terraform aws provider to 5.1.0
```

## Pull Request Process

### 1. Before Creating PR
- [ ] Code is formatted (`terraform fmt -recursive`)
- [ ] All validations pass
- [ ] Security scans are clean
- [ ] Documentation is updated
- [ ] Tests pass (if applicable)

### 2. PR Requirements
- [ ] Clear description of changes
- [ ] Link to related issue (if applicable)
- [ ] Screenshots/logs for infrastructure changes
- [ ] Cost impact assessment
- [ ] Security impact assessment

### 3. Review Process
1. **Automated Checks**: All CI/CD checks must pass
2. **Code Review**: At least 1 approval required
3. **Security Review**: Required for security-related changes
4. **Infrastructure Review**: Required for production changes

## Testing Guidelines

### Local Testing
```bash
# Test in development environment
cd environments/dev
terraform plan -var-file="terraform-dev.tfvars"
terraform apply -var-file="terraform-dev.tfvars"

# Verify resources are created correctly
aws ec2 describe-vpcs --filters "Name=tag:Environment,Values=dev"
```

### Integration Testing
- Changes must be tested in dev environment first
- Staging deployment requires approval
- Production deployment requires 2 approvals

## Security Guidelines

### Sensitive Data
- Never commit AWS credentials
- Use AWS IAM roles and OIDC for authentication
- Store secrets in GitHub Secrets or AWS Secrets Manager
- Use least privilege principle for all IAM policies

### Security Reviews
Required for changes involving:
- IAM policies or roles
- Security group rules
- Network ACLs
- VPC configurations
- Encryption settings

### Security Tools
- **Checkov**: Infrastructure security scanning
- **TFSec**: Terraform security analysis
- **GitHub Security**: Dependency and secret scanning

## Documentation Standards

### Code Documentation
- All variables must have descriptions
- Complex resources need inline comments
- Outputs should explain their purpose

### README Updates
Update documentation for:
- New features or modules
- Changed deployment procedures
- Updated prerequisites
- Modified configuration options

## Release Process

### Versioning
We use [Semantic Versioning](https://semver.org/):
- `MAJOR.MINOR.PATCH`
- Major: Breaking changes
- Minor: New features (backward compatible)
- Patch: Bug fixes

### Release Steps
1. Create release branch: `release/v1.2.0`
2. Update version numbers and changelog
3. Test thoroughly in all environments
4. Create PR to main branch
5. After merge, create GitHub release with tag

## Environment-Specific Guidelines

### Development Environment
- Fast iteration and testing
- Cost optimization (no NAT gateways, etc.)
- Relaxed security for development needs

### Staging Environment
- Production-like configuration
- Full security and monitoring
- Approval required for changes

### Production Environment
- Strict change control
- Multiple approvals required
- Comprehensive monitoring and alerting

## Common Issues and Solutions

### Terraform State Issues
```bash
# State file conflicts
terraform state pull > state.json
# Resolve conflicts manually
terraform state push state.json

# Import existing resources
terraform import aws_vpc.main vpc-12345678
```

### AWS Permission Issues
- Ensure IAM role has necessary permissions
- Check AWS CloudTrail for denied API calls
- Verify OIDC trust relationship is correct

### CI/CD Pipeline Issues
- Check GitHub Actions logs for specific errors
- Verify all required secrets are set
- Ensure branch protection rules are configured

## Getting Help

### Resources
- [Terraform Documentation](https://terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Project Issues](https://github.com/YOUR_USERNAME/terraform-vpc-project/issues)

### Contact
- Create an issue for bugs or feature requests
- Use discussions for questions and ideas
- Tag maintainers for urgent issues

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- Annual contributor appreciation

Thank you for contributing to making this project better! 🚀
