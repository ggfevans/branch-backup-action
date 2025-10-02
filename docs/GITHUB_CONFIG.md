# GitHub Repository Configuration Reference

This document contains all the settings and metadata for configuring the GitHub repository.

## Repository Settings

### Basic Information

**Repository name:** `branch-backup-action`

**Description (short):**
```
Weekly Git branch snapshots with metadata tracking. Originally built for Obsidian vault backups. Provided as-is.
```

**Website:** Leave blank (or add documentation site if you create one later)

**Topics/Tags to add:**
- `github-actions`
- `backup`
- `git`
- `automation`
- `obsidian`
- `workflow`
- `snapshot`
- `version-control`

### Repository Options

**Template repository:** ✓ **Enable this**
- Allows users to click "Use this template"
- Makes adoption much easier

**Require contributors to sign off:** (optional, your choice)

**Allow merge commits:** ✓
**Allow squash merging:** ✓  
**Allow rebase merging:** ✓

### Features to Enable

- ✓ **Issues** - For bug reports and questions
- ✓ **Discussions** - For community Q&A
- ✗ **Projects** - Not needed for this simple project
- ✗ **Wiki** - Documentation in `/docs` is sufficient
- ✓ **Preserve this repository** - Archive if you stop maintaining

### Actions Settings

Go to Settings → Actions → General:

- ✓ **Allow all actions and reusable workflows**
- ✓ **Allow actions created by GitHub**
- Default GITHUB_TOKEN permissions: **Read and write** (for creating branches/tags)

## Badges for README

The README already includes these badges (update usernames):

```markdown
[![GitHub](https://img.shields.io/github/license/ggfevans/branch-backup-action)](LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/ggfevans/branch-backup-action)](https://github.com/ggfevans/branch-backup-action/issues)
```

**Additional optional badges:**
```markdown
[![GitHub stars](https://img.shields.io/github/stars/ggfevans/branch-backup-action)](https://github.com/ggfevans/branch-backup-action/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/ggfevans/branch-backup-action)](https://github.com/ggfevans/branch-backup-action/network)
```

## Initial Release

### Create Initial Release (v0.1.0)

1. Go to **Releases** → **Create a new release**
2. **Choose a tag:** `v0.1.0` (create new tag)
3. **Target:** main
4. **Release title:** `v0.1.0 - Initial Release`
5. **Description:**

```markdown
## Weekly Branch Backup - v0.1.0

Initial public release of the weekly branch backup workflow.

### What It Does
- Creates weekly snapshot branches with date-based naming (`backup-YYYY-MM-DD`)
- Adds annotated Git tags with commit statistics
- Automatically creates GitHub issues on workflow failures
- Preserves all backups indefinitely (no automatic cleanup)

### Recent Fix
- Tag push now uses explicit `refs/tags/` prefix to avoid Git ambiguity

### Origin Story
Originally built for personal use with my Obsidian vault synced via Git. 
Sharing publicly as-is for anyone who finds it useful.

### Installation
See [docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md) for setup instructions.

### Features
- Automatic weekly backups (every Sunday at midnight UTC)
- Rich metadata in annotated tags
- Failure notifications via GitHub issues
- Manual trigger support
- Configurable schedule and branch names

### Support
Provided as-is with limited support. Forks and modifications encouraged!

### Version Note
This is version 0.1.0 - functional but not extensively tested in the wild. 
Please report any issues you encounter!

---

**Note:** This is a personal project shared with the community. 
Response times to issues may vary. No warranty provided.
```

6. **Publish release**

## About Section

Edit the "About" section on the main repository page:

**Description:** (same as repository description above)

**Website:** (leave blank)

**Topics:** Add all the topics listed above

**Options:**
- ✓ Include in the home page
- ✓ Releases
- ✗ Packages
- ✗ Deployments

## Social Media Sharing

### Twitter/X Post
```
I built a GitHub Action for weekly Git branch backups - originally for my Obsidian vault, 
now sharing with the community. 

Includes metadata tags & failure notifications. Provided as-is 🚀

https://github.com/ggfevans/branch-backup-action

#GitHubActions #Obsidian #Git
```

### LinkedIn Post
```
I'm sharing a GitHub Action I built for automated weekly repository backups.

Originally created for my Obsidian personal knowledge vault, but works with any Git repository.

Features:
- Weekly branch snapshots
- Metadata tracking (commits, contributors, files changed)
- Automatic failure notifications
- Zero configuration needed

Sharing it as-is for anyone who might find it useful. MIT licensed, fork-friendly.

Link: [GitHub URL]

#GitHub #Automation #OpenSource #Obsidian
```

### Reddit r/ObsidianMD
**Title:** `[Tool] Automated Weekly Backups for Git-Synced Vaults`

```markdown
I use Git to sync my Obsidian vault across devices, and wanted automated 
weekly snapshots as insurance. Created a GitHub Action that:

- Creates dated backup branches every Sunday
- Tags them with metadata (commits, contributors, files changed)  
- Alerts me if it fails
- No automatic cleanup (keeps everything)

Originally built for personal use, now sharing in case others find it useful.

GitHub: [link]

Provided as-is with limited support, but contributions/forks welcome!

**Use case:** Protection against accidental deletions, sync conflicts, 
major reorganizations, or plugin update issues.
```

### Dev.to Article (Optional)

**Title:** `Automating Git Backups with GitHub Actions: An Obsidian Vault Story`

**Tags:** `github`, `automation`, `obsidian`, `git`

**Suggested outline:**
1. The problem: Protecting my Obsidian vault
2. The solution: GitHub Actions workflow
3. How it works (technical walkthrough)
4. Why I'm sharing it
5. How others can use/modify it

## Community Guidelines

Consider adding a CODE_OF_CONDUCT.md:

```markdown
# Code of Conduct

This project is provided as-is as a personal tool shared with the community.

## Expected Behavior
- Be respectful in issues and discussions
- Provide constructive feedback
- Understand that support is limited
- Help other community members when possible

## Not Acceptable
- Demanding immediate support or features
- Hostile or aggressive communication
- Spam or off-topic content

## Enforcement
The maintainer reserves the right to close issues or discussions that 
don't follow these guidelines.

Remember: This is a personal project shared freely. Treat it as such.
```

## Contributing Guidelines (Already in README)

No separate CONTRIBUTING.md needed since it's covered in the README, but 
you could create one if you want to separate concerns.

## Repository Labels

Suggested labels for issues:

**Default GitHub labels are fine, but consider adding:**
- `obsidian-specific` - Issues specific to Obsidian use case
- `good-first-issue` - Easy contributions for newcomers
- `wontfix-by-maintainer` - Valid requests but outside scope
- `fork-encouraged` - Feature better suited for a fork

## Licensing

Already has MIT License file - no changes needed.

## Repository Visibility

Recommended: **Public**
- Allows community benefit
- Enable template feature
- Discoverable by others
- Can still be forked/modified

## Branch Protection (Optional)

Consider protecting `main` branch:
- Require pull request reviews (optional, since it's personal)
- Require status checks (optional)

Or just use default - simpler for personal projects.

## Pinned Issues (Optional)

You could create and pin:
1. "Welcome & Introduction" issue
2. "Known Limitations" issue  
3. "Share Your Use Case" discussion

But this might be overkill for a simple tool.

## Final Checklist

Before making repository public:

- [ ] All files committed
- [ ] README.md updated (no placeholder "yourusername")
- [ ] Repository description set
- [ ] Topics/tags added
- [ ] Template repository enabled
- [ ] Issues and Discussions enabled
- [ ] Initial release (v1.0.0) created
- [ ] You're comfortable with the "as-is" disclaimer
- [ ] Repository is set to Public visibility

Then you're ready to share! 🚀
