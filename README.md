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
      - uses: ggfevans/branch-backup-action@v0.1
```

Creates branches named `backup-YYYY-MM-DD` with annotated tags. Manual trigger available in Actions tab.

## Setup Requirements

### Personal Access Token

This workflow requires a [fine-grained personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token) with the following permissions:

**Required permissions:**
- **Repository access:** The repository you want to backup
- **Contents:** Read and Write
- **Pull requests:** Read and Write  
- **Actions:** Read and Write

**Setup steps:**
1. Go to [GitHub Settings > Developer settings > Personal access tokens > Fine-grained tokens](https://github.com/settings/personal-access-tokens/new)
2. Create a new fine-grained token
3. Select your repository under "Repository access"
4. Grant the required permissions listed above
5. Add the token to your repository secrets as `GITHUB_TOKEN` or use it in your workflow

> **Note:** Fine-grained tokens are more secure than classic tokens as they provide repository-specific access with minimal required permissions.

## For Obsidian Users

Protects against accidental deletions, sync conflicts, and failed plugin updates:

```bash
git checkout backup-2025-09-29  # Restore from backup
git checkout main               # Return to current
```

## Configuration

```yaml
- uses: ggfevans/branch-backup-action@v0.1
  with:
    backup-prefix: 'snapshot'     # Default: 'backup'
    branch-to-backup: 'develop'   # Default: 'main'
```

Change schedule:
```yaml
cron: '0 0 * * 1'  # Every Monday instead of Sunday
```

## What It Does

- Creates `backup-YYYY-MM-DD` branches every Sunday
- Annotated tags with commit stats (commits, contributors, files changed)
- Creates GitHub issues on failure
- Keeps all backups indefinitely

## Storage

Backups accumulate over time. Clean up old ones manually:
```bash
git push origin --delete backup-2025-01-01
git push origin --delete refs/tags/backup-2025-01-01
```

Bulk cleanup scripts in [docs/STORAGE.md](docs/STORAGE.md).

## Troubleshooting

- Enable Actions in repository settings
- Ensure workflow has `contents: write` and `issues: write` permissions
- See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## License

MIT - see [LICENSE](LICENSE)
