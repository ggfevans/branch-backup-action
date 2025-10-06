#!/bin/bash

# validate-action-yml.sh - Validate action.yml against GitHub Actions schema
# This script validates the action.yml file using check-jsonschema

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ACTION_FILE="$REPO_ROOT/action.yml"

# GitHub Actions schema URL
SCHEMA_URL="https://json.schemastore.org/github-action.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Check if action.yml exists
check_action_file() {
    if [[ ! -f "$ACTION_FILE" ]]; then
        print_color "$RED" "Error: action.yml not found at $ACTION_FILE"
        exit 1
    fi
    
    print_color "$GREEN" "Found action.yml at: $ACTION_FILE"
}

# Install check-jsonschema if needed
install_check_jsonschema() {
    if ! command -v check-jsonschema >/dev/null 2>&1; then
        print_color "$YELLOW" "check-jsonschema not found. Installing..."
        
        # Try to install using pip
        if command -v pip3 >/dev/null 2>&1; then
            pip3 install --user check-jsonschema
        elif command -v pip >/dev/null 2>&1; then
            pip install --user check-jsonschema
        else
            print_color "$RED" "Error: pip not found. Please install Python and pip first."
            print_color "$YELLOW" "Or install check-jsonschema manually:"
            print_color "$YELLOW" "  pip install check-jsonschema"
            exit 1
        fi
        
        # Add user bin to PATH if not already there
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            export PATH="$HOME/.local/bin:$PATH"
        fi
        
        # Check if installation was successful
        if ! command -v check-jsonschema >/dev/null 2>&1; then
            print_color "$RED" "Error: Failed to install check-jsonschema"
            print_color "$YELLOW" "Try installing manually: pip install check-jsonschema"
            exit 1
        fi
        
        print_color "$GREEN" "✅ check-jsonschema installed successfully"
    fi
}

# Validate YAML syntax first
validate_yaml_syntax() {
    print_color "$YELLOW" "Validating YAML syntax..."
    
    # Try python -c method first
    if command -v python3 >/dev/null 2>&1; then
        if python3 -c "import yaml; yaml.safe_load(open('$ACTION_FILE'))" 2>/dev/null; then
            print_color "$GREEN" "✅ YAML syntax is valid"
            return 0
        fi
    elif command -v python >/dev/null 2>&1; then
        if python -c "import yaml; yaml.safe_load(open('$ACTION_FILE'))" 2>/dev/null; then
            print_color "$GREEN" "✅ YAML syntax is valid"
            return 0
        fi
    fi
    
    # Try yq if available
    if command -v yq >/dev/null 2>&1; then
        if yq eval . "$ACTION_FILE" >/dev/null 2>&1; then
            print_color "$GREEN" "✅ YAML syntax is valid"
            return 0
        fi
    fi
    
    print_color "$YELLOW" "Warning: Could not validate YAML syntax (no yaml parser found)"
    print_color "$YELLOW" "Proceeding with schema validation..."
}

# Run schema validation
validate_schema() {
    print_color "$YELLOW" "Validating action.yml against GitHub Actions schema..."
    print_color "$YELLOW" "Schema: $SCHEMA_URL"
    
    if check-jsonschema --schemafile "$SCHEMA_URL" "$ACTION_FILE"; then
        print_color "$GREEN" "✅ action.yml is valid against GitHub Actions schema"
        return 0
    else
        print_color "$RED" "❌ action.yml validation failed"
        return 1
    fi
}

# Perform additional checks
additional_checks() {
    print_color "$YELLOW" "Performing additional checks..."
    
    local checks_passed=0
    local total_checks=0
    
    # Check for required fields
    for field in "name" "description" "runs"; do
        ((total_checks++))
        if grep -q "^$field:" "$ACTION_FILE"; then
            print_color "$GREEN" "✅ Required field '$field' present"
            ((checks_passed++))
        else
            print_color "$RED" "❌ Required field '$field' missing"
        fi
    done
    
    # Check for composite action
    ((total_checks++))
    if grep -q "using: 'composite'" "$ACTION_FILE" || grep -q 'using: "composite"' "$ACTION_FILE"; then
        print_color "$GREEN" "✅ Composite action properly configured"
        ((checks_passed++))
    else
        print_color "$YELLOW" "⚠️  Not a composite action (or not properly configured)"
    fi
    
    # Check for branding (optional but recommended)
    ((total_checks++))
    if grep -q "^branding:" "$ACTION_FILE"; then
        print_color "$GREEN" "✅ Branding section present"
        ((checks_passed++))
    else
        print_color "$YELLOW" "⚠️  Branding section missing (optional but recommended)"
        ((checks_passed++)) # Don't fail for optional field
    fi
    
    echo ""
    print_color "$YELLOW" "Additional checks: $checks_passed/$total_checks passed"
    
    if [[ $checks_passed -eq $total_checks ]]; then
        return 0
    else
        return 1
    fi
}

# Main function
main() {
    print_color "$YELLOW" "GitHub Actions Validation"
    print_color "$YELLOW" "========================="
    echo ""
    
    check_action_file
    install_check_jsonschema
    validate_yaml_syntax
    
    local schema_result=0
    local additional_result=0
    
    validate_schema || schema_result=$?
    echo ""
    additional_checks || additional_result=$?
    
    echo ""
    if [[ $schema_result -eq 0 && $additional_result -eq 0 ]]; then
        print_color "$GREEN" "🎉 All validations passed!"
        return 0
    else
        print_color "$RED" "❌ Validation failed"
        return 1
    fi
}

# Help function
show_help() {
    cat <<EOF
GitHub Actions action.yml Validator

This script validates action.yml files against the GitHub Actions schema
and performs additional checks for best practices.

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help    Show this help message

REQUIREMENTS:
    - Python with pip (for check-jsonschema)
    - Internet connection (to download schema)

EXAMPLE:
    $0                    # Validate action.yml in current repository
    cd /path/to/action && $0  # Validate from different directory

The script will:
1. Check if action.yml exists
2. Install check-jsonschema if needed
3. Validate YAML syntax
4. Validate against GitHub Actions schema
5. Perform additional best practice checks
EOF
}

# Parse command line arguments
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_help
    exit 0
fi

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi