#!/usr/bin/env bats

# action_e2e.bats - End-to-end integration tests for action.yml
# Tests the complete action workflow without modifying the existing action

# Load test helpers
load "../helpers/load"

setup() {
    # Setup test environment
    setup_github_env
    setup_test_date "2024-01-02"
    
    # Create a test repository for the action to run in
    TEST_REPO=$(create_test_repo "$BATS_TEST_TMPDIR/test-repo")
    REMOTE_REPO=$(setup_fake_remote "$BATS_TEST_TMPDIR/remote.git" "$TEST_REPO")
    
    # Set GitHub Actions environment to point to our test repo
    export GITHUB_WORKSPACE="$TEST_REPO"
    
    cd "$TEST_REPO"
    
    # Create initial commit and push
    create_test_commit "Initial commit" "README.md" "# Test Repository"
    push_to_remote "main"
}

teardown() {
    cleanup_github_env
}

# Helper to run action steps manually (simulating what GitHub Actions does)
run_action_steps() {
    local branch_to_backup="${1:-main}"
    local backup_prefix="${2:-backup}"
    
    # Step 1: Checkout (simulated - we're already in the repo)
    git checkout "$branch_to_backup"
    
    # Step 2: Configure Git (local to test repo)
    git config --local user.name "github-actions[bot]"
    git config --local user.email "github-actions[bot]@users.noreply.github.com"
    
    # Step 3: Create backup branch (extracted from action.yml)
    export BACKUP_DATE
    if [[ -n "${BBA_DATE_OVERRIDE:-}" ]]; then
        BACKUP_DATE="$BBA_DATE_OVERRIDE"
    else
        BACKUP_DATE=$(date -u +"%Y-%m-%d")
    fi
    
    # Sanitize branch name for use in backup branch name (replace / with -)
    SOURCE_BRANCH_CLEAN=$(echo "$branch_to_backup" | sed 's/\//-/g')
    BACKUP_BRANCH="${SOURCE_BRANCH_CLEAN}-${backup_prefix}-${BACKUP_DATE}"
    COMMIT_SHA=$(git rev-parse HEAD)
    
    echo "branch=${BACKUP_BRANCH}" >> "$GITHUB_OUTPUT"
    echo "commit=${COMMIT_SHA}" >> "$GITHUB_OUTPUT"
    echo "date=${BACKUP_DATE}" >> "$GITHUB_OUTPUT"
    
    # Check if backup branch already exists
    if git ls-remote --heads origin "${BACKUP_BRANCH}" | grep -q "${BACKUP_BRANCH}"; then
        echo "status=skipped" >> "$GITHUB_OUTPUT"
        echo "⏭️ Backup branch ${BACKUP_BRANCH} already exists"
        return 0
    fi
    
    # Create and push backup branch
    git checkout -b "${BACKUP_BRANCH}"
    git push origin "${BACKUP_BRANCH}"
    
    echo "status=created" >> "$GITHUB_OUTPUT"
    echo "✅ Successfully created backup branch: ${BACKUP_BRANCH}"
    
    # Step 4: Create backup tag (if status is created)
    local status
    status=$(grep "^status=" "$GITHUB_OUTPUT" | tail -1 | cut -d= -f2)
    
    if [[ "$status" == "created" ]]; then
        TAG_NAME="$BACKUP_BRANCH"
        
        # Gather metadata
        COMMITS_THIS_WEEK=$(git log --since='7 days ago' --oneline | wc -l)
        CONTRIBUTORS=$(git log --since='7 days ago' --format='%an' | sort -u | wc -l)
        FILES_CHANGED=$(git diff --name-only "HEAD~${COMMITS_THIS_WEEK}..HEAD" 2>/dev/null | wc -l || echo "0")
        
        # Create annotated tag
        git tag -a "${TAG_NAME}" -m "Weekly Backup - ${BACKUP_DATE}

Repository: ${GITHUB_REPOSITORY:-unknown}
Source Branch: ${branch_to_backup}
Commit: ${COMMIT_SHA}
Workflow Run: ${GITHUB_RUN_ID:-unknown}

Statistics (last 7 days):
- Commits: ${COMMITS_THIS_WEEK}
- Contributors: ${CONTRIBUTORS}
- Files Changed: ${FILES_CHANGED}
"
        
        git push origin "refs/tags/${TAG_NAME}"
        echo "✅ Created backup tag with metadata"
    fi
    
    # Step 5: Create backup summary (always runs)
    STATUS=$(grep "^status=" "$GITHUB_OUTPUT" | tail -1 | cut -d= -f2)
    BACKUP_BRANCH_OUT=$(grep "^branch=" "$GITHUB_OUTPUT" | tail -1 | cut -d= -f2)
    COMMIT_SHA_OUT=$(grep "^commit=" "$GITHUB_OUTPUT" | tail -1 | cut -d= -f2)
    
    echo "## Weekly Backup Report" >> "$GITHUB_STEP_SUMMARY"
    echo "" >> "$GITHUB_STEP_SUMMARY"
    
    if [ "$STATUS" == "created" ]; then
        echo "### ✅ Backup Created Successfully" >> "$GITHUB_STEP_SUMMARY"
    elif [ "$STATUS" == "skipped" ]; then
        echo "### ⏭️ Backup Already Exists" >> "$GITHUB_STEP_SUMMARY"
    else
        echo "### ❌ Backup Failed" >> "$GITHUB_STEP_SUMMARY"
    fi
    
    echo "" >> "$GITHUB_STEP_SUMMARY"
    echo "**Details:**" >> "$GITHUB_STEP_SUMMARY"
    echo "- Date: \`${BACKUP_DATE}\`" >> "$GITHUB_STEP_SUMMARY"
    echo "- Branch: \`${BACKUP_BRANCH_OUT}\`" >> "$GITHUB_STEP_SUMMARY"
    echo "- Commit: \`${COMMIT_SHA_OUT}\`" >> "$GITHUB_STEP_SUMMARY"
    echo "- Source: \`${branch_to_backup}\`" >> "$GITHUB_STEP_SUMMARY"
    echo "" >> "$GITHUB_STEP_SUMMARY"
    echo "[View Backup Branch](https://github.com/${GITHUB_REPOSITORY:-unknown}/tree/${BACKUP_BRANCH_OUT})" >> "$GITHUB_STEP_SUMMARY"
}

@test "action: creates backup branch successfully with default inputs" {
    # Set BBA_DATE_OVERRIDE for deterministic testing
    export BBA_DATE_OVERRIDE="2024-01-02"
    
    run run_action_steps "main" "backup"
    
    assert_success
    
    # Verify outputs were written correctly
    assert_github_output "branch" "main-backup-2024-01-02"
    assert_github_output "status" "created"
    assert_github_output_exists "commit"
    assert_github_output "date" "2024-01-02"
    
    # Verify backup branch exists locally and remotely
    assert_branch_exists "main-backup-2024-01-02"
    assert_remote_branch_exists "main-backup-2024-01-02"
    
    # Verify tag was created
    assert_annotated_tag_exists "main-backup-2024-01-02"
    assert_tag_message_contains "main-backup-2024-01-02" "Weekly Backup - 2024-01-02"
    
    # Verify summary was generated
    assert_summary_contains "## Weekly Backup Report"
    assert_summary_contains "### ✅ Backup Created Successfully"
    assert_summary_contains "main-backup-2024-01-02"
}

@test "action: skips creation when backup branch already exists" {
    export BBA_DATE_OVERRIDE="2024-01-02"
    
    # First run - should create
    run_action_steps "main" "backup"
    
    # Clear outputs for second run
    > "$GITHUB_OUTPUT"
    > "$GITHUB_STEP_SUMMARY"
    
    # Second run - should skip
    run run_action_steps "main" "backup"
    
    assert_success
    assert_output --partial "already exists"
    
    # Verify outputs show skipped status
    assert_github_output "status" "skipped"
    assert_summary_contains "### ⏭️ Backup Already Exists"
}

@test "action: handles custom backup prefix" {
    export BBA_DATE_OVERRIDE="2024-01-02"
    
    run run_action_steps "main" "snapshot"
    
    assert_success
    assert_github_output "branch" "main-snapshot-2024-01-02"
    assert_remote_branch_exists "main-snapshot-2024-01-02"
}

@test "action: handles branch names with slashes" {
    export BBA_DATE_OVERRIDE="2024-01-02"
    
    # Create a feature branch
    git checkout -b "feature/awesome-feature"
    create_test_commit "Feature commit" "feature.txt" "new feature"
    push_to_remote "feature/awesome-feature"
    
    run run_action_steps "feature/awesome-feature" "backup"
    
    assert_success
    
    # Should sanitize slashes to dashes
    assert_github_output "branch" "feature-awesome-feature-backup-2024-01-02"
    assert_remote_branch_exists "feature-awesome-feature-backup-2024-01-02"
}

@test "action: creates tag with correct metadata" {
    export BBA_DATE_OVERRIDE="2024-01-02"
    
    # Add some commits for metadata
    create_test_commit "Second commit" "file2.txt" "content 2"
    create_test_commit "Third commit" "file3.txt" "content 3"
    push_to_remote "main"
    
    run run_action_steps "main" "backup"
    
    assert_success
    
    # Verify tag contains expected metadata
    assert_tag_message_contains "main-backup-2024-01-02" "Repository: ${GITHUB_REPOSITORY:-unknown}"
    assert_tag_message_contains "main-backup-2024-01-02" "Source Branch: main"
    assert_tag_message_contains "main-backup-2024-01-02" "Statistics (last 7 days):"
}

@test "action: generates summary with all required sections" {
    export BBA_DATE_OVERRIDE="2024-01-02"
    
    run run_action_steps "main" "backup"
    
    assert_success
    
    # Verify summary structure
    assert_summary_contains "## Weekly Backup Report"
    assert_summary_contains "### ✅ Backup Created Successfully"
    assert_summary_contains "**Details:**"
    assert_summary_contains "- Date: \`2024-01-02\`"
    assert_summary_contains "- Branch: \`main-backup-2024-01-02\`"
    assert_summary_contains "- Source: \`main\`"
    assert_summary_contains "[View Backup Branch]"
}

@test "action: handles empty repository gracefully" {
    # Test with a repo that has no commits
    local empty_repo
    empty_repo=$(create_test_repo "$BATS_TEST_TMPDIR/empty-repo")
    setup_fake_remote "$BATS_TEST_TMPDIR/empty-remote.git" "$empty_repo"
    
    cd "$empty_repo"
    export GITHUB_WORKSPACE="$empty_repo"
    export BBA_DATE_OVERRIDE="2024-01-02"
    
    # This should fail gracefully since there's no HEAD to backup
    run run_action_steps "main" "backup"
    
    # We expect this to fail, but not crash
    assert_failure
}

@test "action: respects git configuration" {
    export BBA_DATE_OVERRIDE="2024-01-02"
    
    run run_action_steps "main" "backup"
    
    assert_success
    
    # Verify git was configured correctly
    local git_user
    local git_email
    git_user=$(git config user.name)
    git_email=$(git config user.email)
    
    assert_equal "$git_user" "github-actions[bot]"
    assert_equal "$git_email" "github-actions[bot]@users.noreply.github.com"
}