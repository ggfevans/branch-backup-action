#!/bin/bash

# main.sh - Main orchestrator for branch backup action
# This script coordinates the entire backup workflow

set -Eeuo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all library functions
# shellcheck source=lib/inputs.sh
source "$SCRIPT_DIR/lib/inputs.sh"
# shellcheck source=lib/branch.sh
source "$SCRIPT_DIR/lib/branch.sh"
# shellcheck source=lib/git_ops.sh
source "$SCRIPT_DIR/lib/git_ops.sh"
# shellcheck source=lib/meta.sh
source "$SCRIPT_DIR/lib/meta.sh"
# shellcheck source=lib/io.sh
source "$SCRIPT_DIR/lib/io.sh"

main() {
    local backup_branch backup_date commit_sha backup_status tag_message
    
    # Parse and validate inputs
    parse_inputs
    
    # Get backup date (respects BBA_DATE_OVERRIDE for testing)
    backup_date=$(get_backup_date)
    
    # Generate backup branch name
    backup_branch=$(generate_backup_branch_name "$BRANCH_TO_BACKUP" "$BACKUP_PREFIX" "$backup_date")
    
    # Get current commit SHA before any operations
    commit_sha=$(get_current_commit_sha)
    
    # Check if backup branch already exists
    if backup_branch_exists "$backup_branch"; then
        backup_status="skipped"
        log_message "skip" "Backup branch $backup_branch already exists"
        
        # Write outputs and summary for skipped case
        write_backup_outputs "$backup_branch" "$backup_status" "$commit_sha" "$backup_date"
        generate_backup_summary "$backup_status" "$backup_branch" "$commit_sha" "$backup_date" "$BRANCH_TO_BACKUP"
        
        exit 0
    fi
    
    # Create backup branch and push to remote
    create_backup_branch "$backup_branch"
    backup_status="created"
    
    log_message "success" "Successfully created backup branch: $backup_branch"
    
    # Gather statistics and create tag with metadata
    gather_backup_statistics
    tag_message=$(generate_tag_message "$backup_date" "$BRANCH_TO_BACKUP" "$commit_sha")
    create_backup_tag "$backup_branch" "$tag_message"
    
    log_message "success" "Created backup tag with metadata"
    
    # Write outputs and summary
    write_backup_outputs "$backup_branch" "$backup_status" "$commit_sha" "$backup_date"
    generate_backup_summary "$backup_status" "$backup_branch" "$commit_sha" "$backup_date" "$BRANCH_TO_BACKUP"
}

# Handle errors and cleanup
handle_error() {
    local exit_code=$?
    log_message "error" "Backup failed with exit code $exit_code"
    
    # Set failed status in outputs if possible
    if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
        set_output "status" "failed"
    fi
    
    exit $exit_code
}

# Set error trap
trap handle_error ERR

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi