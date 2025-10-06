#!/bin/bash

# run-bats.sh - BATS test runner with consistent options and output formatting
# This script runs BATS tests with TAP output and optional JUnit formatting

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default values
TEST_DIR=""
OUTPUT_DIR="$REPO_ROOT/test-results"
VERBOSE=${BATS_VERBOSE:-false}
JUNIT=${BATS_JUNIT:-false}

# Usage function
usage() {
    cat <<EOF
Usage: $0 [OPTIONS] TEST_DIRECTORY

Run BATS tests with consistent options and output formatting.

OPTIONS:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    -j, --junit         Generate JUnit XML output
    -o, --output DIR    Output directory for results (default: test-results)

EXAMPLES:
    $0 test/unit                    # Run unit tests
    $0 test/integration             # Run integration tests
    $0 --verbose test/unit          # Run with verbose output
    $0 --junit --output ./results test/unit  # Generate JUnit XML

ENVIRONMENT:
    BATS_VERBOSE=true              # Enable verbose output
    BATS_JUNIT=true                # Enable JUnit output
    TZ=UTC                         # Set timezone (recommended)
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -j|--junit)
                JUNIT=true
                shift
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -*)
                echo "Error: Unknown option $1" >&2
                usage >&2
                exit 1
                ;;
            *)
                if [[ -z "$TEST_DIR" ]]; then
                    TEST_DIR="$1"
                else
                    echo "Error: Multiple test directories specified" >&2
                    exit 1
                fi
                shift
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$TEST_DIR" ]]; then
        echo "Error: Test directory is required" >&2
        usage >&2
        exit 1
    fi

    # Convert to absolute path
    TEST_DIR="$(cd "$TEST_DIR" 2>/dev/null && pwd || echo "$TEST_DIR")"
}

# Setup environment for tests
setup_environment() {
    # Ensure timezone is set for deterministic tests
    export TZ=UTC
    
    # Set up PATH to include test bin and bats
    export PATH="$REPO_ROOT/test/bin:$REPO_ROOT/test/vendor/bats-core/bin:$PATH"
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Setup git for tests (if not in CI)
    if [[ -z "${CI:-}" ]]; then
        # Configure git safely for tests
        git config --global --add safe.directory "$REPO_ROOT" 2>/dev/null || true
    fi
}

# Check if BATS is available
check_bats() {
    if ! command -v bats >/dev/null 2>&1; then
        echo "Error: BATS not found in PATH" >&2
        echo "Make sure git submodules are initialized:" >&2
        echo "  git submodule update --init --recursive" >&2
        exit 1
    fi
    
    # Check if test directory exists
    if [[ ! -d "$TEST_DIR" ]]; then
        echo "Error: Test directory does not exist: $TEST_DIR" >&2
        exit 1
    fi
    
    # Check if there are any .bats files
    if ! find "$TEST_DIR" -name "*.bats" -type f | grep -q .; then
        echo "Warning: No .bats files found in $TEST_DIR"
        exit 0
    fi
}

# Run BATS with appropriate options
run_bats() {
    local bats_args=()
    local tap_file="$OUTPUT_DIR/bats.tap"
    local junit_file="$OUTPUT_DIR/junit.xml"
    
    # Always generate TAP output
    bats_args+=(--formatter tap)
    
    # Add verbose output if requested
    if [[ "$VERBOSE" == "true" ]]; then
        bats_args+=(--verbose-run)
    fi
    
    # Add timing information
    bats_args+=(--timing)
    
    echo "Running BATS tests in: $TEST_DIR"
    echo "Output directory: $OUTPUT_DIR"
    
    # Run BATS and capture output
    if bats "${bats_args[@]}" "$TEST_DIR" | tee "$tap_file"; then
        echo "✅ All tests passed"
        local exit_code=0
    else
        echo "❌ Some tests failed"
        local exit_code=1
    fi
    
    # Generate JUnit XML if requested
    if [[ "$JUNIT" == "true" ]]; then
        if command -v tap-junit >/dev/null 2>&1; then
            echo "Generating JUnit XML..."
            tap-junit < "$tap_file" > "$junit_file"
        else
            echo "Warning: tap-junit not found. JUnit XML generation skipped."
            echo "Install with: npm install -g tap-junit"
        fi
    fi
    
    # Show summary
    echo ""
    echo "Test Results Summary:"
    echo "====================="
    
    if [[ -f "$tap_file" ]]; then
        local total_tests
        local failed_tests
        total_tests=$(grep -c "^ok\|^not ok" "$tap_file" || echo "0")
        failed_tests=$(grep -c "^not ok" "$tap_file" || echo "0")
        
        echo "Total tests: $total_tests"
        echo "Failed tests: $failed_tests"
        echo "TAP output: $tap_file"
        
        if [[ "$JUNIT" == "true" && -f "$junit_file" ]]; then
            echo "JUnit XML: $junit_file"
        fi
    fi
    
    return $exit_code
}

# Main function
main() {
    parse_args "$@"
    setup_environment
    check_bats
    run_bats
}

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi