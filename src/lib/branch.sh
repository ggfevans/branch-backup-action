#!/bin/bash

# branch.sh - Branch name generation logic
# This library handles creating backup branch names

set -Eeuo pipefail

# Generate backup branch name
# Args: source_branch backup_prefix backup_date
# Returns: sanitized branch name in format {SOURCE_BRANCH_CLEAN}-{backup-prefix}-{YYYY-MM-DD}
generate_backup_branch_name() {
    local source_branch="$1"
    local backup_prefix="$2"
    local backup_date="$3"

    # Sanitize source branch name (replace / with -)
    local source_branch_clean
    source_branch_clean=$(echo "$source_branch" | sed 's/\//-/g')

    # Generate final branch name
    local backup_branch="${source_branch_clean}-${backup_prefix}-${backup_date}"

    echo "$backup_branch"
}

# Check if backup branch already exists on remote
# Args: branch_name
# Returns: 0 if exists, 1 if not
backup_branch_exists() {
    local branch_name="$1"
    
    if git ls-remote --heads origin "$branch_name" | grep -q "$branch_name"; then
        return 0
    else
        return 1
    fi
}