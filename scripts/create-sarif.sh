#!/bin/bash
# Create empty SARIF files if they don't exist

create_empty_sarif() {
    local filename=$1
    local tool_name=$2
    
    if [ ! -f "$filename" ]; then
        cat > "$filename" << EOF
{
  "\$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {
        "driver": {
          "name": "$tool_name",
          "version": "1.0.0"
        }
      },
      "results": []
    }
  ]
}
EOF
        echo "Created empty SARIF file: $filename"
    fi
}

# Create empty SARIF files
create_empty_sarif "checkov-results.sarif" "Checkov"
create_empty_sarif "tfsec-results.sarif" "TFSec"

echo "SARIF files ready"
