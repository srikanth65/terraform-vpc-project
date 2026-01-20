#!/bin/bash
set -e

# GitHub Repository Quick Setup Script
# Usage: ./setup-github-repo.sh <github-username> <repo-name>

# GITHUB_USERNAME=${1:-"your-username"}
GITHUB_USERNAME=${1:-"srikanth65"}
REPO_NAME=${2:-"terraform-vpc-project"}
REPO_DESCRIPTION="Production-ready Terraform VPC with CI/CD pipeline"

echo "🚀 Setting up GitHub repository: $GITHUB_USERNAME/$REPO_NAME"

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI not found. Please install: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo "🔐 Please authenticate with GitHub CLI:"
    gh auth login
fi

# Create repository
echo "📦 Creating GitHub repository..."
gh repo create "$REPO_NAME" \
    --public \
    --description "$REPO_DESCRIPTION" \
    --clone

cd "$REPO_NAME"

# Copy project files (assuming script is run from project directory)
echo "📁 Copying project files..."
cp -r ../terraform-vpc-project/* . 2>/dev/null || echo "⚠️  Please copy project files manually"

# Create develop branch
echo "🌿 Creating develop branch..."
git checkout -b develop
git push origin develop

# Set default branch to main
echo "🔧 Setting main as default branch..."
gh repo edit --default-branch main

# Create labels
echo "🏷️  Creating repository labels..."
gh label create "terraform" --description "Terraform related changes" --color "7B68EE" || true
gh label create "infrastructure" --description "Infrastructure changes" --color "FF6347" || true
gh label create "security" --description "Security related changes" --color "FF4500" || true
gh label create "breaking-change" --description "Breaking changes" --color "DC143C" || true
gh label create "cost-impact" --description "Changes affecting AWS costs" --color "FFD700" || true
gh label create "urgent" --description "Urgent deployment needed" --color "FF0000" || true

# Initial commit
echo "📝 Creating initial commit..."
git add .
git commit -m "Initial project setup with Terraform VPC and CI/CD pipeline"
git push origin main

echo "✅ Repository setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Configure branch protection rules:"
echo "   https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/branches"
echo ""
echo "2. Create environments (stage, production):"
echo "   https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/environments"
echo ""
echo "3. Add repository secrets:"
echo "   https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/secrets/actions"
echo "   - AWS_ROLE_ARN (after running OIDC setup)"
echo ""
echo "4. Run infrastructure setup:"
echo "   ./setup/scripts/setup-backend.sh"
echo "   ./setup/scripts/setup-oidc.sh $GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "🎉 Happy coding!"
