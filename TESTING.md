# Testing Documentation

This document outlines the current behavior of the Branch Backup Action and our testing strategy.

## Current Behavior Analysis

Based on `action.yml` examination:

### Inputs
- `backup-prefix`: Optional, defaults to `"backup"`
- `branch-to-backup`: Optional, defaults to `"main"` 
- `github-token`: Optional, defaults to `${{ github.token }}`

### Outputs
- `backup-branch`: Name of the created backup branch
- `backup-status`: Status (`"created"`, `"skipped"`, or `"failed"`)
- `commit-sha`: SHA of the commit that was backed up

### Branch Naming Logic
- Format: `{SOURCE_BRANCH_CLEAN}-{backup-prefix}-{YYYY-MM-DD}`
- Source branch sanitization: Forward slashes (`/`) replaced with dashes (`-`)
- Date: UTC format `YYYY-MM-DD` from `date -u +"%Y-%m-%d"`

### Existing Branch Behavior
- **Skip if exists**: If remote branch already exists with same name, status is set to `"skipped"` and action exits successfully
- **No deduplication**: No suffix or alternative naming attempted
- **Check method**: Uses `git ls-remote --heads origin` to check existence

### Tag Creation
- **Only when created**: Tags only created when `backup-status == "created"` (not when skipped)
- **Tag name**: Same as branch name
- **Tag type**: Annotated tag with metadata
- **Metadata includes**:
  - Repository name
  - Source branch
  - Commit SHA
  - Workflow run ID
  - Statistics (commits, contributors, files changed in last 7 days)

### Summary Generation
- **Always runs**: Uses `if: always()` condition
- **Content varies by status**: Different headers for created/skipped/failed
- **Includes**: Date, branch name, commit SHA, source branch, GitHub link

### Error Handling
- **Script fails fast**: Uses `set -e`
- **No explicit failure status**: Relies on script exit codes
- **Issue creation**: Separate step in workflow creates GitHub issue on failure

## Test Strategy

### Unit Tests
- Input validation and defaults
- Branch name generation and sanitization  
- Git operations (mocked)
- Metadata calculation
- Output variable generation
- Error conditions

### Integration Tests
- End-to-end backup creation
- Multiple source branches
- Existing branch skip behavior
- Tag creation with metadata
- Summary generation
- Edge cases (empty repo, long names, etc.)

### Environment Variables for Testing
- `BBA_DATE_OVERRIDE`: Override date for deterministic tests (format: YYYY-MM-DD)
- Standard GitHub Actions variables: `GITHUB_OUTPUT`, `GITHUB_STEP_SUMMARY`, etc.

## Implementation Notes

1. **Behavior preservation**: Tests must assert current behavior, not desired behavior
2. **Skip behavior**: When branch exists remotely, action skips and exits 0
3. **No local branch cleanup**: Action doesn't clean up local branches created during process
4. **Remote-first**: Existence check is against remote, not local repository
5. **Date dependency**: Uses system date, requires override mechanism for deterministic testing