#!/bin/bash
set -e

echo "🔐 Setting up GitHub OIDC Integration..."

# Check if GitHub repository is provided
if [ -z "$1" ]; then
    echo "❌ Please provide GitHub repository in format: owner/repo"
    echo "Usage: $0 your-username/terraform-vpc-project"
    exit 1
fi

GITHUB_REPO="$1"

# Navigate to OIDC setup
cd setup/oidc

echo "📦 Initializing OIDC setup..."
terraform init

echo "📋 Planning OIDC resources..."
terraform plan -var="github_repository=$GITHUB_REPO"

echo "🏗️  Creating IAM role and OIDC provider..."
terraform apply -var="github_repository=$GITHUB_REPO" -auto-approve

# Get the role ARN
ROLE_ARN=$(terraform output -raw github_role_arn)

echo "✅ OIDC setup complete!"
echo ""
echo "📝 Add this to your GitHub repository secrets:"
echo "Secret Name: AWS_ROLE_ARN"
echo "Secret Value: $ROLE_ARN"
echo ""
echo "🌐 GitHub Settings URL:"
echo "https://github.com/$GITHUB_REPO/settings/secrets/actions"
