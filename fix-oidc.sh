#!/bin/bash
set -e

echo "🔧 Fixing OIDC trust relationship..."

# Get current repository name from user
read -p "Enter your GitHub repository name (format: username/repo-name): " REPO_NAME

if [ -z "$REPO_NAME" ]; then
    echo "❌ Repository name is required"
    exit 1
fi

echo "📝 Updating OIDC role trust policy for repository: $REPO_NAME"

# Update the trust policy
aws iam update-assume-role-policy \
    --role-name github-actions-terraform-role \
    --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Federated": "arn:aws:iam::664841856213:oidc-provider/token.actions.githubusercontent.com"
                },
                "Action": "sts:AssumeRoleWithWebIdentity",
                "Condition": {
                    "StringEquals": {
                        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                    },
                    "StringLike": {
                        "token.actions.githubusercontent.com:sub": "repo:'$REPO_NAME':*"
                    }
                }
            }
        ]
    }' \
    --region us-east-2

echo "✅ OIDC trust policy updated successfully!"
echo ""
echo "🧪 Test the connection:"
echo "1. Go to GitHub Actions"
echo "2. Run any workflow"
echo "3. Check if AWS authentication works"
