#!/bin/bash

# git.bash - Git utilities helper for creating test repositories
# This file provides utilities to create temp repos, seed commits, and configure git settings

# Create a test git repository with initial setup
create_test_repo() {
    local repo_dir="${1:-$BATS_TEST_TMPDIR/test-repo}"
    local initial_branch="${2:-main}"
    
    # Ensure clean directory creation
    rm -rf "$repo_dir"
    mkdir -p "$repo_dir"
    cd "$repo_dir" || return 1
    
    # Initialize repo with consistent config
    git init --initial-branch="$initial_branch" --quiet >/dev/null 2>&1
    configure_test_git_user
    
    # Verify we're in the right place and return the path
    pwd
}

# Configure git user for testing (isolated from global config)
configure_test_git_user() {
    git config user.name "Test User"
    git config user.email "test@example.com"
    git config init.defaultBranch main
    git config core.autocrlf false
    git config commit.gpgsign false
}

# Create a commit with deterministic content and timestamp
create_test_commit() {
    local message="${1:-Test commit}"
    local file="${2:-test-file.txt}"
    local content="${3:-Test content $(date)}"
    local timestamp="${4:-2024-01-01T10:00:00}"
    
    echo "$content" > "$file"
    git add "$file"
    
    # Use consistent timestamp if provided
    if [[ -n "$timestamp" ]]; then
        GIT_COMMITTER_DATE="$timestamp" GIT_AUTHOR_DATE="$timestamp" git commit -m "$message"
    else
        git commit -m "$message"
    fi
}

# Create multiple test commits with different files
create_multiple_commits() {
    local count="${1:-3}"
    local base_date="2024-01-01T10:00:00"
    
    for ((i=1; i<=count; i++)); do
        local timestamp
        timestamp=$(date -d "$base_date + $i hours" -u +"%Y-%m-%dT%H:%M:%S" 2>/dev/null || date -v+"${i}H" -j -f "%Y-%m-%dT%H:%M:%S" "$base_date" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null || echo "$base_date")
        create_test_commit "Commit $i" "file$i.txt" "Content $i" "$timestamp"
    done
}

# Create a branch from current position
create_test_branch() {
    local branch_name="$1"
    local switch_to="${2:-false}"
    
    git branch "$branch_name"
    
    if [[ "$switch_to" == "true" ]]; then
        git checkout "$branch_name"
    fi
}

# Setup a fake remote (local bare repo)
setup_fake_remote() {
    local remote_dir="${1:-$BATS_TEST_TMPDIR/remote.git}"
    local repo_dir="${2:-$(pwd)}"
    
    # Create bare repository
    git init --bare "$remote_dir"
    
    # Add remote to current repo
    cd "$repo_dir" || return 1
    git remote add origin "$remote_dir"
    
    echo "$remote_dir"
}

# Push current branch to remote
push_to_remote() {
    local branch="${1:-$(git branch --show-current)}"
    git push origin "$branch"
}

# Check if branch exists on remote
remote_branch_exists() {
    local branch="$1"
    git ls-remote --heads origin "$branch" | grep -q "$branch"
}

# Get commit statistics for testing
get_commit_stats() {
    local since="${1:-7 days ago}"
    
    local commits
    local contributors  
    local files_changed
    
    commits=$(git log --since="$since" --oneline | wc -l)
    contributors=$(git log --since="$since" --format='%an' | sort -u | wc -l)
    
    # Handle files changed calculation safely
    if [[ "$commits" -gt 0 ]]; then
        files_changed=$(git diff --name-only "HEAD~${commits}..HEAD" 2>/dev/null | wc -l || echo "0")
    else
        files_changed=0
    fi
    
    echo "commits=$commits contributors=$contributors files_changed=$files_changed"
}

# Create a repository with history for metadata testing  
create_repo_with_history() {
    local repo_dir="${1:-$BATS_TEST_TMPDIR/history-repo}"
    
    create_test_repo "$repo_dir"
    cd "$repo_dir" || return 1
    
    # Create commits over the last week
    for i in {1..5}; do
        local days_ago=$((8-i))
        local timestamp
        timestamp=$(date -d "$days_ago days ago" -u +"%Y-%m-%dT%H:%M:%S" 2>/dev/null || date -v-"${days_ago}d" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null || echo "2024-01-0${i}T10:00:00")
        
        create_test_commit "Historical commit $i" "history$i.txt" "History content $i" "$timestamp"
    done
    
    echo "$repo_dir"
}
