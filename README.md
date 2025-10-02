# Weekly GitHub Branch Backup

[![GitHub](https://img.shields.io/github/license/ggfevans/branch-backup-action)]([LICENSE](https://github.com/ggfevans/branch-backup-action/blob/main/LICENSE))
[![GitHub release](https://img.shields.io/github/v/release/ggfevans/branch-backup-action)](https://github.com/ggfevans/branch-backup-action/releases)
[![GitHub issues](https://img.shields.io/github/issues/ggfevans/branch-backup-action)](https://github.com/ggfevans/branch-backup-action/issues)

Automatically create weekly snapshot branches with rich metadata and failure notifications.

**Originally created for Obsidian vaults synced via Git, but works with any repository where you want periodic branch snapshots.**

> **Provided as-is:** This workflow works well for my needs, but I'm sharing it without warranty or guaranteed support. Feel free to fork and modify as needed.

## Features

- **Automatic weekly backups** every Sunday at midnight UTC
- **Annotated Git tags** with commit statistics (commits, contributors, files changed)
- **Automatic issue creation** on workflow failures
- **Detailed workflow summaries** in Actions tab
- **Indefinite retention** (no automatic cleanup)
- **Manual trigger** support via workflow dispatch
- **Configurable** via environment variables

## Quick Start

### Option 1: GitHub Action (Recommended)

Add this workflow file to your repository:

```yaml
# .github/workflows/backup.yml
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
        with:
          backup-prefix: 'backup'        # Optional: customize branch prefix
          branch-to-backup: 'main'       # Optional: change source branch
```

### Option 2: Use This Template

Click **"Use this template"** to create a repository with the workflow pre-configured.

The workflow runs automatically every Sunday at 00:00 UTC and can be triggered manually from the Actions tab.

## Obsidian Users

This action was specifically designed for Obsidian vaults synced via Git:

**Why weekly backups?**
- Protection against accidental bulk deletions or edits
- Recovery point before major vault reorganizations  
- Insurance against sync conflicts across devices
- Snapshot of vault state before plugin updates

**Quick setup:**
1. Ensure your vault is syncing to GitHub
2. Add the workflow above to your vault's repository
3. Weekly snapshots run automatically

**Recovery:**
```bash
git checkout backup-2025-09-29  # Review your vault
git checkout main               # Return to current state
```

## Configuration

**Default behavior:**
- Backs up the `main` branch
- Creates branches named `backup-YYYY-MM-DD`
- Creates annotated tags with metadata
- Skips if backup already exists for that date
- Creates GitHub issue on workflow failures

**Customize the action:**
```yaml
- uses: ggfevans/branch-backup-action@v0.1
  with:
    backup-prefix: 'snapshot'     # Custom prefix
    branch-to-backup: 'develop'   # Different source branch
```

**Change schedule:**
```yaml
on:
  schedule:
    - cron: '0 0 * * 1'  # Every Monday instead of Sunday
```
Use [crontab.guru](https://crontab.guru/) for custom schedules.

**Manual trigger:** Go to Actions → Your Backup Workflow → Run workflow

## Monitoring

**View backups:** All backups appear as branches (`backup-YYYY-MM-DD`) and tags with metadata

**Workflow summaries:** Each run shows status, date, and links in the Actions tab

**Failure notifications:** Failed workflows automatically create GitHub issues with details

## Storage

**Important:** This workflow preserves all backups indefinitely.

Monitor repository size at `Settings → Storage`. GitHub provides 1GB free storage.

**Manual cleanup:**
```bash
# Delete old backup
git push origin --delete backup-2025-01-01
git push origin --delete refs/tags/backup-2025-01-01
```

See [Storage Management](docs/STORAGE.md) for bulk cleanup scripts.

## Troubleshooting

**Workflow not running?**
- Enable Actions: `Settings → Actions → General`
- Verify cron expression at [crontab.guru](https://crontab.guru/)
- Note: GitHub Actions may have 15+ minute delays

**Permission errors?**
- Ensure workflow has `contents: write` and `issues: write` permissions
- Check branch protection rules don't block backup branches

See [Troubleshooting Guide](docs/TROUBLESHOOTING.md) for detailed help.

## Documentation

- **[Setup Guide](docs/SETUP_GUIDE.md)** - Quick setup instructions
- **[Advanced Configuration](docs/ADVANCED.md)** - Multiple branches, custom schedules, integrations
- **[Storage Management](docs/STORAGE.md)** - Cleanup scripts and retention strategies  
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Comprehensive problem-solving guide
- **[Manual Cleanup](docs/manual-cleanup.md)** - Scripts for bulk backup deletion

## Contributing

This is a personal project shared as-is. While I'm happy to review pull requests:

- **Response times vary** - This is a side project  
- **Forks encouraged** - Feel free to create your own version
- **Limited feature scope** - The workflow meets my current needs

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**A personal tool shared with the community.** Originally built for my Obsidian vault, now available for anyone who finds it useful. No warranty or guaranteed support, but hopefully helpful!
