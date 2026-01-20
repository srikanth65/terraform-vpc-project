#!/bin/bash
set -e

echo "🚀 Setting up Terraform VPC Project Backend..."

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Navigate to backend setup
cd setup/backend

echo "📦 Initializing backend setup..."
terraform init

echo "📋 Planning backend resources..."
terraform plan

echo "🏗️  Creating S3 bucket and DynamoDB table..."
terraform apply -auto-approve

echo "✅ Backend setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Run ./setup/scripts/setup-oidc.sh"
echo "2. Run ./setup/scripts/migrate-state.sh"
