#!/bin/bash

# meta.sh - Metadata gathering and statistics calculation
# This library handles collecting backup metadata and statistics

set -Eeuo pipefail

# Gather statistics for the last 7 days
gather_backup_statistics() {
    local commits_this_week
    local contributors
    local files_changed

    # Get commits in the last 7 days
    commits_this_week=$(git log --since='7 days ago' --oneline | wc -l)
    
    # Get unique contributors in the last 7 days  
    contributors=$(git log --since='7 days ago' --format='%an' | sort -u | wc -l)
    
    # Get files changed (with error handling for edge cases)
    files_changed=$(git diff --name-only "HEAD~${commits_this_week}..HEAD" 2>/dev/null | wc -l || echo "0")

    # Export for use by other functions
    export COMMITS_THIS_WEEK="$commits_this_week"
    export CONTRIBUTORS="$contributors" 
    export FILES_CHANGED="$files_changed"
}

# Generate tag message with metadata
# Args: backup_date source_branch commit_sha
generate_tag_message() {
    local backup_date="$1"
    local source_branch="$2"
    local commit_sha="$3"
    
    # Ensure statistics are gathered
    if [[ -z "${COMMITS_THIS_WEEK:-}" ]]; then
        gather_backup_statistics
    fi

    cat <<EOF
Weekly Backup - $backup_date

Repository: ${GITHUB_REPOSITORY:-unknown}
Source Branch: $source_branch
Commit: $commit_sha
Workflow Run: ${GITHUB_RUN_ID:-unknown}

Statistics (last 7 days):
- Commits: $COMMITS_THIS_WEEK
- Contributors: $CONTRIBUTORS
- Files Changed: $FILES_CHANGED
EOF
}