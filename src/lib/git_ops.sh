#!/bin/bash

# git_ops.sh - Git operations for branch and tag creation
# This library handles git operations needed for backup

set -Eeuo pipefail

# Configure git user for GitHub Actions bot
configure_git_user() {
    git config --global user.name "github-actions[bot]"
    git config --global user.email "github-actions[bot]@users.noreply.github.com"
}

# Create backup branch and push to remote
# Args: backup_branch_name
create_backup_branch() {
    local backup_branch="$1"
    
    echo "Creating backup branch: $backup_branch"
    git checkout -b "$backup_branch"
    git push origin "$backup_branch"
}

# Get current commit SHA
get_current_commit_sha() {
    git rev-parse HEAD
}

# Create annotated tag with metadata
# Args: tag_name tag_message
create_backup_tag() {
    local tag_name="$1"
    local tag_message="$2"
    
    echo "Creating backup tag: $tag_name"
    git tag -a "$tag_name" -m "$tag_message"
    git push origin "refs/tags/$tag_name"
}