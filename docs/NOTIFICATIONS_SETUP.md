# Slack & Teams Integration Setup Guide

## 🚀 Overview

Set up real-time notifications for:
- Deployment status (success/failure)
- Security vulnerabilities
- Infrastructure changes
- Cost alerts
- Approval requests

## 📱 Slack Integration

### Step 1: Create Slack App

1. **Go to Slack API**: https://api.slack.com/apps
2. **Create New App** → "From scratch"
3. **App Name**: `Terraform Infrastructure Bot`
4. **Workspace**: Select your workspace

### Step 2: Configure Incoming Webhooks

1. **Features** → **Incoming Webhooks** → **Activate**
2. **Add New Webhook to Workspace**
3. **Select Channel**: `#infrastructure` or `#alerts`
4. **Copy Webhook URL**: `https://hooks.slack.com/services/...`

### Step 3: Add Webhook to GitHub Secrets

1. **GitHub Repository** → **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret**:
   - Name: `SLACK_WEBHOOK_URL`
   - Value: Your webhook URL

### Step 4: Create Security Alerts Channel

1. **Create Channel**: `#security-alerts`
2. **Add New Webhook** for security channel
3. **Add to GitHub Secrets**:
   - Name: `SLACK_SECURITY_WEBHOOK_URL`
   - Value: Security webhook URL

## 🔔 Microsoft Teams Integration

### Step 1: Create Incoming Webhook

1. **Teams Channel** → **...** → **Connectors**
2. **Configure** → **Incoming Webhook**
3. **Name**: `Terraform Infrastructure`
4. **Upload Image**: Optional logo
5. **Create** → **Copy URL**

### Step 2: Add to GitHub Secrets

1. **GitHub Repository** → **Settings** → **Secrets**
2. **New repository secret**:
   - Name: `TEAMS_WEBHOOK_URL`
   - Value: Your Teams webhook URL

## 🔧 Complete Setup Commands

### Quick Setup Script
```bash
#!/bin/bash
echo "🔔 Setting up Slack/Teams integration..."

# Check if webhooks are configured
if [ -z "$SLACK_WEBHOOK_URL" ]; then
    echo "⚠️  SLACK_WEBHOOK_URL not set in GitHub secrets"
    echo "📋 Add it at: https://github.com/YOUR_USERNAME/terraform-vpc-project/settings/secrets/actions"
fi

if [ -z "$TEAMS_WEBHOOK_URL" ]; then
    echo "⚠️  TEAMS_WEBHOOK_URL not set in GitHub secrets"
    echo "📋 Add it at: https://github.com/YOUR_USERNAME/terraform-vpc-project/settings/secrets/actions"
fi

echo "✅ Setup complete! Notifications will be sent on:"
echo "   • Deployment success/failure"
echo "   • Security vulnerabilities"
echo "   • Cost threshold exceeded"
echo "   • Manual workflow triggers"
```

## 📊 Notification Types

### 1. Deployment Notifications
- ✅ **Success**: Green notification with deployment summary
- ❌ **Failure**: Red alert with error details and logs link
- 📋 **Details**: Repository, branch, commit, author

### 2. Security Vulnerability Alerts
- 🚨 **High Severity**: Immediate alerts for security issues
- 📊 **Scan Results**: Checkov and TFSec findings
- 🔍 **Details**: Issue count, severity, remediation links

### 3. Cost Monitoring Alerts
- 💰 **Threshold Exceeded**: When monthly costs exceed limit
- 📈 **Cost Breakdown**: Service-wise cost analysis
- 📅 **Weekly Reports**: Regular cost summaries

### 4. Approval Requests
- 🔒 **Stage Deployment**: Approval needed for staging
- 🏭 **Production Deployment**: Approval needed for production
- ⏰ **Timeout Warnings**: Pending approval reminders

## 🎨 Customization Options

### Slack Message Customization
```yaml
- name: Custom Slack Alert
  uses: 8398a7/action-slack@v3
  with:
    status: custom
    webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
    channel: '#infrastructure'
    username: 'Custom Bot Name'
    icon_emoji: ':terraform:'
    custom_payload: |
      {
        "attachments": [{
          "color": "good",
          "title": "Custom Alert Title",
          "text": "Custom message text",
          "fields": [
            {
              "title": "Field Title",
              "value": "Field Value",
              "short": true
            }
          ]
        }]
      }
```

### Teams Message Customization
```yaml
- name: Custom Teams Alert
  uses: skitionek/notify-microsoft-teams@master
  with:
    webhook_url: ${{ secrets.TEAMS_WEBHOOK_URL }}
    overwrite: |
      {
        "@type": "MessageCard",
        "@context": "https://schema.org/extensions",
        "summary": "Custom Alert",
        "themeColor": "28a745",
        "sections": [{
          "activityTitle": "Custom Title",
          "activitySubtitle": "Custom Subtitle",
          "facts": [{
            "name": "Custom Field:",
            "value": "Custom Value"
          }]
        }]
      }
```

## 🔧 Testing Notifications

### Test Slack Integration
```bash
# Test webhook manually
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Test message from Terraform project"}' \
  YOUR_SLACK_WEBHOOK_URL
```

### Test Teams Integration
```bash
# Test Teams webhook
curl -H "Content-Type: application/json" \
  -d '{"text":"Test message from Terraform project"}' \
  YOUR_TEAMS_WEBHOOK_URL
```

### Trigger Test Workflow
1. **Go to Actions** → **Security Vulnerability Alerts**
2. **Run workflow** → **Manual trigger**
3. **Check notifications** in Slack/Teams

## 📋 Required GitHub Secrets

Add these secrets to your repository:

```
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
TEAMS_WEBHOOK_URL=https://outlook.office.com/webhook/...
AWS_ROLE_ARN=arn:aws:iam::ACCOUNT:role/github-actions-terraform-role
```

## 🚨 Alert Channels Recommendation

### Slack Channels
- `#infrastructure` - Deployment notifications
- `#security-alerts` - Security vulnerabilities
- `#cost-monitoring` - Cost alerts
- `#approvals` - Deployment approvals

### Teams Channels
- **Infrastructure** - All deployment notifications
- **Security** - Security-specific alerts
- **Finance** - Cost monitoring alerts

## 🔍 Monitoring Setup

### Enable All Workflows
1. **Main Pipeline**: Deployment notifications
2. **Security Alerts**: Vulnerability scanning (every 6 hours)
3. **Cost Monitoring**: Weekly cost reports
4. **Generate Reports**: Manual reporting

### Notification Schedule
- **Deployments**: Real-time (on push/merge)
- **Security Scans**: Every 6 hours + on code changes
- **Cost Alerts**: Weekly + threshold breaches
- **Reports**: Manual + post-deployment

## 🎯 Best Practices

### Channel Management
- Use dedicated channels for different alert types
- Set appropriate notification levels
- Add relevant team members to channels

### Alert Fatigue Prevention
- Use different severity levels
- Aggregate similar alerts
- Provide actionable information
- Include direct links to fixes

### Security Considerations
- Webhook URLs are sensitive - store in secrets
- Limit webhook permissions
- Regularly rotate webhook URLs
- Monitor webhook usage

## 🔧 Troubleshooting

### Common Issues

1. **Webhook Not Working**
   ```bash
   # Test webhook URL
   curl -X POST YOUR_WEBHOOK_URL -d '{"text":"test"}'
   ```

2. **Notifications Not Appearing**
   - Check webhook URL in secrets
   - Verify channel permissions
   - Check workflow logs

3. **Wrong Channel**
   - Update channel name in workflow
   - Ensure bot has access to channel

### Debug Commands
```bash
# Check GitHub secrets (won't show values)
gh secret list

# Test workflow manually
gh workflow run security-alerts.yml

# View workflow logs
gh run list --workflow=security-alerts.yml
```

This setup provides comprehensive real-time monitoring for your Terraform infrastructure with professional-grade notifications!
