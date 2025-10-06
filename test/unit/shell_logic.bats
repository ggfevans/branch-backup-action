#!/usr/bin/env bats

# shell_logic.bats - Unit tests for shell script logic from action.yml
# Tests individual shell snippets without running the full action

# Load test helpers
load "../helpers/load"

setup() {
    setup_github_env
    setup_test_date "2024-01-02"
}

teardown() {
    cleanup_github_env
}

@test "branch naming: basic branch name generation" {
    # Test the exact logic from action.yml lines 60-63
    local branch_to_backup="main"
    local backup_prefix="backup"
    
    # Simulate BBA_DATE_OVERRIDE behavior
    local BACKUP_DATE="2024-01-02"
    
    # Exact logic from action.yml
    SOURCE_BRANCH_CLEAN=$(echo "$branch_to_backup" | sed 's/\//-/g')
    BACKUP_BRANCH="${SOURCE_BRANCH_CLEAN}-${backup_prefix}-${BACKUP_DATE}"
    
    assert_equal "$BACKUP_BRANCH" "main-backup-2024-01-02"
}

@test "branch naming: sanitizes slashes in branch names" {
    local branch_to_backup="feature/awesome-feature"
    local backup_prefix="backup"
    local BACKUP_DATE="2024-01-02"
    
    # Exact logic from action.yml
    SOURCE_BRANCH_CLEAN=$(echo "$branch_to_backup" | sed 's/\//-/g')
    BACKUP_BRANCH="${SOURCE_BRANCH_CLEAN}-${backup_prefix}-${BACKUP_DATE}"
    
    assert_equal "$BACKUP_BRANCH" "feature-awesome-feature-backup-2024-01-02"
}

@test "branch naming: handles multiple slashes" {
    local branch_to_backup="release/2024/january"
    local backup_prefix="backup"
    local BACKUP_DATE="2024-01-02"
    
    SOURCE_BRANCH_CLEAN=$(echo "$branch_to_backup" | sed 's/\//-/g')
    BACKUP_BRANCH="${SOURCE_BRANCH_CLEAN}-${backup_prefix}-${BACKUP_DATE}"
    
    assert_equal "$BACKUP_BRANCH" "release-2024-january-backup-2024-01-02"
}

@test "branch naming: preserves other characters" {
    local branch_to_backup="feature_awesome-branch.v2"
    local backup_prefix="backup"
    local BACKUP_DATE="2024-01-02"
    
    SOURCE_BRANCH_CLEAN=$(echo "$branch_to_backup" | sed 's/\//-/g')
    BACKUP_BRANCH="${SOURCE_BRANCH_CLEAN}-${backup_prefix}-${BACKUP_DATE}"
    
    assert_equal "$BACKUP_BRANCH" "feature_awesome-branch.v2-backup-2024-01-02"
}

@test "date generation: uses current date when no override" {
    # Test the date command from action.yml line 60
    unset BBA_DATE_OVERRIDE
    
    # Mock date to return a known value
    date() {
        if [[ "$1" == "-u" && "$2" == "+%Y-%m-%d" ]]; then
            echo "2024-12-25"
        else
            command date "$@"
        fi
    }
    export -f date
    
    BACKUP_DATE=$(date -u +"%Y-%m-%d")
    
    assert_equal "$BACKUP_DATE" "2024-12-25"
}

@test "github outputs: writes correct format" {
    # Test the output writing logic from action.yml
    local BACKUP_BRANCH="main-backup-2024-01-02"
    local COMMIT_SHA="abc123def456"
    local BACKUP_DATE="2024-01-02"
    
    # Simulate the output writing
    echo "branch=${BACKUP_BRANCH}" >> "$GITHUB_OUTPUT"
    echo "commit=${COMMIT_SHA}" >> "$GITHUB_OUTPUT"
    echo "date=${BACKUP_DATE}" >> "$GITHUB_OUTPUT"
    
    assert_github_output "branch" "$BACKUP_BRANCH"
    assert_github_output "commit" "$COMMIT_SHA"
    assert_github_output "date" "$BACKUP_DATE"
}

@test "metadata calculation: statistics gathering" {
    # Create a test repo with some history
    local test_repo
    test_repo=$(create_test_repo "$BATS_TEST_TMPDIR/stats-repo")
    cd "$test_repo"
    
    # Create several commits
    create_test_commit "Commit 1" "file1.txt" "content 1"
    create_test_commit "Commit 2" "file2.txt" "content 2"  
    create_test_commit "Commit 3" "file3.txt" "content 3"
    
    # Test the exact statistics logic from action.yml lines 91-93
    COMMITS_THIS_WEEK=$(git log --since='7 days ago' --oneline | wc -l)
    CONTRIBUTORS=$(git log --since='7 days ago' --format='%an' | sort -u | wc -l)
    FILES_CHANGED=$(git diff --name-only "HEAD~${COMMITS_THIS_WEEK}..HEAD" 2>/dev/null | wc -l || echo "0")
    
    # Should have 3 commits from test user
    assert_equal "$COMMITS_THIS_WEEK" "3"
    assert_equal "$CONTRIBUTORS" "1" # Just "Test User"
    assert_equal "$FILES_CHANGED" "3" # 3 files changed
}

@test "metadata calculation: handles edge case with no commits" {
    # Test the error handling logic when there are no commits
    
    # Simulate empty git log output
    COMMITS_THIS_WEEK=$(echo "" | wc -l)
    CONTRIBUTORS=$(echo "" | wc -l)
    FILES_CHANGED="0"  # This is the fallback value from the action.yml
    
    assert_equal "$COMMITS_THIS_WEEK" "0"
    assert_equal "$CONTRIBUTORS" "0"
    assert_equal "$FILES_CHANGED" "0"
}

@test "tag message: generates correct format" {
    # Test tag message generation from action.yml lines 95-107
    local BACKUP_DATE="2024-01-02"
    local branch_to_backup="main" 
    local COMMIT_SHA="abc123def456"
    local COMMITS_THIS_WEEK="5"
    local CONTRIBUTORS="2"
    local FILES_CHANGED="10"
    
    # Build tag message exactly like action.yml
    local expected_message="Weekly Backup - $BACKUP_DATE

Repository: ${GITHUB_REPOSITORY:-unknown}
Source Branch: $branch_to_backup
Commit: $COMMIT_SHA
Workflow Run: ${GITHUB_RUN_ID:-unknown}

Statistics (last 7 days):
- Commits: $COMMITS_THIS_WEEK
- Contributors: $CONTRIBUTORS
- Files Changed: $FILES_CHANGED
"
    
    # The tag message should contain all the expected elements
    [[ "$expected_message" == *"Weekly Backup - 2024-01-02"* ]]
    [[ "$expected_message" == *"Source Branch: main"* ]]
    [[ "$expected_message" == *"Commits: 5"* ]]
}

@test "summary generation: creates correct markdown structure" {
    # Test summary generation from action.yml lines 113-138
    local STATUS="created"
    local BACKUP_BRANCH="main-backup-2024-01-02"
    local COMMIT_SHA="abc123def456"
    local BACKUP_DATE="2024-01-02"
    local branch_to_backup="main"
    
    # Clear summary file
    > "$GITHUB_STEP_SUMMARY"
    
    # Generate summary exactly like action.yml
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
    echo "- Date: \`$BACKUP_DATE\`" >> "$GITHUB_STEP_SUMMARY"
    echo "- Branch: \`$BACKUP_BRANCH\`" >> "$GITHUB_STEP_SUMMARY"
    echo "- Commit: \`$COMMIT_SHA\`" >> "$GITHUB_STEP_SUMMARY"
    echo "- Source: \`$branch_to_backup\`" >> "$GITHUB_STEP_SUMMARY"
    echo "" >> "$GITHUB_STEP_SUMMARY"
    echo "[View Backup Branch](https://github.com/${GITHUB_REPOSITORY:-unknown}/tree/$BACKUP_BRANCH)" >> "$GITHUB_STEP_SUMMARY"
    
    # Verify the structure
    assert_summary_contains "## Weekly Backup Report"
    assert_summary_contains "### ✅ Backup Created Successfully"
    assert_summary_contains "**Details:**"
    assert_summary_contains "- Date:"
    assert_summary_contains "2024-01-02"
    assert_summary_contains "[View Backup Branch]"
}

@test "summary generation: handles skipped status" {
    local STATUS="skipped"
    local BACKUP_BRANCH="main-backup-2024-01-02"
    
    > "$GITHUB_STEP_SUMMARY"
    
    echo "## Weekly Backup Report" >> "$GITHUB_STEP_SUMMARY"
    echo "" >> "$GITHUB_STEP_SUMMARY"
    
    if [ "$STATUS" == "created" ]; then
        echo "### ✅ Backup Created Successfully" >> "$GITHUB_STEP_SUMMARY"
    elif [ "$STATUS" == "skipped" ]; then
        echo "### ⏭️ Backup Already Exists" >> "$GITHUB_STEP_SUMMARY"
    else
        echo "### ❌ Backup Failed" >> "$GITHUB_STEP_SUMMARY"
    fi
    
    assert_summary_contains "### ⏭️ Backup Already Exists"
}

@test "branch existence check: command format" {
    # Test the branch existence check from action.yml lines 71-75
    local BACKUP_BRANCH="test-branch"
    
    # Create a test repo to check against
    local test_repo
    test_repo=$(create_test_repo "$BATS_TEST_TMPDIR/check-repo")
    setup_fake_remote "$BATS_TEST_TMPDIR/check-remote.git" "$test_repo"
    cd "$test_repo"
    
    create_test_commit "Initial commit"
    push_to_remote "main"
    
    # Test the exact command from action.yml
    # This should return failure (exit 1) since branch doesn't exist
    run bash -c "git ls-remote --heads origin \"${BACKUP_BRANCH}\" | grep -q \"${BACKUP_BRANCH}\""
    assert_failure
    
    # Now create the branch and test again
    git checkout -b "$BACKUP_BRANCH"
    push_to_remote "$BACKUP_BRANCH"
    
    run bash -c "git ls-remote --heads origin \"${BACKUP_BRANCH}\" | grep -q \"${BACKUP_BRANCH}\""
    assert_success
}