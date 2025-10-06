#!/bin/bash

# env.bash - GitHub Actions environment variables helper
# This file exports fake GitHub Actions environment variables for testing

# Setup fake GitHub Actions environment
setup_github_env() {
    local workspace="${1:-$BATS_TEST_TMPDIR/workspace}"
    local repo="${2:-testorg/testrepo}"
    
    # Create temp files for outputs and summary
    export GITHUB_OUTPUT="$BATS_TEST_TMPDIR/github_output"
    export GITHUB_STEP_SUMMARY="$BATS_TEST_TMPDIR/github_summary"
    export GITHUB_WORKSPACE="$workspace"
    export GITHUB_REPOSITORY="$repo"
    export GITHUB_SHA="abc123def456"
    export GITHUB_REF="refs/heads/main"
    export GITHUB_RUN_ID="12345"
    export RUNNER_OS="Linux"
    
    # Create empty files
    touch "$GITHUB_OUTPUT" "$GITHUB_STEP_SUMMARY"
    mkdir -p "$GITHUB_WORKSPACE"
}

# Setup test inputs
setup_test_inputs() {
    local backup_prefix="${1:-backup}"
    local branch_to_backup="${2:-main}"
    local github_token="${3:-fake-token}"
    
    export INPUT_BACKUP_PREFIX="$backup_prefix"
    export INPUT_BRANCH_TO_BACKUP="$branch_to_backup" 
    export INPUT_GITHUB_TOKEN="$github_token"
}

# Set deterministic date for testing
setup_test_date() {
    local date="${1:-2024-01-02}"
    export BBA_DATE_OVERRIDE="$date"
}

# Cleanup environment
cleanup_github_env() {
    unset GITHUB_OUTPUT GITHUB_STEP_SUMMARY GITHUB_WORKSPACE
    unset GITHUB_REPOSITORY GITHUB_SHA GITHUB_REF GITHUB_RUN_ID RUNNER_OS
    unset INPUT_BACKUP_PREFIX INPUT_BRANCH_TO_BACKUP INPUT_GITHUB_TOKEN
    unset BBA_DATE_OVERRIDE
}

# Read GitHub outputs
read_github_outputs() {
    if [[ -f "$GITHUB_OUTPUT" ]]; then
        cat "$GITHUB_OUTPUT"
    fi
}

# Read GitHub step summary
read_github_summary() {
    if [[ -f "$GITHUB_STEP_SUMMARY" ]]; then
        cat "$GITHUB_STEP_SUMMARY"
    fi
}