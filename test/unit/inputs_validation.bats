#!/usr/bin/env bats

# inputs_validation.bats - Unit tests for input validation and sanitization
# Tests the parse_inputs() and get_backup_date() functions from inputs.sh

# Load test helpers
load "../helpers/load"

# Source the library under test
setup() {
    # Source the inputs library
    source "$REPO_ROOT/src/lib/inputs.sh"
    
    # Setup test environment
    setup_github_env
    setup_test_date "2024-01-02"
    
    # Clear any existing inputs
    unset INPUT_BACKUP_PREFIX INPUT_BRANCH_TO_BACKUP INPUT_GITHUB_TOKEN
}

teardown() {
    cleanup_github_env
}

@test "inputs: defaults applied when not provided" {
    # No inputs provided - should use defaults
    # Test by running parse_inputs and then checking exported variables
    parse_inputs
    
    assert_equal "$BACKUP_PREFIX" "backup"
    assert_equal "$BRANCH_TO_BACKUP" "main"
    assert_equal "${GITHUB_TOKEN:-}" ""
}

@test "inputs: accepts valid backup prefix" {
    export INPUT_BACKUP_PREFIX="test-prefix"
    export INPUT_BRANCH_TO_BACKUP="main"
    export INPUT_GITHUB_TOKEN="fake-token"
    
    parse_inputs
    
    assert_equal "$BACKUP_PREFIX" "test-prefix"
    assert_equal "$BRANCH_TO_BACKUP" "main"
    assert_equal "$GITHUB_TOKEN" "fake-token"
}

@test "inputs: accepts alphanumeric, dash, and underscore in backup prefix" {
    export INPUT_BACKUP_PREFIX="valid_prefix-123"
    export INPUT_BRANCH_TO_BACKUP="main"
    
    parse_inputs
    
    assert_equal "$BACKUP_PREFIX" "valid_prefix-123"
}

@test "inputs: trims whitespace from inputs" {
    export INPUT_BACKUP_PREFIX="  backup  "
    export INPUT_BRANCH_TO_BACKUP="  main  "
    
    parse_inputs
    
    assert_equal "$BACKUP_PREFIX" "backup"
    assert_equal "$BRANCH_TO_BACKUP" "main"
}

@test "inputs: rejects empty backup prefix after trimming" {
    export INPUT_BACKUP_PREFIX="   "
    export INPUT_BRANCH_TO_BACKUP="main"
    
    run parse_inputs
    
    assert_failure
    assert_output --partial "backup-prefix cannot be empty"
}

@test "inputs: rejects backup prefix with spaces" {
    export INPUT_BACKUP_PREFIX="backup prefix"
    export INPUT_BRANCH_TO_BACKUP="main"
    
    run parse_inputs
    
    assert_failure
    assert_output --partial "invalid characters"
}

@test "inputs: rejects backup prefix with special characters" {
    export INPUT_BACKUP_PREFIX="backup@prefix"
    export INPUT_BRANCH_TO_BACKUP="main"
    
    run parse_inputs
    
    assert_failure
    assert_output --partial "invalid characters"
}

@test "inputs: rejects path traversal in backup prefix" {
    export INPUT_BACKUP_PREFIX="../backup"
    export INPUT_BRANCH_TO_BACKUP="main"
    
    run parse_inputs
    
    assert_failure
    assert_output --partial "invalid characters"
}

@test "inputs: rejects empty branch name" {
    export INPUT_BACKUP_PREFIX="backup"
    export INPUT_BRANCH_TO_BACKUP=""
    
    run parse_inputs
    
    assert_failure
    assert_output --partial "branch-to-backup cannot be empty"
}

@test "inputs: rejects empty branch name after trimming" {
    export INPUT_BACKUP_PREFIX="backup"
    export INPUT_BRANCH_TO_BACKUP="   "
    
    run parse_inputs
    
    assert_failure
    assert_output --partial "branch-to-backup cannot be empty"
}

@test "inputs: handles missing github token gracefully" {
    export INPUT_BACKUP_PREFIX="backup"
    export INPUT_BRANCH_TO_BACKUP="main"
    # INPUT_GITHUB_TOKEN not set, GITHUB_TOKEN not set
    unset GITHUB_TOKEN
    
    parse_inputs
    
    assert_equal "${GITHUB_TOKEN:-}" ""
}

@test "inputs: uses fallback GITHUB_TOKEN when INPUT_GITHUB_TOKEN not set" {
    export INPUT_BACKUP_PREFIX="backup"
    export INPUT_BRANCH_TO_BACKUP="main"
    export GITHUB_TOKEN="fallback-token"
    # INPUT_GITHUB_TOKEN not set
    unset INPUT_GITHUB_TOKEN
    
    parse_inputs
    
    assert_equal "$GITHUB_TOKEN" "fallback-token"
}

@test "inputs: INPUT_GITHUB_TOKEN takes precedence over GITHUB_TOKEN" {
    export INPUT_BACKUP_PREFIX="backup"
    export INPUT_BRANCH_TO_BACKUP="main"
    export INPUT_GITHUB_TOKEN="input-token"
    export GITHUB_TOKEN="fallback-token"
    
    parse_inputs
    
    assert_equal "$GITHUB_TOKEN" "input-token"
}

@test "inputs: does not leak github token in output or error messages" {
    export INPUT_BACKUP_PREFIX="backup"
    export INPUT_BRANCH_TO_BACKUP="main"
    export INPUT_GITHUB_TOKEN="secret-token-12345"
    
    run parse_inputs
    
    assert_success
    assert_no_secrets_leaked "$output" "secret-token-12345"
}

@test "date: uses current date when BBA_DATE_OVERRIDE not set" {
    unset BBA_DATE_OVERRIDE
    
    # Mock date command to return known value
    date() {
        if [[ "${1:-}" == "-u" && "${2:-}" == "+%Y-%m-%d" ]]; then
            echo "2024-12-25"
        else
            command date "$@"
        fi
    }
    export -f date
    
    run get_backup_date
    
    assert_success
    assert_output "2024-12-25"
}

@test "date: respects BBA_DATE_OVERRIDE for testing" {
    export BBA_DATE_OVERRIDE="2024-01-02"
    
    run get_backup_date
    
    assert_success
    assert_output "2024-01-02"
}

@test "date: BBA_DATE_OVERRIDE overrides system date" {
    export BBA_DATE_OVERRIDE="1999-12-31"
    
    # Mock date to return different value - should be ignored
    date() {
        echo "2024-01-01"
    }
    export -f date
    
    run get_backup_date
    
    assert_success
    assert_output "1999-12-31"
}

@test "inputs: exports variables for use by other functions" {
    export INPUT_BACKUP_PREFIX="test-backup"
    export INPUT_BRANCH_TO_BACKUP="develop"
    export INPUT_GITHUB_TOKEN="test-token"
    
    # Run parse_inputs in current shell context (not subshell)
    parse_inputs
    
    # Variables should be available in current shell
    assert_equal "$BACKUP_PREFIX" "test-backup"
    assert_equal "$BRANCH_TO_BACKUP" "develop"
    assert_equal "$GITHUB_TOKEN" "test-token"
}

@test "inputs: validates extremely long prefix" {
    # Create a very long prefix (over 255 chars)
    local long_prefix
    long_prefix=$(printf 'a%.0s' {1..300})
    
    export INPUT_BACKUP_PREFIX="$long_prefix"
    export INPUT_BRANCH_TO_BACKUP="main"
    
    run parse_inputs
    
    # This should succeed - Git can handle long branch names up to a point
    # The actual length limit will be tested in integration tests
    assert_success
}

@test "inputs: handles unicode characters in prefix" {
    export INPUT_BACKUP_PREFIX="bäckup"
    export INPUT_BRANCH_TO_BACKUP="main"
    
    run parse_inputs
    
    # Should fail due to non-ASCII characters
    assert_failure
    assert_output --partial "invalid characters"
}