# Branch Strategy

## Summary

- **prod** is the release branch and is heavily protected. No direct pushes. Changes land only via pull requests with required reviews and status checks.
- **dev** is the default development branch. All feature work branches from dev and merges back into dev via pull requests.
- **Feature branches** use descriptive prefixes such as `update`, `fix`, `docs`, `chore`. Example: `update/update-branch-naming`.

## Backup and Tagging

- The weekly-backup workflow defaults to backing up **prod** via `BRANCH_TO_BACKUP: 'prod'`.
- The composite action input `branch-to-backup` defaults to **prod**. It can be overridden for manual runs.
- Backup branches are named using the `backup-prefix` input and a date stamp. Example: `backup-YYYY-MM-DD`.
- The action creates annotated tags with commit statistics and metadata for traceability.

## Day-to-day Development Flow

1. Create feature branch from **dev**.
2. Commit work to the feature branch.
3. Open a pull request targeting **dev**.
4. Ensure required checks pass. Merge into **dev**.

## Release Flow

1. Cut a release pull request from **dev** to **prod**.
2. Ensure all required checks and approvals are satisfied.
3. Merge into **prod**.
4. The scheduled backup will back up **prod** automatically. Manual dispatch can be used if needed.

## Branch Protections

### prod
- Require pull request reviews and status checks to pass.
- Restrict who can push. Direct pushes are disabled.
- Consider enabling linear history and signed commits.

### dev
- Default branch. Require status checks to pass.
- Pull requests required for merging changes.
- Direct pushes may be restricted according to team policy.

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

# Release PR: from dev to prod with required approvals and checks
gh pr create -H dev -B prod
```

## Local Testing Notes

- The composite action defaults to **prod**. For ad-hoc tests, override `branch-to-backup` to a temporary branch.
- If using `act`, ensure any sample event inputs use **prod** by default to match this strategy.

This strategy aligns the default backup target with the protected **prod** branch while keeping **dev** as the base for active development.