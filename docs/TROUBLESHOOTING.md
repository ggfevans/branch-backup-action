# Troubleshooting

Comprehensive troubleshooting guide for the Weekly GitHub Branch Backup action.

## Common Issues

### Workflow Not Running

#### Actions Disabled
**Symptoms**: Workflow doesn't appear in Actions tab or never triggers
**Solution**:
1. Go to `Settings → Actions → General`
2. Ensure "Allow all actions and reusable workflows" is selected
3. Check that Actions are enabled for your repository

#### Schedule Issues
**Symptoms**: Workflow exists but doesn't run on schedule
**Possible causes**:
- Invalid cron expression
- GitHub Actions delays during high load (can be 15+ minutes late)
- Repository has been inactive for 60+ days (GitHub pauses scheduled workflows)

**Solutions**:
```bash
# Test cron expression at https://crontab.guru/
# Example: '0 0 * * 0' = Every Sunday at midnight UTC

# Force run to check if workflow is working:
# Go to Actions → Weekly Main Branch Backup → Run workflow
```

#### Workflow File Location
**Symptoms**: Workflow doesn't appear at all
**Check**: Ensure file is in exact location `.github/workflows/weekly-backup.yml`

### Permission Errors

#### Permission Denied: Create Branch
**Error**: `Permission denied (publickey)` or `403 Forbidden`
**Causes**: 
- Insufficient token permissions
- Branch protection rules blocking the action
- Organization security policies

**Solutions**:
1. **Check workflow permissions**:
   ```yaml
   permissions:
     contents: write    # Required for branches/tags
     issues: write      # Required for failure notifications
   ```

2. **Branch protection bypass**:
   ```yaml
   # Option 1: Use admin token
   - uses: actions/checkout@08c6903cd8c0fde910a37f88322edcfb5dd907a8 # v5
     with:
       token: ${{ secrets.ADMIN_TOKEN }}
   
   # Option 2: Exclude backup branches from protection
   # Go to Settings → Branches → Edit rule → Exclude *-backup-*
   ```

3. **Organization policies**:
   - Contact admin to allow Actions to create branches
   - Check if organization restricts GITHUB_TOKEN usage

#### Permission Denied: Create Issues
**Error**: Failure notification step fails
**Solution**: Ensure `issues: write` permission is granted

### Backup Creation Failures

#### Branch Already Exists
**Behavior**: Workflow skips with "Backup branch already exists"
**Expected**: This is normal behavior - prevents duplicate backups
**Check**: Look for branch named `{branch}-backup-YYYY-MM-DD` in repository

#### Git Configuration Errors
**Error**: `Author identity unknown` or similar Git errors
**Cause**: Git user configuration issues
**Solution**: The workflow already configures this, but if issues persist:
```yaml
- name: Configure Git
  run: |
    git config --global user.name "github-actions[bot]"
    git config --global user.email "github-actions[bot]@users.noreply.github.com"
    git config --global init.defaultBranch main
```

#### Tag Creation Fails
**Error**: `fatal: tag '{branch}-backup-YYYY-MM-DD' already exists`
**Cause**: Tag exists but branch doesn't (unusual state)
**Manual fix**:
```bash
# Delete the orphaned tag
git push origin --delete refs/tags/main-backup-2024-01-01
```

### Repository Size Issues

#### Approaching Size Limits
**Warning signs**:
- Slow git operations
- Push failures
- GitHub storage warnings

**Immediate actions**:
1. Check repository size: `Settings → Storage`
2. Run cleanup scripts (see [Storage Management](STORAGE.md))
3. Consider archiving old backups

#### Large Repository Performance
**Symptoms**: Workflow times out or runs very slowly
**Optimizations**:
```yaml
# Reduce fetch depth if full history isn't needed
- uses: actions/checkout@08c6903cd8c0fde910a37f88322edcfb5dd907a8 # v5
  with:
    fetch-depth: 100  # Instead of 0 (full history)
```

### Network and Connectivity Issues

#### Timeout Errors
**Symptoms**: Workflow fails with timeout
**Common timeouts**:
- Checkout step: Large repository
- Push step: Network issues
- Git operations: Repository size

**Solutions**:
```yaml
# Increase timeout for specific steps
- name: Push backup branch
  timeout-minutes: 10
  run: git push origin "${BACKUP_BRANCH}"
```

#### Authentication Issues
**Error**: `fatal: Authentication failed`
**Debug steps**:
1. Check if `GITHUB_TOKEN` is available:
   ```yaml
   - name: Debug token
     run: |
       if [ -z "$GITHUB_TOKEN" ]; then
         echo "❌ GITHUB_TOKEN is not set"
       else
         echo "✅ GITHUB_TOKEN is available"
       fi
     env:
       GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
   ```

2. Verify repository permissions in workflow

### Metadata and Statistics Issues

#### Incorrect Commit Count
**Symptoms**: Tag metadata shows wrong number of commits
**Cause**: Date calculation or git log issues
**Debug**:
```bash
# Test locally
git log --since='7 days ago' --oneline | wc -l
```

#### Missing Contributors
**Symptoms**: Contributors count is 0 or incorrect
**Debug**:
```bash
# Test locally  
git log --since='7 days ago' --format='%an' | sort -u | wc -l
```

### Issue Creation Failures

#### Issues Not Created on Failure
**Possible causes**:
- Missing `issues: write` permission
- Issue template conflicts
- API rate limits

**Debug**:
```yaml
- name: Debug issue creation
  if: failure()
  run: |
    echo "Repository: ${{ github.repository }}"
    echo "Run ID: ${{ github.run_id }}"
    echo "Actor: ${{ github.actor }}"
```

## Advanced Debugging

### Enable Debug Logging
Add to workflow:
```yaml
env:
  ACTIONS_RUNNER_DEBUG: true
  ACTIONS_STEP_DEBUG: true
```

### Workflow Run Analysis
1. Go to Actions tab
2. Click on failed workflow run
3. Expand each step to see detailed logs
4. Look for the first error message

### Local Testing with Act
```bash
# Install act (GitHub Actions local runner)
# Windows: scoop install act
# macOS: brew install act
# Linux: curl -s https://get.act.io | bash

# List workflows
act -l

# Run workflow locally (dry run)
act -n workflow_dispatch

# Run with custom event
act workflow_dispatch -e event.json
```

### Common Error Patterns

#### Pattern: `pathspec 'backup-YYYY-MM-DD' did not match any file(s)`
**Meaning**: Branch creation succeeded but checkout failed
**Fix**: This usually resolves itself on next run

#### Pattern: `Updates were rejected because the tip of your current branch is behind`
**Meaning**: Race condition or concurrent workflow runs
**Fix**: Ensure only one backup workflow runs at a time

#### Pattern: `fatal: couldn't find remote ref refs/heads/backup-*`  
**Meaning**: Branch was created locally but push failed
**Debug**: Check network connectivity and permissions

## Getting Help

### Information to Collect
When reporting issues, include:

1. **Workflow run URL**
2. **Complete error message** from logs
3. **Repository details**:
   - Size (approximate)
   - Visibility (public/private)
   - Branch protection rules
   - GitHub plan (Free/Pro/Enterprise)

4. **Environment**:
   - When did it last work?
   - Recent changes to repository settings?
   - Organization policies?

### Quick Health Check
Run this in your repository:
```bash
# Repository info
echo "Repository size:"
du -sh .git 2>/dev/null || echo "Cannot determine size"

echo -e "\nBackup branches:"
git branch -r | grep backup- | wc -l

echo -e "\nRecent workflow runs:"
gh run list --workflow=weekly-backup.yml --limit=5 2>/dev/null || echo "gh CLI not available"

echo -e "\nGit configuration:"
git config user.name
git config user.email
```

### Self-Service Diagnostics
```yaml
# Add this step to your workflow for debugging
- name: Self-diagnostics
  if: always()
  run: |
    echo "=== Diagnostics ==="
    echo "Repository: ${{ github.repository }}"
    echo "Branch: ${{ github.ref }}"
    echo "Event: ${{ github.event_name }}"
    echo "Actor: ${{ github.actor }}"
    echo "Workspace: $GITHUB_WORKSPACE"
    
    echo -e "\n=== Git Status ==="
    git status
    
    echo -e "\n=== Remote Branches ==="
    git branch -r | head -10
    
    echo -e "\n=== Recent Commits ==="
    git log --oneline -5
```

### When to Fork vs. Report Issues
**Report an issue when**:
- Clear bug in the action logic  
- Documentation is incorrect
- Security concern

**Consider forking when**:
- Need different default behavior
- Want additional features beyond scope
- Need faster response than available support

Remember: This is a personal project shared as-is with limited support. The community and forks are encouraged for extending functionality.