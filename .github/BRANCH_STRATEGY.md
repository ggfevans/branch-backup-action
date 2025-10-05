# Branch Strategy

## Summary

- **main** is the default and release branch. It is heavily protected with no direct pushes. Changes land only via pull requests with required reviews and status checks.
- **dev** is the active development branch. All feature work branches from dev and merges back into dev via pull requests.
- **Feature branches** use descriptive prefixes such as `update`, `fix`, `docs`, `chore`. Example: `update/update-branch-naming`.

## Backup and Tagging

- The weekly-backup workflow defaults to backing up **main** via `BRANCH_TO_BACKUP: 'main'`.
- The composite action input `branch-to-backup` defaults to **main**. It can be overridden for manual runs.
- Backup branches are named using the `backup-prefix` input and a date stamp. Example: `backup-YYYY-MM-DD`.
- The action creates annotated tags with commit statistics and metadata for traceability.

## Day-to-day Development Flow

1. Create feature branch from **dev**.
2. Commit work to the feature branch.
3. Open a pull request targeting **dev**.
4. Ensure required checks pass. Merge into **dev**.

## Release Flow

1. Cut a release pull request from **dev** to **main**.
2. Ensure all required checks and approvals are satisfied.
3. Merge into **main**.
4. The scheduled backup will back up **main** automatically. Manual dispatch can be used if needed.

## Branch Protections

### main
- Require pull request reviews and status checks to pass.
- Restrict who can push. Direct pushes are disabled.
- Consider enabling linear history and signed commits.

### dev
- Active development branch. Require status checks to pass.
- Pull requests required for merging changes.
- Direct pushes may be restricted according to team policy.

### Default Branch
- **main** is the repository default branch
- Workflows (like backups) run from main for stability
- GitHub shows main branch by default when viewing the repository

## Naming Conventions

- **Feature branches**: `update`, `fix`, `docs`, `chore` prefixes.
- **Backup branches**: `backup-YYYY-MM-DD`.
- **Tags**: Annotated tags with release or backup metadata.

## Example Commands

```bash
# Start a feature branch
git checkout dev && git pull --ff-only && git checkout -b update/update-branch-naming

# Push your feature
git push -u origin update/update-branch-naming

# Open a PR: target the dev branch
gh pr create -B dev

# Release PR: from dev to main with required approvals and checks
gh pr create -H dev -B main
```

## Local Testing Notes

- The composite action defaults to **main**. For ad-hoc tests, override `branch-to-backup` to a temporary branch.
- If using `act`, ensure any sample event inputs use **main** by default to match this strategy.

This strategy aligns the default backup target with the protected **main** branch while keeping **dev** as the base for active development.
