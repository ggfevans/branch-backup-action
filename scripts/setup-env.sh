#!/bin/bash

# setup-env.sh - Environment setup script for development and CI
# This script sets up git configs safely and ensures proper environment

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Mode: development or ci
MODE="${1:-development}"

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

# Setup timezone
setup_timezone() {
    export TZ=UTC
    print_color "$GREEN" "✅ Timezone set to UTC"
}

# Setup git for development
setup_git_development() {
    print_color "$YELLOW" "Setting up git for development..."
    
    # Add safe directory for this repo
    git config --global --add safe.directory "$REPO_ROOT" 2>/dev/null || true
    
    # Check if user has git config
    local user_name
    local user_email
    
    user_name=$(git config --global user.name 2>/dev/null || echo "")
    user_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -z "$user_name" || -z "$user_email" ]]; then
        print_color "$YELLOW" "⚠️  Git user not configured globally"
        print_color "$YELLOW" "   This is fine - tests will use isolated config"
    else
        print_color "$GREEN" "✅ Git user configured: $user_name <$user_email>"
    fi
    
    # Ensure line endings are consistent
    git config --global core.autocrlf false 2>/dev/null || true
    
    print_color "$GREEN" "✅ Git setup complete for development"
}

# Setup git for CI
setup_git_ci() {
    print_color "$YELLOW" "Setting up git for CI..."
    
    # Configure git for CI environment
    git config --global user.name "GitHub Actions"
    git config --global user.email "actions@github.com"
    git config --global init.defaultBranch main
    git config --global core.autocrlf false
    git config --global --add safe.directory "$REPO_ROOT"
    
    print_color "$GREEN" "✅ Git configured for CI"
}

# Check required tools
check_tools() {
    print_color "$YELLOW" "Checking required tools..."
    
    local missing_tools=()
    
    # Essential tools
    if ! command -v git >/dev/null 2>&1; then
        missing_tools+=("git")
    fi
    
    if ! command -v bash >/dev/null 2>&1; then
        missing_tools+=("bash")
    fi
    
    # Development tools (warnings only)
    local optional_tools=("shellcheck" "actionlint" "shfmt")
    local missing_optional=()
    
    for tool in "${optional_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_optional+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_color "$RED" "❌ Missing required tools: ${missing_tools[*]}"
        return 1
    fi
    
    print_color "$GREEN" "✅ All required tools available"
    
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        print_color "$YELLOW" "⚠️  Optional tools missing: ${missing_optional[*]}"
        print_color "$YELLOW" "   Install for better development experience:"
        for tool in "${missing_optional[@]}"; do
            case "$tool" in
                "shellcheck")
                    print_color "$YELLOW" "   - shellcheck: brew install shellcheck"
                    ;;
                "actionlint") 
                    print_color "$YELLOW" "   - actionlint: brew install actionlint"
                    ;;
                "shfmt")
                    print_color "$YELLOW" "   - shfmt: brew install shfmt"
                    ;;
            esac
        done
    fi
}

# Setup test environment
setup_test_environment() {
    print_color "$YELLOW" "Setting up test environment..."
    
    # Create necessary directories
    mkdir -p "$REPO_ROOT/test-results"
    mkdir -p "$REPO_ROOT/coverage"
    
    # Check if BATS is available
    if [[ ! -d "$REPO_ROOT/test/vendor/bats-core" ]]; then
        print_color "$YELLOW" "⚠️  BATS submodules not initialized"
        if [[ "$MODE" == "ci" ]] || read -p "Initialize git submodules now? (y/n): " -n 1 -r && echo && [[ $REPLY =~ ^[Yy]$ ]]; then
            print_color "$YELLOW" "Initializing submodules..."
            git submodule update --init --recursive
            print_color "$GREEN" "✅ Submodules initialized"
        else
            print_color "$YELLOW" "Skipped. Run 'git submodule update --init --recursive' later"
        fi
    else
        print_color "$GREEN" "✅ BATS submodules available"
    fi
    
    # Make scripts executable
    find "$REPO_ROOT/scripts" -name "*.sh" -exec chmod +x {} \;
    find "$REPO_ROOT/test/bin" -name "*" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    print_color "$GREEN" "✅ Test environment ready"
}

# Show system information
show_system_info() {
    print_color "$YELLOW" "System Information:"
    print_color "$YELLOW" "==================="
    echo "OS: $(uname -s)"
    echo "Architecture: $(uname -m)"
    echo "Shell: $SHELL"
    echo "Git version: $(git --version)"
    echo "Timezone: ${TZ:-$(date +%Z)}"
    echo "Working directory: $REPO_ROOT"
    echo ""
}

# Main setup function
main() {
    print_color "$GREEN" "Branch Backup Action - Environment Setup"
    print_color "$GREEN" "========================================"
    echo ""
    
    show_system_info
    setup_timezone
    
    case "$MODE" in
        "ci")
            setup_git_ci
            ;;
        "development"|*)
            setup_git_development
            ;;
    esac
    
    check_tools
    setup_test_environment
    
    echo ""
    print_color "$GREEN" "🎉 Environment setup complete!"
    print_color "$YELLOW" "Next steps:"
    print_color "$YELLOW" "  - Run tests: make test"
    print_color "$YELLOW" "  - Run linting: make lint"
    print_color "$YELLOW" "  - See all commands: make help"
}

# Help function
show_help() {
    cat <<EOF
Environment Setup Script

This script sets up the development/CI environment for the Branch Backup Action.

USAGE:
    $0 [MODE]

MODES:
    development    Setup for local development (default)
    ci             Setup for CI environment

EXAMPLES:
    $0                    # Setup for development
    $0 development        # Same as above
    $0 ci                 # Setup for CI

The script will:
1. Set timezone to UTC
2. Configure git appropriately
3. Check for required and optional tools
4. Setup test directories
5. Initialize submodules (if needed)
6. Make scripts executable
EOF
}

# Parse command line arguments
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_help
    exit 0
fi

# Validate mode
if [[ -n "${1:-}" && "$1" != "development" && "$1" != "ci" ]]; then
    print_color "$RED" "Error: Invalid mode '$1'"
    print_color "$YELLOW" "Valid modes: development, ci"
    exit 1
fi

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi