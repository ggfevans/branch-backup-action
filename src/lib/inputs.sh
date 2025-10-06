#!/bin/bash

# inputs.sh - Input validation and sanitization
# This library handles parsing and validating action inputs

set -Eeuo pipefail

# Parse and validate action inputs
# Sets global variables: BACKUP_PREFIX, BRANCH_TO_BACKUP, GITHUB_TOKEN
parse_inputs() {
    # Set defaults if not provided (use ${var-default} to handle empty strings)
    BACKUP_PREFIX="${INPUT_BACKUP_PREFIX-backup}"
    BRANCH_TO_BACKUP="${INPUT_BRANCH_TO_BACKUP-main}"
    GITHUB_TOKEN="${INPUT_GITHUB_TOKEN-${GITHUB_TOKEN-}}"

    # Trim whitespace (remove leading/trailing)
    BACKUP_PREFIX="$(echo "$BACKUP_PREFIX" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    BRANCH_TO_BACKUP="$(echo "$BRANCH_TO_BACKUP" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    
    # Check for spaces in backup prefix BEFORE removing them (to reject)
    if [[ "$BACKUP_PREFIX" =~ [[:space:]] ]]; then
        echo "Error: backup-prefix contains invalid characters. Only alphanumeric, dash, and underscore allowed." >&2
        return 1
    fi

    # Validate backup prefix
    if [[ -z "$BACKUP_PREFIX" ]]; then
        echo "Error: backup-prefix cannot be empty" >&2
        return 1
    fi

    # Basic validation for backup prefix (alphanumeric, dash, underscore only)
    if [[ ! "$BACKUP_PREFIX" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Error: backup-prefix contains invalid characters. Only alphanumeric, dash, and underscore allowed." >&2
        return 1
    fi

    # Validate branch name
    if [[ -z "$BRANCH_TO_BACKUP" ]]; then
        echo "Error: branch-to-backup cannot be empty" >&2
        return 1
    fi
    
    # Note: We allow any characters in branch names as git will validate them
    # The branch sanitization happens in branch.sh

    # Export for use by other functions
    export BACKUP_PREFIX BRANCH_TO_BACKUP GITHUB_TOKEN
}

# Get current date in YYYY-MM-DD format
# Respects BBA_DATE_OVERRIDE for testing
get_backup_date() {
    if [[ -n "${BBA_DATE_OVERRIDE:-}" ]]; then
        echo "$BBA_DATE_OVERRIDE"
    else
        date -u +"%Y-%m-%d"
    fi
}