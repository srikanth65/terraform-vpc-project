# AWS Security Best Practices Setup Guide

## 🎯 Industry Best Practices Overview

### Principle of Least Privilege
- Each user/service gets minimum required permissions
- Separate roles for different environments
- Time-limited access tokens
- No shared credentials

### Multi-Account Strategy (Recommended)
```
AWS Organization
├── Management Account (billing, users)
├── Dev Account (development resources)
├── Stage Account (staging resources)
└── Prod Account (production resources)
```

### Single Account Strategy (Your Current Setup)
```
Single AWS Account
├── IAM Users (developers)
├── IAM Roles (services, CI/CD)
├── Environment separation via tags/naming
└── Resource-level permissions
```

## 🔧 Secure Setup Implementation

### Step 1: Create Dedicated IAM Users

#### 1.1 Create Developer IAM User (Replace Admin)
```bash
# Create IAM user for development
aws iam create-user --user-name terraform-developer

# Create access keys
aws iam create-access-key --user-name terraform-developer
```

#### 1.2 Create IAM Policy for Developer
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:CreateVpc",
        "ec2:DeleteVpc",
        "ec2:CreateSubnet",
        "ec2:DeleteSubnet",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroup*",
        "ec2:RevokeSecurityGroup*",
        "ec2:CreateInternetGateway",
        "ec2:DeleteInternetGateway",
        "ec2:AttachInternetGateway",
        "ec2:DetachInternetGateway",
        "ec2:CreateRouteTable",
        "ec2:DeleteRouteTable",
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:AssociateRouteTable",
        "ec2:DisassociateRouteTable",
        "ec2:CreateTags",
        "ec2:DeleteTags"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-2"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::terraform-state-vpc-project-*",
        "arn:aws:s3:::terraform-state-vpc-project-*/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:us-east-2:*:table/terraform-locks"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:GetRole",
        "iam:PassRole"
      ],
      "Resource": "arn:aws:iam::*:role/*-flow-log-role"
    }
  ]
}
```

### Step 2: Environment-Specific Roles

#### 2.1 Create Environment Roles
```bash
# Development role
aws iam create-role --role-name TerraformDevRole --assume-role-policy-document file://trust-policy.json

# Staging role  
aws iam create-role --role-name TerraformStageRole --assume-role-policy-document file://trust-policy.json

# Production role
aws iam create-role --role-name TerraformProdRole --assume-role-policy-document file://trust-policy.json
```

#### 2.2 Trust Policy for Roles
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT_ID:user/terraform-developer"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "unique-external-id"
        }
      }
    }
  ]
}
```

### Step 3: GitHub Actions OIDC (Current - Keep This)

Your OIDC setup is correct! This is industry best practice:

```yaml
# GitHub Actions uses OIDC (no long-lived keys)
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: us-east-2
```

### Step 4: Local Development Security

#### 4.1 Use AWS CLI Profiles
```bash
# Configure developer profile
aws configure --profile terraform-dev
# Enter your developer access keys (not admin keys)

# Configure for different environments
aws configure set role_arn arn:aws:iam::ACCOUNT_ID:role/TerraformDevRole --profile dev
aws configure set source_profile terraform-dev --profile dev
aws configure set external_id unique-external-id --profile dev

aws configure set role_arn arn:aws:iam::ACCOUNT_ID:role/TerraformStageRole --profile stage
aws configure set source_profile terraform-dev --profile stage

aws configure set role_arn arn:aws:iam::ACCOUNT_ID:role/TerraformProdRole --profile prod
aws configure set source_profile terraform-dev --profile prod
```

#### 4.2 Use Profiles in Terraform
```bash
# Development
export AWS_PROFILE=dev
terraform plan

# Staging
export AWS_PROFILE=stage
terraform plan

# Production  
export AWS_PROFILE=prod
terraform plan
```

### Step 5: MFA Enforcement (Highly Recommended)

#### 5.1 Enable MFA for IAM User
```bash
# Create virtual MFA device
aws iam create-virtual-mfa-device --virtual-mfa-device-name terraform-developer-mfa --outfile QRCode.png --bootstrap-method QRCodePNG

# Enable MFA (after scanning QR code)
aws iam enable-mfa-device --user-name terraform-developer --serial-number arn:aws:iam::ACCOUNT_ID:mfa/terraform-developer-mfa --authentication-code-1 123456 --authentication-code-2 789012
```

#### 5.2 MFA Policy
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "NotAction": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:ListMFADevices",
        "iam:ListVirtualMFADevices",
        "iam:ResyncMFADevice",
        "sts:GetSessionToken"
      ],
      "Resource": "*",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "false"
        }
      }
    }
  ]
}
```

## 🔒 Security Implementation Script

### Complete Setup Script
```bash
#!/bin/bash
set -e

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
EXTERNAL_ID=$(openssl rand -hex 16)

echo "🔐 Setting up secure AWS infrastructure access..."
echo "Account ID: $ACCOUNT_ID"
echo "External ID: $EXTERNAL_ID"

# 1. Create developer user
echo "👤 Creating developer IAM user..."
aws iam create-user --user-name terraform-developer || echo "User already exists"

# 2. Create and attach developer policy
echo "📋 Creating developer policy..."
cat > developer-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:CreateVpc",
        "ec2:DeleteVpc",
        "ec2:CreateSubnet",
        "ec2:DeleteSubnet",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroup*",
        "ec2:RevokeSecurityGroup*",
        "ec2:CreateInternetGateway",
        "ec2:DeleteInternetGateway",
        "ec2:AttachInternetGateway",
        "ec2:DetachInternetGateway",
        "ec2:CreateRouteTable",
        "ec2:DeleteRouteTable",
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:AssociateRouteTable",
        "ec2:DisassociateRouteTable",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "sts:AssumeRole"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-2"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::terraform-state-vpc-project-*",
        "arn:aws:s3:::terraform-state-vpc-project-*/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:us-east-2:*:table/terraform-locks"
    }
  ]
}
EOF

aws iam put-user-policy --user-name terraform-developer --policy-name TerraformDeveloperPolicy --policy-document file://developer-policy.json

# 3. Create environment roles
echo "🏗️  Creating environment roles..."

# Trust policy for roles
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::$ACCOUNT_ID:user/terraform-developer"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "$EXTERNAL_ID"
        }
      }
    }
  ]
}
EOF

# Create roles
for env in dev stage prod; do
    aws iam create-role --role-name "TerraformRole-$env" --assume-role-policy-document file://trust-policy.json || echo "Role already exists"
    aws iam put-role-policy --role-name "TerraformRole-$env" --policy-name "TerraformPolicy-$env" --policy-document file://developer-policy.json
done

# 4. Create access keys
echo "🔑 Creating access keys..."
aws iam create-access-key --user-name terraform-developer > access-keys.json

echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Save access keys from access-keys.json"
echo "2. Configure AWS CLI profiles:"
echo "   aws configure --profile terraform-dev"
echo "3. Set up role profiles:"
echo "   aws configure set role_arn arn:aws:iam::$ACCOUNT_ID:role/TerraformRole-dev --profile dev"
echo "   aws configure set source_profile terraform-dev --profile dev"
echo "   aws configure set external_id $EXTERNAL_ID --profile dev"
echo "4. Test access:"
echo "   AWS_PROFILE=dev aws sts get-caller-identity"
echo ""
echo "🔐 External ID (save this): $EXTERNAL_ID"

# Cleanup
rm -f developer-policy.json trust-policy.json
```

## 📋 Migration Steps

### 1. Immediate Actions
```bash
# 1. Run the security setup script
chmod +x setup-security.sh
./setup-security.sh

# 2. Update your local AWS configuration
aws configure --profile terraform-dev
# Enter the new developer access keys (not admin keys)

# 3. Test the new setup
AWS_PROFILE=dev aws sts get-caller-identity
```

### 2. Remove Admin Access Keys
```bash
# After confirming new setup works
aws iam delete-access-key --user-name admin-user --access-key-id AKIA...
```

### 3. Update Local Development
```bash
# Use environment-specific profiles
export AWS_PROFILE=dev
cd environments/dev
terraform plan

export AWS_PROFILE=stage  
cd environments/stage
terraform plan
```

## 🎯 Benefits of This Approach

### Security Benefits
- ✅ Least privilege access
- ✅ Environment isolation
- ✅ Audit trail per environment
- ✅ No long-lived admin keys
- ✅ MFA enforcement
- ✅ Temporary credentials

### Operational Benefits
- ✅ Clear separation of concerns
- ✅ Easy to revoke access
- ✅ Compliance ready
- ✅ Scalable for teams
- ✅ Industry standard

### GitHub Actions (Keep Current)
- ✅ OIDC is perfect (no changes needed)
- ✅ Temporary tokens
- ✅ No secrets management
- ✅ Automatic rotation

## 🚨 Important Notes

1. **Keep GitHub OIDC**: Your current GitHub Actions setup with OIDC is perfect - don't change it
2. **Remove Admin Keys**: Delete admin user access keys after migration
3. **Use Profiles**: Always use AWS profiles for local development
4. **Enable MFA**: Highly recommended for all IAM users
5. **Regular Rotation**: Rotate access keys every 90 days

This approach follows AWS Well-Architected Framework security pillar and industry best practices used by major organizations.
