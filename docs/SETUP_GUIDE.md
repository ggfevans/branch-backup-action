# Setup Guide

Quick reference for setting up the weekly backup workflow in your repository.

## Prerequisites

- A GitHub repository (public or private)
- Basic familiarity with Git and GitHub Actions
- (Optional) Obsidian vault already syncing to GitHub

## Installation Steps

### Method 1: Use as Template (Easiest)

1. Click "Use this template" button at the top of this repository
2. Create your new repository
3. Clone it locally
4. The workflow is already set up and will run automatically

### Method 2: Copy to Existing Repository

1. In your existing repository, create the directory structure:
   ```bash
   mkdir -p .github/workflows
   ```

2. Copy the workflow file:
   - Download `weekly-backup.yml` from this repository
   - Place it in `.github/workflows/` in your repository

3. Commit and push:
   ```bash
   git add .github/workflows/weekly-backup.yml
   git commit -m "Add weekly backup workflow"
   git push
   ```

4. Verify in GitHub:
   - Go to your repository's "Actions" tab
   - You should see "Weekly Main Branch Backup" listed

## Configuration

### Change the Schedule

Edit `.github/workflows/weekly-backup.yml`:

```yaml
on:
  schedule:
    - cron: '0 0 * * 0'  # Change this line
```

**Common schedules:**
- Daily: `'0 0 * * *'`
- Every Monday: `'0 0 * * 1'`
- First of month: `'0 0 1 * *'`
- Twice weekly (Sun & Wed): `'0 0 * * 0,3'`

### Change Branch or Naming

Edit the environment variables in the workflow:

```yaml
env:
  BACKUP_PREFIX: 'backup'      # Change prefix
  BRANCH_TO_BACKUP: 'main'     # Change source branch
```

## Verification

### Test the Workflow

1. Go to **Actions** tab in GitHub
2. Select "Weekly Main Branch Backup"
3. Click "Run workflow" dropdown
4. Click "Run workflow" button
5. Wait for completion (usually < 30 seconds)

### Check the Backup

After running:
1. Go to your repository's main page
2. Click the branch dropdown
3. Look for `backup-YYYY-MM-DD` branch
4. Go to "Tags" to see annotated tag with metadata

## For Obsidian Users

### Additional Setup

1. **Ensure .obsidian folder is tracked:**
   ```bash
   git add .obsidian
   git commit -m "Track Obsidian config"
   ```

2. **Consider excluding certain files** in `.gitignore`:
   ```
   .obsidian/workspace.json
   .obsidian/workspace-mobile.json
   ```
   (These change frequently and don't need backup)

3. **Set appropriate schedule:**
   - Weekly is good for most vaults
   - Consider daily if you make many changes

### Recovery from Backup

If you need to restore from a backup:

```bash
# View available backups
git fetch --all
git branch -r | grep backup

# Checkout a specific backup
git checkout backup-2025-09-29

# Copy files you need, then return to main
git checkout main
```

## Troubleshooting

### Workflow not appearing?

- Ensure Actions are enabled: Settings → Actions → General
- Check workflow file is in `.github/workflows/` (exact path)
- Verify YAML syntax is correct

### Permission errors?

- The workflow uses `GITHUB_TOKEN` automatically
- No additional setup needed
- Check branch protection rules if present

### Backups not creating?

- Check the Actions tab for error messages
- Verify the source branch exists (default: `main`)
- Check you haven't hit storage limits

## Next Steps

1. ✅ Install the workflow
2. ✅ Run a test backup manually
3. ✅ Verify the backup branch was created
4. ✅ Review the workflow summary
5. ✅ Wait for automatic weekly backup

## Getting Help

- Check [Troubleshooting section in README](../README.md#troubleshooting)
- Review [Manual Cleanup guide](manual-cleanup.md)
- Open an issue (but note: limited support available)
- Fork and customize for your needs

## Storage Management

Monitor your repository size:
- Go to Settings → Storage
- GitHub provides 1GB free storage
- See [manual-cleanup.md](manual-cleanup.md) for removal scripts

**Tip:** If storage becomes an issue, consider removing old backups periodically.
