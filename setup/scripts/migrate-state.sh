#!/bin/bash
set -e

echo "📦 Migrating Terraform state to remote backend..."

# Get bucket name from backend setup
cd setup/backend
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
cd - > /dev/null

if [ -z "$BUCKET_NAME" ]; then
    echo "❌ Could not get bucket name. Please run setup-backend.sh first."
    exit 1
fi

echo "🪣 Using S3 bucket: $BUCKET_NAME"

ENVIRONMENTS=("dev" "stage" "prod")

for env in "${ENVIRONMENTS[@]}"; do
    echo "🔄 Migrating $env environment..."
    
    cd "environments/$env"
    
    # Check if local state exists
    if [ -f "terraform.tfstate" ]; then
        echo "📋 Local state found, migrating to remote backend..."
        terraform init \
            -backend-config="bucket=$BUCKET_NAME" \
            -migrate-state -force-copy
        
        # Backup local state
        mv terraform.tfstate "terraform.tfstate.local.backup"
        echo "💾 Local state backed up as terraform.tfstate.local.backup"
    else
        echo "📦 No local state found, initializing with remote backend..."
        terraform init -backend-config="bucket=$BUCKET_NAME"
    fi
    
    cd - > /dev/null
    echo "✅ $env environment migration complete!"
done

echo ""
echo "🎉 All environments migrated to remote backend!"
echo "📝 Backend configuration:"
echo "  Bucket: $BUCKET_NAME"
echo "  Region: us-east-2"
echo "  DynamoDB: terraform-locks"
echo ""
echo "📝 You can now safely delete local state backup files if everything works correctly:"
echo "find environments/ -name '*.local.backup' -delete"
