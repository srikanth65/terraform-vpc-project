# Infrastructure Reporting

## Overview
This project includes comprehensive reporting capabilities that generate infrastructure insights without breaking the CI/CD pipeline.

## Report Types

### 1. Summary Report
- Resource counts per environment
- VPC and subnet information
- Security group counts
- Deployment status

### 2. Detailed Report
- Complete Terraform state listing
- All outputs and variables
- Resource configurations

### 3. Security Report
- Checkov security scan results
- TFSec vulnerability analysis
- Compliance findings

### 4. Cost Report
- Resource cost estimates (requires Infracost)
- Environment cost breakdown
- Cost optimization recommendations

## How to Generate Reports

### Manual Report Generation
```bash
# Generate summary for all environments
./scripts/generate-report.sh all summary

# Generate detailed report for specific environment
./scripts/generate-report.sh dev detailed

# Generate security report
./scripts/generate-report.sh all security

# Generate cost analysis
./scripts/generate-report.sh all cost
```

### GitHub Actions Reports

#### 1. Manual Workflow Dispatch
- Go to Actions → "Generate Infrastructure Report"
- Select environment and report type
- Reports are uploaded as artifacts
- Summary posted as GitHub issue

#### 2. Scheduled Reports
- Automatic weekly reports every Monday at 9 AM UTC
- Summary reports for all environments
- Available as workflow artifacts

#### 3. Post-Deployment Reports
- Automatically generated after successful deployments
- Non-blocking (won't fail pipeline if report fails)
- Available as workflow artifacts

## Report Locations

### Local Reports
```
reports/
├── summary.md           # Environment summary
├── detailed-dev.md      # Detailed dev report
├── detailed-stage.md    # Detailed stage report
├── detailed-prod.md     # Detailed prod report
├── security.md          # Security scan results
├── cost.md             # Cost analysis
└── index.md            # Report index
```

### GitHub Actions
- **Artifacts**: Available for 7-30 days
- **Issues**: Summary reports posted as issues
- **Workflow logs**: Detailed execution logs

## Pipeline Safety

### Non-Breaking Design
- All reporting steps use `continue-on-error: true`
- Reports run in separate jobs
- Main deployment pipeline never blocked by reports
- Failed reports don't affect infrastructure deployment

### Error Handling
- Graceful degradation when tools unavailable
- Fallback messages for missing data
- Comprehensive error logging

## Report Customization

### Adding New Report Types
1. Modify `scripts/generate-report.sh`
2. Add new case in report type switch
3. Update workflow inputs if needed

### Custom Metrics
```bash
# Add to generate-report.sh
get_custom_metrics() {
    local env=$1
    # Your custom logic here
    echo "- Custom Metric: $value" >> reports/summary.md
}
```

### Integration with External Tools
- **Infracost**: Cost analysis and estimation
- **Checkov**: Security and compliance scanning
- **TFSec**: Terraform security analysis
- **Custom tools**: Easy to integrate via script

## Best Practices

### Report Frequency
- **Summary**: Weekly or after major deployments
- **Detailed**: On-demand or monthly
- **Security**: Weekly or after security updates
- **Cost**: Monthly or before budget reviews

### Report Storage
- Local reports for development
- GitHub artifacts for CI/CD history
- External storage for long-term retention

### Report Review
- Include in code review process
- Regular security report reviews
- Cost report analysis for optimization

## Troubleshooting

### Common Issues
1. **Missing tools**: Install Checkov, TFSec, Infracost
2. **AWS permissions**: Ensure read access to resources
3. **State access**: Verify backend configuration

### Debug Commands
```bash
# Test report generation locally
./scripts/generate-report.sh dev summary

# Check tool availability
which checkov tfsec infracost

# Verify Terraform state access
terraform state list
```

## Examples

### Sample Summary Report
```markdown
# Infrastructure Summary Report
Generated: 2026-01-19

## Environment: dev
### Resources
- Total Resources: 12
- VPC ID: vpc-12345678
- CIDR Block: 10.0.0.0/16
- Public Subnets: 2
- Private Subnets: 2
- Security Groups: 3
```

### Sample Security Report
```markdown
# Security Report
Generated: 2026-01-19

## Security Scan Results
### Checkov Results
✅ Passed: 15 checks
⚠️  Warning: 2 checks
❌ Failed: 0 checks

### TFSec Results
No security issues found
```
