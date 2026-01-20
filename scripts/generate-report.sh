#!/bin/bash
set -e

ENVIRONMENT=${1:-"all"}
REPORT_TYPE=${2:-"summary"}
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Create reports directory
mkdir -p reports

echo "📊 Generating $REPORT_TYPE report for $ENVIRONMENT environment(s)..."

# Function to get environment info
get_env_info() {
    local env=$1
    echo "## Environment: $env" >> reports/summary.md
    
    cd "environments/$env"
    
    if [ -f "terraform.tfstate" ] || terraform state list > /dev/null 2>&1; then
        echo "### Resources" >> ../../reports/summary.md
        terraform state list | wc -l | xargs echo "- Total Resources:" >> ../../reports/summary.md
        
        # Get VPC info
        if terraform state show module.vpc.aws_vpc.main > /dev/null 2>&1; then
            VPC_ID=$(terraform output -raw vpc_id 2>/dev/null || echo "N/A")
            CIDR=$(terraform output -raw vpc_cidr_block 2>/dev/null || echo "N/A")
            echo "- VPC ID: $VPC_ID" >> ../../reports/summary.md
            echo "- CIDR Block: $CIDR" >> ../../reports/summary.md
        fi
        
        # Get subnet info
        PUBLIC_SUBNETS=$(terraform output -json public_subnet_ids 2>/dev/null | jq -r 'length' || echo "0")
        PRIVATE_SUBNETS=$(terraform output -json private_subnet_ids 2>/dev/null | jq -r 'length' || echo "0")
        echo "- Public Subnets: $PUBLIC_SUBNETS" >> ../../reports/summary.md
        echo "- Private Subnets: $PRIVATE_SUBNETS" >> ../../reports/summary.md
        
        # Security groups
        SG_COUNT=$(terraform state list | grep aws_security_group | wc -l)
        echo "- Security Groups: $SG_COUNT" >> ../../reports/summary.md
        
        echo "" >> ../../reports/summary.md
    else
        echo "- Status: No resources deployed" >> ../../reports/summary.md
        echo "" >> ../../reports/summary.md
    fi
    
    cd - > /dev/null
}

# Generate detailed report
generate_detailed_report() {
    local env=$1
    echo "# Detailed Infrastructure Report - $env" > "reports/detailed-$env.md"
    echo "Generated: $(date)" >> "reports/detailed-$env.md"
    echo "" >> "reports/detailed-$env.md"
    
    cd "environments/$env"
    
    if terraform state list > /dev/null 2>&1; then
        echo "## Terraform State" >> "../../reports/detailed-$env.md"
        terraform state list >> "../../reports/detailed-$env.md"
        echo "" >> "../../reports/detailed-$env.md"
        
        echo "## Outputs" >> "../../reports/detailed-$env.md"
        terraform output >> "../../reports/detailed-$env.md" 2>/dev/null || echo "No outputs available" >> "../../reports/detailed-$env.md"
        echo "" >> "../../reports/detailed-$env.md"
    fi
    
    cd - > /dev/null
}

# Generate security report
generate_security_report() {
    echo "# Security Report" > "reports/security.md"
    echo "Generated: $(date)" >> "reports/security.md"
    echo "" >> "reports/security.md"
    
    # Run security scans
    echo "## Security Scan Results" >> "reports/security.md"
    
    # Checkov scan
    if command -v checkov &> /dev/null; then
        echo "### Checkov Results" >> "reports/security.md"
        checkov -d . --framework terraform --quiet --compact >> "reports/security.md" 2>/dev/null || echo "Checkov scan failed" >> "reports/security.md"
    fi
    
    # TFSec scan
    if command -v tfsec &> /dev/null; then
        echo "### TFSec Results" >> "reports/security.md"
        tfsec . --format markdown >> "reports/security.md" 2>/dev/null || echo "TFSec scan failed" >> "reports/security.md"
    fi
}

# Generate cost report
generate_cost_report() {
    echo "# Cost Analysis Report" > "reports/cost.md"
    echo "Generated: $(date)" >> "reports/cost.md"
    echo "" >> "reports/cost.md"
    
    # Estimate costs using infracost if available
    if command -v infracost &> /dev/null; then
        for env in dev stage prod; do
            if [ "$ENVIRONMENT" = "all" ] || [ "$ENVIRONMENT" = "$env" ]; then
                echo "## $env Environment" >> "reports/cost.md"
                cd "environments/$env"
                infracost breakdown --path . --format table >> "../../reports/cost.md" 2>/dev/null || echo "Cost analysis not available for $env" >> "../../reports/cost.md"
                cd - > /dev/null
                echo "" >> "reports/cost.md"
            fi
        done
    else
        echo "Infracost not available. Install from: https://www.infracost.io/docs/" >> "reports/cost.md"
    fi
}

# Initialize summary report
echo "# Infrastructure Summary Report" > reports/summary.md
echo "Generated: $(date)" >> reports/summary.md
echo "" >> reports/summary.md

# Generate reports based on type and environment
case $REPORT_TYPE in
    "summary")
        if [ "$ENVIRONMENT" = "all" ]; then
            for env in dev stage prod; do
                get_env_info $env
            done
        else
            get_env_info $ENVIRONMENT
        fi
        ;;
    "detailed")
        if [ "$ENVIRONMENT" = "all" ]; then
            for env in dev stage prod; do
                generate_detailed_report $env
            done
        else
            generate_detailed_report $ENVIRONMENT
        fi
        ;;
    "security")
        generate_security_report
        ;;
    "cost")
        generate_cost_report
        ;;
esac

# Create index file
echo "# Infrastructure Reports" > reports/index.md
echo "Generated: $(date)" >> reports/index.md
echo "" >> reports/index.md
echo "Available reports:" >> reports/index.md
ls reports/*.md | grep -v index.md | while read file; do
    basename "$file" .md | xargs echo "- " >> reports/index.md
done

echo "✅ Report generation complete!"
echo "📁 Reports saved in: reports/"
ls -la reports/
