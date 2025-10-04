# Branch Backup Action

[![License](https://img.shields.io/github/license/ggfevans/branch-backup-action)](LICENSE)
[![Release](https://img.shields.io/github/v/release/ggfevans/branch-backup-action)](https://github.com/ggfevans/branch-backup-action/releases)

Creates weekly Git branch snapshots with metadata. Originally built for my Obsidian vault, works with any repository.

**Personal project shared as-is.** Limited support, forks welcome.

## Usage

Add to `.github/workflows/backup.yml`:

```yaml
name: Weekly Backup
on:
  schedule:
    - cron: '0 0 * * 0'  # Every Sunday at midnight UTC
  workflow_dispatch:

jobs:
  backup:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      issues: write
    steps:
      - uses: ggfevans/branch-backup-action@v1
```

Creates branches named `{branch}-backup-YYYY-MM-DD` with annotated tags. Manual trigger available in Actions tab.

## Personal Access Token Setup

This action requires a [fine-grained personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token) with specific permissions to create branches and tags.

### Required Permissions

The token must have access to your repository with these permissions:

- **Metadata**: Read access
- **Contents**: Read and Write access
- **Pull requests**: Read and Write access  
- **Actions**: Read and Write access

### Setup Steps

1. Go to [GitHub Settings > Developer settings > Personal access tokens > Fine-grained tokens](https://github.com/settings/personal-access-tokens/new)
2. Click **Generate new token**
3. **Token name**: Enter a descriptive name (e.g., "Branch Backup Action")
4. **Expiration**: Set expiration (or "No expiration" if allowed by your organization)
5. **Resource owner**: Select the account/organization that owns your repository
6. **Repository access**: Select "Selected repositories" and choose your target repository
7. **Permissions**: Under "Repository permissions", set:
   - **Metadata**: Read
   - **Contents**: Read and write
   - **Pull requests**: Read and write
   - **Actions**: Read and write
8. Click **Generate token**
9. Copy the token immediately (you won't see it again)

### Using the Token

**Option 1 - Default (Recommended):**
Use the built-in `GITHUB_TOKEN` with proper workflow permissions (as shown in the usage example above).

**Option 2 - Custom Token:**
If you need a custom token, add it to your repository secrets and reference it:

```yaml
steps:
  - uses: ggfevans/branch-backup-action@v1
    with:
      github-token: ${{ secrets.BACKUP_TOKEN }}
```

### Security Notes

- Fine-grained tokens are more secure than classic tokens
- Only grant the minimum required permissions
- Set reasonable expiration dates
- Store tokens in repository secrets, never in code

## For Obsidian Users

Protects against accidental deletions, sync conflicts, and failed plugin updates:

```bash
git checkout main-backup-2025-09-29  # Restore from backup
git checkout main                    # Return to current
```

## Configuration

```yaml
- uses: ggfevans/branch-backup-action@v1
  with:
    backup-prefix: 'snapshot'     # Default: 'backup'
    branch-to-backup: 'develop'   # Default: 'main'
```

Change schedule:
```yaml
cron: '0 0 * * 1'  # Every Monday instead of Sunday
```

## What It Does

- Creates `{branch}-backup-YYYY-MM-DD` branches every Sunday
- Annotated tags with commit stats (commits, contributors, files changed)
- Creates GitHub issues on failure
- Keeps all backups indefinitely

## Storage

Backups accumulate over time. Clean up old ones manually:
```bash
git push origin --delete main-backup-2025-01-01
git push origin --delete refs/tags/main-backup-2025-01-01
```

Bulk cleanup scripts in [docs/STORAGE.md](docs/STORAGE.md).

## Troubleshooting

- Enable Actions in repository settings
- Ensure workflow has `contents: write` and `issues: write` permissions
- See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## License

MIT - see [LICENSE](LICENSE)
