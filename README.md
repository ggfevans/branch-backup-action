# Weekly GitHub Branch Backup

Automatically create weekly snapshot branches with rich metadata and failure notifications.

[![GitHub](https://img.shields.io/github/license/ggfevans/github-weekly-backup-action)](LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/ggfevans/github-weekly-backup-action)](https://github.com/ggfevans/github-weekly-backup-action/issues)

## Origin & Disclaimer

**Original use case:** I created this workflow for my personal Obsidian vault that syncs via Git. I wanted weekly snapshots as insurance against accidental changes or sync conflicts.

**Provided as-is:** This workflow works well for my needs, but I'm sharing it without any warranty or ongoing support commitment. It may or may not fit your use case. Feel free to fork and modify as needed.

**Note:** While I originally built this for Obsidian, it works with any Git repository where you want periodic branch snapshots.

## Features

- Automatic weekly backups every Sunday at midnight UTC
- Annotated Git tags with commit statistics (commits, contributors, files changed)
- Automatic issue creation on workflow failures
- Detailed workflow run summaries
- Indefinite backup retention (no automatic cleanup)
- Manual trigger support via workflow dispatch
- Configurable via environment variables

## Quick Start

### Option 1: Use This Template (Recommended)

Click the **"Use this template"** button above to create a repository with the workflow pre-configured.

### Option 2: Manual Installation

1. Create `.github/workflows/` directory in your repository
2. Copy `weekly-backup.yml` to `.github/workflows/`
3. Commit and push

The workflow will run automatically every Sunday at 00:00 UTC.

## Using with Obsidian Vaults

This workflow was specifically designed for Obsidian vaults synced via Git:

**Why weekly backups for Obsidian?**
- Protection against accidental bulk deletions or edits
- Recovery point before major vault reorganizations
- Insurance against sync conflicts across devices
- Snapshot of vault state before plugin updates or changes

**Setup for Obsidian users:**
1. Ensure your Obsidian vault is already syncing to GitHub
2. Add this workflow to your vault's repository
3. Weekly snapshots run automatically

**Recovery from backup:**
```bash
# If you need to recover from a specific date
git checkout backup-2025-09-29
# Review your vault, copy files you need, then return to main
git checkout main
```

**Note:** The `.obsidian/` folder (with settings and plugin data) is included in backups if it's tracked in your repository.

## Default Behavior

**What it does:**
- Backs up the `main` branch
- Creates branches named `backup-YYYY-MM-DD`
- Creates annotated tags with the same name
- Skips if a backup for that date already exists
- Creates a GitHub issue if the workflow fails

**What gets backed up:**
- Complete commit history
- All files and directories
- Branch state at time of backup

## Configuration

### Change Backup Schedule

Edit the cron expression in the workflow file:

```yaml
on:
  schedule:
    - cron: '0 0 * * 0'  # Every Sunday at midnight UTC
```

Common alternatives:
- `'0 0 * * 1'` - Every Monday
- `'0 0 1 * *'` - First day of every month
- `'0 0 * * 0,3'` - Every Sunday and Wednesday

Use [crontab.guru](https://crontab.guru/) to create custom schedules.

### Customize Branch Names or Source

Edit environment variables in the workflow:

```yaml
env:
  BACKUP_PREFIX: 'backup'        # Change to 'snapshot', 'archive', etc.
  BRANCH_TO_BACKUP: 'main'       # Change to 'develop', 'production', etc.
```

### Manual Trigger

Navigate to **Actions → Weekly Main Branch Backup → Run workflow** to create a backup on demand.

## Monitoring

### Backup Branches and Tags

All backups are visible in your repository:
- **Branches:** `backup-YYYY-MM-DD`
- **Tags:** Same as branch names, with annotated metadata

### Workflow Summaries

Each run creates a summary visible in the Actions tab showing:
- Backup status (created/skipped/failed)
- Date, branch name, and commit SHA
- Link to the backup branch

### Failure Notifications

If the workflow fails, it automatically creates a GitHub issue with:
- Failure date
- Link to failed workflow run
- Labels: `automation`, `backup-failure`, `priority-high`

## Storage Considerations

**Important:** This workflow preserves all backups indefinitely.

Monitor repository size at `Settings → Storage`. GitHub provides 1GB free storage for repositories.

### Manual Cleanup

To remove old backups:

```bash
# Delete a specific backup branch
git push origin --delete backup-2025-01-01

# Delete the corresponding tag
git push origin --delete refs/tags/backup-2025-01-01
```

For bulk deletion, see [docs/manual-cleanup.md](docs/manual-cleanup.md).

## Troubleshooting

### Workflow Not Running

**Check Actions are enabled:**
1. Go to `Settings → Actions → General`
2. Ensure "Allow all actions and reusable workflows" is selected

**Verify the schedule:**
- Check the cron expression is valid
- Note: GitHub Actions may have up to 15-minute delays during high load

### Permission Errors

The workflow uses the default `GITHUB_TOKEN` which has sufficient permissions for creating branches and tags. No additional configuration is needed.

**Branch protection:** If your main branch has protection rules, ensure the workflow token has appropriate permissions or exclude backup branches from protection.

### Workflow Fails Silently

Check the Actions tab for workflow runs. Failed runs will have a red indicator and create an issue automatically.

## Advanced Usage

### Backup Multiple Branches

Create additional workflow files for different branches:

```yaml
# .github/workflows/backup-develop.yml
env:
  BACKUP_PREFIX: 'dev-backup'
  BRANCH_TO_BACKUP: 'develop'
```

### Custom Metadata

Edit the tag creation step to include additional information relevant to your workflow.

### Integration with Other Workflows

Backup branches can be referenced in other workflows:

```yaml
- name: Restore from backup
  run: |
    git fetch origin backup-2025-01-01
    git checkout backup-2025-01-01
```

## Documentation

- [Setup Guide](docs/SETUP_GUIDE.md) - Quick setup instructions
- [Manual Cleanup](docs/manual-cleanup.md) - Scripts for bulk backup deletion
- [GitHub Configuration](docs/GITHUB_CONFIG.md) - Repository setup reference

## Contributing

This is a personal project I'm sharing with the community. While I'm happy to review pull requests and consider improvements, please understand:

- **Response times may vary** - This is a side project
- **I may not implement all feature requests** - The workflow meets my needs as-is
- **Forks are encouraged** - Feel free to create your own version with different features

If you do want to contribute:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request with a clear description of the changes

For bugs or feature ideas, open an issue. I'll respond when I can.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Support

**Limited support available.** Since this is a personal tool I'm sharing as-is:

- **Issues:** You can [report bugs or request features](https://github.com/ggfevans/github-weekly-backup-action/issues), but responses may be slow or not guaranteed
- **Community support:** Other users may be able to help in the Discussions tab
- **Forks welcome:** If you need different behavior, feel free to fork and customize

**For Obsidian users:** This workflow was designed for Obsidian vaults synced via Git. It creates snapshots before potential sync conflicts or unwanted changes.

---

**A personal tool shared with the community.** Originally built for backing up my Obsidian vault, now available for anyone who finds it useful. No warranty, no guaranteed support, but hopefully helpful!
