# Branch Backup Action

[![License](https://img.shields.io/github/license/ggfevans/branch-backup-action)](https://github.com/ggfevans/branch-backup-action/blob/main/LICENSE)
[![Release](https://img.shields.io/github/v/release/ggfevans/branch-backup-action)](https://github.com/ggfevans/branch-backup-action/releases)
[![Security](https://github.com/ggfevans/branch-backup-action/actions/workflows/scorecard.yml/badge.svg)](https://github.com/ggfevans/branch-backup-action/actions/workflows/scorecard.yml)

**Automatic weekly Git snapshots with metadata tracking.** Originally built for Obsidian vault backups, works with any Git repository.

## What It Does

Creates weekly backup branches with annotated tags containing commit statistics. Provides recovery points for accidental deletions, failed updates, or Git mishaps.

```
Your Repository
├── main (active branch)
├── main-backup-2025-10-01
├── main-backup-2025-10-08
└── main-backup-2025-10-15
```

**Recovery example:**
```bash
git checkout main-backup-2025-10-08  # Jump to backup
cp recovered-file.txt ../             # Extract what you need
git checkout main                     # Return to work
```

## Quick Start

To use this in your existing repo, create `.github/workflows/backup.yml`:

```yaml
name: Weekly Backup
on:
  schedule:
    - cron: '0 0 * * 0'  # Every Sunday at midnight UTC
  workflow_dispatch:      # Manual trigger option

jobs:
  backup:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      issues: write
    steps:
      - uses: ggfevans/branch-backup-action@v1
```

Done. Your repository now has automatic weekly backups.

## Versioning

**Recommended:** Pin to a specific version for reproducible builds:
```yaml
- uses: ggfevans/branch-backup-action@v1.3.0
```

**Convenience:** Use floating major version tag (auto-updated):
```yaml
- uses: ggfevans/branch-backup-action@v1
```

**Available tags:**
- `v1.3.0`, `v1.2.0`, `v1.1.0` (immutable release versions)
- `v1.3`, `v1` (floating tags, updated on each release)

## Features

- Automated weekly snapshots on schedule
- Rich metadata in annotated tags (commits, contributors, file changes)
- Failure notifications via GitHub issues
- Manual trigger support from Actions tab
- Indefinite retention (you control deletion)
- Source branch name included in backup branch

## Use Cases

**Knowledge Management**
- Obsidian, Notion, Logseq vaults
- Documentation repositories
- Note-taking systems

**Development**
- Personal projects
- Configuration files (dotfiles)
- Prototype repositories
- Small team codebases

**Content Creation**
- Writing projects
- Research notes
- Blog repositories

## Configuration

### Custom Schedule

```yaml
on:
  schedule:
    - cron: '0 0 * * 1'  # Every Monday
    # or
    - cron: '0 0 1 * *'  # Monthly on 1st
    # or  
    - cron: '0 0 * * *'  # Daily
```

### Backup Different Branch

```yaml
- uses: ggfevans/branch-backup-action@v1
  with:
    branch-to-backup: 'develop'  # Default: 'main'
    backup-prefix: 'snapshot'     # Default: 'backup'
```

### Use Custom Token

For repositories with branch protection:

```yaml
- uses: ggfevans/branch-backup-action@v1
  with:
    github-token: ${{ secrets.BACKUP_TOKEN }}
```

See [Personal Access Token Setup](docs/ADVANCED.md#personal-access-token-setup) for details.

## Storage Management

This action keeps all backups indefinitely for maximum data safety. 

GitHub supports 5,000 branches per repository. This action creates approximately 52 branches per year, well within limits.

**Optional cleanup:**
```bash
git push origin --delete main-backup-2025-01-01
git push origin --delete refs/tags/main-backup-2025-01-01
```

See [docs/STORAGE.md](docs/STORAGE.md) for bulk cleanup scripts and retention policies.

## Recovery Patterns

**Restore a single file:**
```bash
git show main-backup-2025-10-01:path/to/file.txt > recovered-file.txt
```

**Compare changes over time:**
```bash
git diff main-backup-2025-10-01..main-backup-2025-10-08 -- file.txt
```

**Create recovery branch:**
```bash
git checkout main-backup-2025-10-01
git checkout -b recovery-branch
```

## How It Works

1. Scheduled trigger (or manual run)
2. Checkout repository at current state
3. Collect metadata (commits, contributors, files)
4. Create backup branch: `{branch}-backup-YYYY-MM-DD`
5. Add annotated tag with statistics
6. Push to GitHub
7. Create issue on failure (optional)

## Documentation

- [Setup Guide](docs/SETUP_GUIDE.md) - Installation and configuration
- [Storage Management](docs/STORAGE.md) - Cleanup and retention
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues
- [Advanced Config](docs/ADVANCED.md) - Custom tokens and options

## Support

Personal project shared as-is. Limited support available.

- [Report issues](https://github.com/ggfevans/branch-backup-action/issues)
- [Request features](https://github.com/ggfevans/branch-backup-action/issues)
- [Fork and customize](https://github.com/ggfevans/branch-backup-action/fork)

Response times vary. Consider forking for mission-critical needs.

## License

MIT License - see [LICENSE](LICENSE)

---

*This project uses AI tools (Claude, GitHub Copilot) as development aids under full human oversight. See [AI_ACKNOWLEDGMENT.md](AI_ACKNOWLEDGMENT.md) for details.*