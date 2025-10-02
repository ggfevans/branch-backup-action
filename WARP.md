# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## WARP: branch-backup-action (Developer Quick Reference)

### Architecture
- Type: Composite GitHub Action (shell steps and nested actions)
- Key steps/scripts: checkout, git config, backup branch creation, tag creation with metadata, summary generation, failure issue creation
- Workflows: .github/workflows (scheduled/dispatch as defined)

### Inputs (from action.yml)
- backup-prefix (optional; default: 'backup') – Prefix for backup branch names
- branch-to-backup (optional; default: 'main') – Branch to create backups from
- github-token (optional; default: ${{ github.token }}) – GitHub token for repository access

### Essentials
- Requirements: bash/sh, git, gh CLI (optional), act (optional)
- Lint scripts: shellcheck action.yml  # install with: scoop install shellcheck (Windows) or sudo apt-get install shellcheck (Linux)
- Execute components directly (for debugging):
  - Test git commands manually: `git checkout main && git checkout -b backup-test-$(date +%Y-%m-%d)`
  - Verify tag creation: `git tag -a test-tag -m "test message" && git tag -d test-tag`

### Run locally (act)
- List workflows: act -l
- Run workflow_dispatch: act workflow_dispatch -W .github/workflows/weekly-backup.yml -e .act/event.json
  - Create .act/event.json with required inputs:
    {
      "inputs": {
        "backup-prefix": "backup",
        "branch-to-backup": "main",
        "github-token": "ghp_example_token_here"
      }
    }

### Development notes
- Action creates branches named `{backup-prefix}-YYYY-MM-DD`
- Annotated tags include commit statistics and metadata
- Automatic issue creation on workflow failures
- No build/compile step required - pure shell/composite action