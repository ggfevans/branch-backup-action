# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - TBD

### Added
- Initial public release
- Weekly branch snapshot creation every Sunday at midnight UTC
- Annotated Git tags with metadata (commits, contributors, files changed)
- Automatic issue creation on workflow failures
- Detailed workflow run summaries
- Manual trigger support via workflow_dispatch
- Configurable environment variables (BACKUP_PREFIX, BRANCH_TO_BACKUP)
- Comprehensive documentation in README
- Manual cleanup guide for old backups
- Obsidian-specific usage instructions

### Fixed
- Tag push now uses explicit `refs/tags/` prefix to avoid ambiguity with branch names

### Notes
- Originally created for personal Obsidian vault backups
- Shared with community as-is with limited support
- No automatic retention/cleanup policy (preserves all backups indefinitely)
- Version 0.1.0 indicates functional but not extensively battle-tested
