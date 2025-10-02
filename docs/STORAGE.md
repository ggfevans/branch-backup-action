# Storage Management

Managing repository size and backup retention for the Weekly GitHub Branch Backup action.

## Storage Considerations

**Important:** This workflow preserves all backups indefinitely by default.

### GitHub Storage Limits
- **Free accounts**: 1GB total repository storage
- **Pro accounts**: 10GB total repository storage  
- **Enterprise**: Varies by plan

### Monitor Usage
Check your repository size at `Settings → Storage` in GitHub.

## Backup Retention Strategies

### 1. Manual Cleanup (Recommended)

Use the provided cleanup scripts when needed:

#### Delete Single Backup
```bash
# Replace date with target backup
BACKUP_DATE="2024-01-01"

# Delete branch
git push origin --delete backup-${BACKUP_DATE}

# Delete tag
git push origin --delete refs/tags/backup-${BACKUP_DATE}
```

#### Delete Backups Older Than N Days
```bash
# Delete all backups older than 90 days
git fetch --all
git branch -r | grep 'origin/backup-' | while read branch; do
  BRANCH_DATE=$(echo $branch | grep -oP '\d{4}-\d{2}-\d{2}')
  DAYS_OLD=$(( ($(date +%s) - $(date -d "$BRANCH_DATE" +%s)) / 86400 ))
  
  if [ $DAYS_OLD -gt 90 ]; then
    echo "Deleting $branch (${DAYS_OLD} days old)"
    git push origin --delete ${branch#origin/}
    git push origin --delete refs/tags/${branch#origin/}
  fi
done
```

#### Keep Only N Most Recent Backups
```bash
# Keep only the 12 most recent backups
KEEP=12

git fetch --all
git branch -r | grep 'origin/backup-' | sort -r | tail -n +$((KEEP + 1)) | while read branch; do
  echo "Deleting old backup: $branch"
  git push origin --delete ${branch#origin/}
  git push origin --delete refs/tags/${branch#origin/}
done
```

### 2. PowerShell Version (Windows)
```powershell
# Delete backups older than 90 days
$backups = git branch -r | Select-String 'origin/backup-'
foreach ($branch in $backups) {
    $branchName = $branch.ToString().Trim()
    if ($branchName -match '\d{4}-\d{2}-\d{2}') {
        $backupDate = [DateTime]::ParseExact($matches[0], "yyyy-MM-dd", $null)
        $daysOld = (Get-Date) - $backupDate
        
        if ($daysOld.Days -gt 90) {
            Write-Host "Deleting $branchName ($($daysOld.Days) days old)"
            $cleanBranch = $branchName.Replace('origin/', '')
            git push origin --delete $cleanBranch
            git push origin --delete "refs/tags/$cleanBranch"
        }
    }
}
```

## Automated Retention (Advanced)

### Option 1: Workflow-Based Cleanup
Create `.github/workflows/cleanup-old-backups.yml`:

```yaml
name: Cleanup Old Backups
on:
  schedule:
    - cron: '0 2 1 * *'  # First day of month at 2 AM
  workflow_dispatch:

jobs:
  cleanup:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: Delete backups older than 90 days
        run: |
          git fetch --all
          git branch -r | grep 'origin/backup-' | while read branch; do
            BRANCH_DATE=$(echo $branch | grep -oP '\d{4}-\d{2}-\d{2}')
            if [ -n "$BRANCH_DATE" ]; then
              DAYS_OLD=$(( ($(date +%s) - $(date -d "$BRANCH_DATE" +%s)) / 86400 ))
              
              if [ $DAYS_OLD -gt 90 ]; then
                echo "Deleting $branch (${DAYS_OLD} days old)"
                git push origin --delete ${branch#origin/}
                git push origin --delete refs/tags/${branch#origin/}
              fi
            fi
          done
```

### Option 2: External Service Integration
Use GitHub Actions with external storage services:

```yaml
- name: Archive old backups to external storage
  run: |
    # Upload to S3, Azure Blob, etc.
    aws s3 cp backup-archive/ s3://my-backup-bucket/ --recursive
    
    # Then delete from GitHub
    git push origin --delete backup-old-date
```

## Monitoring Repository Size

### Add Size Monitoring to Backup Workflow
```yaml
- name: Monitor repository size
  run: |
    SIZE_MB=$(du -sm .git | cut -f1)
    echo "Repository size: ${SIZE_MB}MB"
    
    if [ $SIZE_MB -gt 800 ]; then
      echo "::warning::Repository approaching size limit (${SIZE_MB}MB/1GB)"
    fi
    
    # Add to step summary
    echo "## Repository Size" >> $GITHUB_STEP_SUMMARY
    echo "Current size: ${SIZE_MB}MB" >> $GITHUB_STEP_SUMMARY
```

### Storage Usage Report
```bash
# Get detailed breakdown
echo "=== Repository Storage Breakdown ==="
echo "Total repository size:"
du -sh .git
echo ""
echo "Backup branches:"
git for-each-ref --format='%(refname:short) %(objectname)' refs/remotes/origin/backup-* | while read branch commit; do
  size=$(git rev-list --disk-usage $commit 2>/dev/null || echo "0")
  echo "$branch: ${size} bytes"
done
```

## Best Practices

### 1. Regular Monitoring
- Check repository size monthly
- Set up automated alerts at 80% capacity
- Review backup retention policy quarterly

### 2. Retention Policies
**Conservative (recommended for most users):**
- Keep 4 weekly backups (1 month)
- Keep 12 monthly backups (1 year)
- Manual cleanup as needed

**Aggressive (for high-activity repositories):**  
- Keep 2 weekly backups (2 weeks)
- Keep 6 monthly backups (6 months)
- Automated monthly cleanup

### 3. Archive Strategy
For long-term retention:
1. Export important backups to external storage
2. Delete from GitHub when approaching limits
3. Document what was archived and when

## Troubleshooting Storage Issues

### Repository Size Limit Exceeded
```bash
# Emergency cleanup - remove oldest backups
git fetch --all
git branch -r | grep 'origin/backup-' | head -5 | while read branch; do
  echo "Emergency deletion: $branch"
  git push origin --delete ${branch#origin/}
  git push origin --delete refs/tags/${branch#origin/}
done
```

### Failed Branch Deletion
If cleanup fails:
```bash
# Force delete (use carefully)
git push origin --delete backup-2024-01-01 --force

# If tag deletion fails
git push origin :refs/tags/backup-2024-01-01
```

### Verify Cleanup
```bash
# Check remaining backups
git fetch --all
echo "Remaining backup branches:"
git branch -r | grep 'origin/backup-' | wc -l

# Check repository size
du -sh .git
```