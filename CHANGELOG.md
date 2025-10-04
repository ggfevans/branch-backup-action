# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-10-02

### Added
- **Branch name integration**: Backup branches now include source branch name (e.g., `main-backup-2024-10-02`)
- **Fine-grained token support**: Comprehensive documentation for GitHub personal access tokens
- **Updated dependencies**: actions/checkout@v5 for latest security and performance improvements
- **Enhanced documentation**: Updated all examples to reflect new branch naming convention

### Changed
- **BREAKING**: Backup branch naming format changed from `backup-YYYY-MM-DD` to `{branch}-backup-YYYY-MM-DD`
- Updated all documentation examples to use new naming convention
- Updated cleanup scripts and patterns to work with new branch names
- All version references updated to @v1 for production release

### Fixed
- Branch name sanitization for names containing slashes (e.g., `feature/xyz` → `feature-xyz-backup-2024-10-02`)
- Updated branch protection exclusion patterns to `*-backup-*`
- Improved regex patterns in cleanup scripts for better branch matching

## [0.1.0] - 2025-10-02

### Added
- Initial public release
- Weekly branch snapshot creation every Sunday at midnight UTC
- Annotated Git tags with rich metadata (commits, contributors, files changed)
- Automatic GitHub issue creation on workflow failures
- Detailed workflow run summaries in Actions tab
- Manual trigger support via workflow_dispatch
- Configurable inputs: backup-prefix, branch-to-backup, github-token
- Comprehensive documentation:
  - Streamlined README with quick start examples
  - Advanced configuration guide (docs/ADVANCED.md)
  - Storage management and cleanup scripts (docs/STORAGE.md)
  - Detailed troubleshooting guide (docs/TROUBLESHOOTING.md)
  - Contributing guidelines (CONTRIBUTING.md)
- Security analysis with ShellCheck and Dependabot
- GitHub Actions marketplace optimization
- Issue templates for bug reports and feature requests
- Manual cleanup scripts for backup retention management
- Obsidian-specific usage instructions and recovery procedures

### Fixed
- Tag push uses explicit `refs/tags/` prefix to avoid ambiguity
- Proper error handling and status reporting
- Consistent branch and tag naming conventions

### Notes
- Originally created for personal Obsidian vault backups
- Shared with community as-is with limited support
- No automatic retention/cleanup policy (preserves all backups indefinitely)
- Version 0.1.0 indicates functional and ready for public use
