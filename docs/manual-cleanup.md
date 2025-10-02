# Manual Backup Cleanup

This workflow preserves all backups indefinitely. Use these scripts to manually remove old backups.

## Delete Single Backup

```bash
# Replace date with target backup
BACKUP_DATE="2025-01-01"

# Delete branch
git push origin --delete backup-${BACKUP_DATE}

# Delete tag
git push origin --delete refs/tags/backup-${BACKUP_DATE}
```

## Delete Multiple Backups

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

## Keep Only N Most Recent Backups

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

## Windows PowerShell Version

For Windows users who prefer PowerShell:

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

## View All Backups with Dates

```bash
# List all backup branches with creation dates
git fetch --all
git for-each-ref --sort=-creatordate --format '%(refname:short) - %(creatordate:short)' refs/remotes/origin/backup-*
```

## Safety Tips

**Before bulk deletion:**
1. Review the list of backups first
2. Test the script on a single backup
3. Ensure you have at least one recent backup preserved
4. Consider archiving important backups elsewhere first

**Verify deletions:**
```bash
# After running cleanup, verify remaining backups
git branch -r | grep 'origin/backup-' | wc -l
```
