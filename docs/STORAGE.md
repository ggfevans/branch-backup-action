# Storage Management

**This action keeps all backups indefinitely.** GitHub has repository limits you should know about.

## GitHub Repository Limits
- **Recommended max**: 10GB on-disk size (.git folder)
- **Max branches**: 5,000 (this action creates one branch per week)
- **Performance**: Large repositories slow down Git operations

**Monitor**: Repository size at `Settings → Storage`

## Manual Cleanup

**Delete single backup:**
```bash
git push origin --delete backup-2024-01-01
git push origin --delete refs/tags/backup-2024-01-01
```

**Delete backups older than 90 days:**
```bash
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

**Keep only last 12 backups:**
```bash
git fetch --all
git branch -r | grep 'origin/backup-' | sort -r | tail -n +13 | while read branch; do
  git push origin --delete ${branch#origin/}
  git push origin --delete refs/tags/${branch#origin/}
done
```

**PowerShell (Windows):**
```powershell
$backups = git branch -r | Select-String 'origin/backup-'
foreach ($branch in $backups) {
    if ($branch -match '\d{4}-\d{2}-\d{2}') {
        $backupDate = [DateTime]::ParseExact($matches[0], "yyyy-MM-dd", $null)
        $daysOld = (Get-Date) - $backupDate
        
        if ($daysOld.Days -gt 90) {
            $cleanBranch = $branch.ToString().Replace('origin/', '').Trim()
            git push origin --delete $cleanBranch
            git push origin --delete "refs/tags/$cleanBranch"
        }
    }
}
```

## Automated Cleanup

**Monthly cleanup workflow** (`.github/workflows/cleanup.yml`):
```yaml
name: Cleanup Old Backups
on:
  schedule:
    - cron: '0 2 1 * *'  # Monthly
  workflow_dispatch:

jobs:
  cleanup:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v5
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
                git push origin --delete ${branch#origin/}
                git push origin --delete refs/tags/${branch#origin/}
              fi
            fi
          done
```

## Size Monitoring

**Check repository size:**
```bash
du -sh .git  # Shows .git folder size
git branch -r | grep backup- | wc -l  # Count backup branches
```

**Add to backup workflow:**
```yaml
- name: Check repository size
  run: |
    SIZE_MB=$(du -sm .git | cut -f1)
    echo "Repository size: ${SIZE_MB}MB"
    if [ $SIZE_MB -gt 9000 ]; then
      echo "::warning::Repository approaching 10GB limit"
    fi
```

## Retention Recommendations

**Conservative:** Keep 12 weekly backups (~3 months)  
**Moderate:** Keep 26 weekly backups (~6 months)  
**Aggressive:** Keep 52 weekly backups (~1 year)

**Note:** 52 branches = ~1 year of weekly backups, well under GitHub's 5,000 branch limit.

## Troubleshooting

**Emergency cleanup:**
```bash
# Delete oldest 10 backups
git branch -r | grep 'origin/backup-' | head -10 | while read branch; do
  git push origin --delete ${branch#origin/}
  git push origin --delete refs/tags/${branch#origin/}
done
```

**Check cleanup results:**
```bash
git branch -r | grep backup- | wc -l  # Count remaining
du -sh .git  # Check size
```
