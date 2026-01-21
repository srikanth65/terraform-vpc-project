#!/bin/bash

# 🔥 Complete Infrastructure Destruction Script
# This script destroys ALL infrastructure in the correct order

set -e

echo "🔥 TERRAFORM VPC PROJECT - COMPLETE DESTRUCTION"
echo "================================================"
echo ""
echo "⚠️  WARNING: This will destroy ALL infrastructure!"
echo "   - All VPC resources (dev, stage, prod)"
echo "   - All KMS keys and encrypted data"
echo "   - All NAT Gateways and Elastic IPs"
echo "   - Backend infrastructure (S3, DynamoDB)"
echo "   - OIDC configuration"
echo ""

# Confirmation
read -p "Type 'DESTROY-ALL' to confirm complete destruction: " confirm
if [ "$confirm" != "DESTROY-ALL" ]; then
    echo "❌ Destruction cancelled"
    exit 1
fi

echo ""
echo "🔥 Starting complete infrastructure destruction..."
echo ""

# Function to destroy environment
destroy_environment() {
    local env=$1
    echo "🔥 Destroying $env environment..."
    
    cd "environments/$env"
    
    if terraform init; then
        if terraform destroy -var-file="terraform-$env.tfvars" -auto-approve; then
            echo "✅ $env environment destroyed successfully"
        else
            echo "❌ Failed to destroy $env environment"
            return 1
        fi
    else
        echo "❌ Failed to initialize $env environment"
        return 1
    fi
    
    cd ../..
}

# Destroy environments in reverse order (prod -> stage -> dev)
echo "📋 Step 1: Destroying application environments..."
destroy_environment "prod"
destroy_environment "stage" 
destroy_environment "dev"

echo ""
echo "📋 Step 2: Destroying backend infrastructure..."

# Destroy backend
cd setup/backend
if terraform init; then
    if terraform destroy -auto-approve; then
        echo "✅ Backend infrastructure destroyed"
    else
        echo "❌ Failed to destroy backend infrastructure"
        exit 1
    fi
else
    echo "❌ Failed to initialize backend"
    exit 1
fi
cd ../..

echo ""
echo "📋 Step 3: Destroying OIDC configuration..."

# Destroy OIDC
cd setup/oidc
if terraform init; then
    if terraform destroy -auto-approve; then
        echo "✅ OIDC configuration destroyed"
    else
        echo "❌ Failed to destroy OIDC configuration"
        exit 1
    fi
else
    echo "❌ Failed to initialize OIDC"
    exit 1
fi
cd ../..

echo ""
echo "🎉 COMPLETE DESTRUCTION FINISHED!"
echo "=================================="
echo ""
echo "✅ All environments destroyed"
echo "✅ Backend infrastructure destroyed"  
echo "✅ OIDC configuration destroyed"
echo ""
echo "⚠️  All Terraform state has been destroyed"
echo "🔄 To rebuild: Run setup scripts from scratch"
echo ""
echo "📋 Next steps to rebuild:"
echo "   1. ./setup/scripts/setup-backend.sh"
echo "   2. ./setup/scripts/setup-oidc.sh USERNAME/REPO"
echo "   3. ./setup/scripts/migrate-state.sh"
echo "   4. git push origin main"
