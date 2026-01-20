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
        "sts:AssumeRole",
        "logs:CreateLogGroup",
        "logs:DeleteLogGroup",
        "logs:PutRetentionPolicy",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:PassRole",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy"
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
    aws iam create-role --role-name "TerraformRole-$env" --assume-role-policy-document file://trust-policy.json || echo "Role TerraformRole-$env already exists"
    aws iam put-role-policy --role-name "TerraformRole-$env" --policy-name "TerraformPolicy-$env" --policy-document file://developer-policy.json
done

# 4. Create access keys
echo "🔑 Creating access keys..."
aws iam create-access-key --user-name terraform-developer > access-keys.json || echo "Access keys may already exist"

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
echo ""
echo "🚨 IMPORTANT: Remove admin user access keys after confirming this setup works!"

# Cleanup
rm -f developer-policy.json trust-policy.json
