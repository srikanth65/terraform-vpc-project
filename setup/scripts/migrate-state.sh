#!/bin/bash
set -e

echo "📦 Migrating Terraform state to remote backend..."

ENVIRONMENTS=("dev" "stage" "prod")

for env in "${ENVIRONMENTS[@]}"; do
    echo "🔄 Migrating $env environment..."
    
    cd "environments/$env"
    
    # Check if local state exists
    if [ -f "terraform.tfstate" ]; then
        echo "📋 Local state found, migrating to remote backend..."
        terraform init -migrate-state -force-copy
        
        # Backup local state
        mv terraform.tfstate "terraform.tfstate.local.backup"
        echo "💾 Local state backed up as terraform.tfstate.local.backup"
    else
        echo "📦 No local state found, initializing with remote backend..."
        terraform init
    fi
    
    cd - > /dev/null
    echo "✅ $env environment migration complete!"
done

echo ""
echo "🎉 All environments migrated to remote backend!"
echo ""
echo "📝 You can now safely delete local state backup files if everything works correctly:"
echo "find environments/ -name '*.local.backup' -delete"
