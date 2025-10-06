#!/bin/bash

# asserts.bash - Custom assertions helper for testing specific functionality
# This file provides common assertions for outputs, tags, branch existence, summary content

# Assert that a GitHub output variable exists and has expected value
assert_github_output() {
    local expected_name="$1"
    local expected_value="$2"
    
    assert [ -f "$GITHUB_OUTPUT" ]
    
    if grep -q "^${expected_name}=${expected_value}$" "$GITHUB_OUTPUT"; then
        return 0
    else
        echo "Expected GitHub output '$expected_name=$expected_value' not found"
        echo "Actual outputs:"
        cat "$GITHUB_OUTPUT"
        return 1
    fi
}

# Assert that a GitHub output variable exists (any value)
assert_github_output_exists() {
    local expected_name="$1"
    
    assert [ -f "$GITHUB_OUTPUT" ]
    
    if grep -q "^${expected_name}=" "$GITHUB_OUTPUT"; then
        return 0
    else
        echo "Expected GitHub output '$expected_name' not found"
        echo "Actual outputs:"
        cat "$GITHUB_OUTPUT"
        return 1
    fi
}

# Assert that GitHub step summary contains expected text
assert_summary_contains() {
    local expected_text="$1"
    
    assert [ -f "$GITHUB_STEP_SUMMARY" ]
    
    if grep -q "$expected_text" "$GITHUB_STEP_SUMMARY"; then
        return 0
    else
        echo "Expected summary text '$expected_text' not found"
        echo "Actual summary:"
        cat "$GITHUB_STEP_SUMMARY"
        return 1
    fi
}

# Assert that a git branch exists locally
assert_branch_exists() {
    local branch_name="$1"
    
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        return 0
    else
        echo "Expected branch '$branch_name' does not exist"
        echo "Available branches:"
        git branch
        return 1
    fi
}

# Assert that a git branch exists on remote
assert_remote_branch_exists() {
    local branch_name="$1"
    
    if git ls-remote --heads origin "$branch_name" | grep -q "$branch_name"; then
        return 0
    else
        echo "Expected remote branch '$branch_name' does not exist"
        echo "Available remote branches:"
        git ls-remote --heads origin
        return 1
    fi
}

# Assert that a git tag exists and is annotated
assert_annotated_tag_exists() {
    local tag_name="$1"
    
    # Check if tag exists
    if ! git show-ref --verify --quiet "refs/tags/$tag_name"; then
        echo "Expected tag '$tag_name' does not exist"
        echo "Available tags:"
        git tag
        return 1
    fi
    
    # Check if tag is annotated
    local tag_type
    tag_type=$(git cat-file -t "$tag_name")
    if [[ "$tag_type" != "tag" ]]; then
        echo "Expected tag '$tag_name' to be annotated, but it's a $tag_type"
        return 1
    fi
    
    return 0
}

# Assert that a tag message contains expected text
assert_tag_message_contains() {
    local tag_name="$1"
    local expected_text="$2"
    
    assert_annotated_tag_exists "$tag_name"
    
    local tag_message
    tag_message=$(git tag -l --format='%(contents)' "$tag_name")
    
    if echo "$tag_message" | grep -q "$expected_text"; then
        return 0
    else
        echo "Expected tag message to contain '$expected_text'"
        echo "Actual tag message:"
        echo "$tag_message"
        return 1
    fi
}

# Assert that output does not contain secrets
assert_no_secrets_leaked() {
    local output="$1"
    local secret_pattern="${2:-fake-token}"
    
    if echo "$output" | grep -q "$secret_pattern"; then
        echo "Secret leaked in output!"
        echo "Found pattern: $secret_pattern"
        echo "In output: $output"
        return 1
    fi
    
    return 0
}

# Assert that a file contains expected number of lines
assert_line_count() {
    local file="$1"
    local expected_count="$2"
    
    assert [ -f "$file" ]
    
    local actual_count
    actual_count=$(wc -l < "$file")
    
    if [[ "$actual_count" -eq "$expected_count" ]]; then
        return 0
    else
        echo "Expected $expected_count lines, got $actual_count"
        echo "File content:"
        cat "$file"
        return 1
    fi
}

# Assert that a directory exists and is not empty
assert_directory_not_empty() {
    local dir="$1"
    
    assert [ -d "$dir" ]
    
    if [[ -n "$(ls -A "$dir")" ]]; then
        return 0
    else
        echo "Expected directory '$dir' to not be empty"
        return 1
    fi
}

# Assert that current git commit matches expected SHA  
assert_current_commit() {
    local expected_sha="$1"
    
    local actual_sha
    actual_sha=$(git rev-parse HEAD)
    
    if [[ "$actual_sha" == "$expected_sha" ]]; then
        return 0
    else
        echo "Expected commit SHA '$expected_sha', got '$actual_sha'"
        return 1
    fi
}