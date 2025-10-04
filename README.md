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
      - uses: ggfevans/branch-backup-action@v1
```

Creates branches named `{branch}-backup-YYYY-MM-DD` with annotated tags. Manual trigger available in Actions tab.

## For Obsidian Users

Protects against accidental deletions, sync conflicts, and failed plugin updates:

```bash
git checkout main-backup-2025-09-29  # Restore from backup
git checkout main                    # Return to current
```

## Configuration

```yaml
- uses: ggfevans/branch-backup-action@v1
  with:
    backup-prefix: 'snapshot'     # Default: 'backup'
    branch-to-backup: 'develop'   # Default: 'main'
```

Change schedule:
```yaml
cron: '0 0 * * 1'  # Every Monday instead of Sunday
```

## What It Does

- Creates `{branch}-backup-YYYY-MM-DD` branches every Sunday
- Annotated tags with commit stats (commits, contributors, files changed)
- Creates GitHub issues on failure
- Keeps all backups indefinitely

## Storage

Backups accumulate over time. Clean up old ones manually:
```bash
git push origin --delete main-backup-2025-01-01
git push origin --delete refs/tags/main-backup-2025-01-01
```

Bulk cleanup scripts in [docs/STORAGE.md](docs/STORAGE.md).

## Troubleshooting

- Enable Actions in repository settings
- Ensure workflow has `contents: write` and `issues: write` permissions
- See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## License

MIT - see [LICENSE](LICENSE)
