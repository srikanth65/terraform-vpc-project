---
name: Infrastructure Change
about: Request infrastructure modifications
title: '[INFRA] '
labels: ['infrastructure', 'terraform']
assignees: ''
---

## Change Description
Describe the infrastructure change you want to make.

## Motivation
Why is this change needed?

## Environment
- [ ] Development
- [ ] Staging
- [ ] Production
- [ ] All environments

## Resources Affected
List the AWS resources that will be modified:
- [ ] VPC
- [ ] Subnets
- [ ] Security Groups
- [ ] NAT Gateways
- [ ] Route Tables
- [ ] Other: ___________

## Change Type
- [ ] Addition of new resources
- [ ] Modification of existing resources
- [ ] Removal of resources
- [ ] Configuration change

## Risk Assessment
- [ ] Low risk (no impact on running services)
- [ ] Medium risk (minimal service impact)
- [ ] High risk (potential service disruption)

## Cost Impact
- [ ] No cost change
- [ ] Cost increase: $___/month
- [ ] Cost decrease: $___/month

## Security Impact
- [ ] No security impact
- [ ] Improves security
- [ ] Requires security review
- [ ] Changes network access patterns

## Testing Plan
How will you test this change?
- [ ] Local terraform plan
- [ ] Deploy to dev environment first
- [ ] Validate connectivity/functionality
- [ ] Performance testing (if applicable)

## Rollback Plan
Describe how to rollback if something goes wrong:

## Dependencies
List any dependencies or prerequisites:

## Timeline
When do you need this change implemented?
- [ ] ASAP
- [ ] Within 1 week
- [ ] Within 1 month
- [ ] No specific timeline

## Additional Notes
Any other relevant information:
