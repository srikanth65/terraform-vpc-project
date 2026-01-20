#!/bin/bash
set -e

echo "🔔 Setting up Slack/Teams integration..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI not found. Please install: https://cli.github.com/${NC}"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}🔐 Please authenticate with GitHub CLI:${NC}"
    gh auth login
fi

echo -e "${GREEN}📋 Checking current GitHub secrets...${NC}"

# Check existing secrets
SECRETS=$(gh secret list --json name --jq '.[].name')

echo "Current secrets:"
echo "$SECRETS"

echo ""
echo -e "${YELLOW}📝 Required secrets for notifications:${NC}"
echo "1. SLACK_WEBHOOK_URL - Slack incoming webhook URL"
echo "2. TEAMS_WEBHOOK_URL - Microsoft Teams webhook URL"
echo "3. AWS_ROLE_ARN - AWS IAM role for GitHub Actions (should already exist)"

echo ""
echo -e "${GREEN}🔧 Setting up notification secrets...${NC}"

# Function to add secret
add_secret() {
    local secret_name=$1
    local secret_description=$2
    
    if echo "$SECRETS" | grep -q "^$secret_name$"; then
        echo -e "${YELLOW}⚠️  $secret_name already exists${NC}"
        read -p "Do you want to update it? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    echo -e "${GREEN}📝 Adding $secret_name${NC}"
    echo "$secret_description"
    read -p "Enter the webhook URL: " webhook_url
    
    if [ -n "$webhook_url" ]; then
        gh secret set "$secret_name" --body "$webhook_url"
        echo -e "${GREEN}✅ $secret_name added successfully${NC}"
    else
        echo -e "${RED}❌ No URL provided, skipping $secret_name${NC}"
    fi
}

# Add Slack webhook
echo ""
echo -e "${GREEN}🔔 Slack Integration Setup${NC}"
echo "1. Go to https://api.slack.com/apps"
echo "2. Create new app → From scratch"
echo "3. Enable Incoming Webhooks"
echo "4. Add webhook to workspace"
echo "5. Copy the webhook URL"
echo ""
add_secret "SLACK_WEBHOOK_URL" "Slack webhook URL (https://hooks.slack.com/services/...)"

# Add Teams webhook
echo ""
echo -e "${GREEN}📢 Microsoft Teams Integration Setup${NC}"
echo "1. Go to your Teams channel"
echo "2. Click ... → Connectors"
echo "3. Configure Incoming Webhook"
echo "4. Set name and create"
echo "5. Copy the webhook URL"
echo ""
add_secret "TEAMS_WEBHOOK_URL" "Teams webhook URL (https://outlook.office.com/webhook/...)"

# Test webhooks
echo ""
echo -e "${GREEN}🧪 Testing webhook integration...${NC}"

# Create test workflow dispatch
echo "Creating test notification..."
cat > test-notification.yml << 'EOF'
name: Test Notifications
on:
  workflow_dispatch:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - name: Test Slack
      if: env.SLACK_WEBHOOK_URL != ''
      run: |
        curl -X POST -H 'Content-type: application/json' \
          --data '{"text":"🧪 Test notification from Terraform Infrastructure Bot"}' \
          ${{ secrets.SLACK_WEBHOOK_URL }}
    
    - name: Test Teams
      if: env.TEAMS_WEBHOOK_URL != ''
      run: |
        curl -H "Content-Type: application/json" \
          -d '{"text":"🧪 Test notification from Terraform Infrastructure Bot"}' \
          ${{ secrets.TEAMS_WEBHOOK_URL }}
EOF

# Check if workflows directory exists
if [ ! -d ".github/workflows" ]; then
    mkdir -p .github/workflows
fi

# Move test workflow
mv test-notification.yml .github/workflows/

echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Commit and push the changes:"
echo "   git add .github/workflows/"
echo "   git commit -m 'Add notification workflows'"
echo "   git push origin main"
echo ""
echo "2. Test notifications:"
echo "   - Go to Actions tab in GitHub"
echo "   - Run 'Test Notifications' workflow"
echo "   - Check your Slack/Teams channels"
echo ""
echo "3. Notification workflows are now active for:"
echo "   ✅ Deployment success/failure"
echo "   🚨 Security vulnerabilities (every 6 hours)"
echo "   💰 Cost alerts (weekly)"
echo "   📊 Infrastructure reports"
echo ""
echo -e "${GREEN}🎉 Your infrastructure monitoring is now live!${NC}"

# Cleanup
rm -f test-notification.yml
