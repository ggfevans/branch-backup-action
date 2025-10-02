# Advanced Configuration

Advanced setup options and customization for the Weekly GitHub Branch Backup action.

## Multiple Branch Backups

Create additional workflow files for different branches:

```yaml
# .github/workflows/backup-develop.yml
name: Weekly Develop Branch Backup
on:
  schedule:
    - cron: '0 0 * * 0'  # Every Sunday at midnight UTC
  workflow_dispatch:

env:
  BACKUP_PREFIX: 'dev-backup'
  BRANCH_TO_BACKUP: 'develop'

jobs:
  backup:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      issues: write
    steps:
      - uses: ggfevans/branch-backup-action@v0.1
        with:
          backup-prefix: ${{ env.BACKUP_PREFIX }}
          branch-to-backup: ${{ env.BRANCH_TO_BACKUP }}
```

## Custom Schedules

Edit the cron expression in your workflow file:

### Common Alternatives
- `'0 0 * * 1'` - Every Monday at midnight UTC
- `'0 0 1 * *'` - First day of every month
- `'0 0 * * 0,3'` - Every Sunday and Wednesday
- `'0 0 * * *'` - Daily at midnight UTC
- `'0 12 * * 1'` - Every Monday at noon UTC

Use [crontab.guru](https://crontab.guru/) to create custom schedules.

## Custom Metadata in Tags

Edit the tag creation step in your workflow to include additional information:

```yaml
- name: Create backup tag
  if: steps.backup.outputs.status == 'created'
  run: |
    TAG_NAME="${{ steps.backup.outputs.branch }}"
    
    # Custom metadata
    ENVIRONMENT="production"  # Add your custom fields
    PROJECT_VERSION=$(cat package.json | jq -r '.version' || echo "unknown")
    
    git tag -a "${TAG_NAME}" -m "Weekly Backup - ${{ steps.backup.outputs.date }}
    
    Repository: ${{ github.repository }}
    Environment: ${ENVIRONMENT}
    Project Version: ${PROJECT_VERSION}
    Source Branch: ${{ env.BRANCH_TO_BACKUP }}
    Commit: ${{ steps.backup.outputs.commit }}
    "
```

## Integration with Other Workflows

### Backup Before Deployment
```yaml
name: Deploy with Backup
on:
  push:
    branches: [main]

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - uses: ggfevans/branch-backup-action@v0.1
        with:
          backup-prefix: 'pre-deploy'
          
  deploy:
    needs: backup
    runs-on: ubuntu-latest
    steps:
      - name: Deploy application
        run: echo "Deploying..."
```

### Restore from Backup
```yaml
- name: Restore from specific backup
  run: |
    git fetch origin main-backup-2024-01-01
    git checkout main-backup-2024-01-01
    # Copy files you need, then return to main
    git checkout main
```

## Branch Protection Compatibility

If your main branch has protection rules:

1. **Option 1**: Exclude backup branches from protection
   - Go to Settings → Branches
   - Edit branch protection rule
   - Add `*-backup-*` to branch name pattern exclusions

2. **Option 2**: Use a service account with admin permissions
   ```yaml
   - uses: actions/checkout@v4
     with:
       token: ${{ secrets.ADMIN_TOKEN }}
   ```

## Repository Size Monitoring

### Automated Size Alerts
Add to your workflow:

```yaml
- name: Check repository size
  run: |
    SIZE=$(du -sh .git | cut -f1)
    echo "Repository size: $SIZE"
    
    # Alert if over 800MB (GitHub has 1GB limit)
    SIZE_MB=$(du -sm .git | cut -f1)
    if [ $SIZE_MB -gt 800 ]; then
      echo "⚠️ Repository approaching size limit!"
    fi
```

## Environment Variables

All available environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `BACKUP_PREFIX` | `backup` | Prefix for backup branch names |
| `BRANCH_TO_BACKUP` | `main` | Source branch to backup |
| `GITHUB_TOKEN` | `${{ secrets.GITHUB_TOKEN }}` | Token for GitHub API access |

## Workflow Permissions

Minimum required permissions:
```yaml
permissions:
  contents: write    # Create branches and tags
  issues: write      # Create failure notifications
```

## Action Inputs Reference

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `backup-prefix` | No | `backup` | Prefix for backup branch names |
| `branch-to-backup` | No | `main` | Branch to create backups from |
| `github-token` | No | `${{ github.token }}` | GitHub token for repository access |

## Action Outputs

| Output | Description |
|--------|-------------|
| `backup-branch` | Name of the created backup branch |
| `backup-status` | Status of backup operation (created, skipped, failed) |
| `commit-sha` | SHA of the commit that was backed up |