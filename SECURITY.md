# Security Policy

## Supported Versions

This project follows semantic versioning. Security updates are provided for the latest major version.

| Version | Supported          | Security Updates | End of Life |
| ------- | ------------------ | --------------- | ----------- |
| 1.x.x   | :white_check_mark: | Active          | TBD         |
| 0.x.x   | :x:                | None            | 2025-10-04  |

### Security Update Policy

- **Critical vulnerabilities**: Patched within 48 hours when possible
- **High severity issues**: Patched within 7 days
- **Medium/Low severity**: Included in next regular release
- **Security advisories**: Published for all severity levels

## Reporting a Vulnerability

If you discover a security vulnerability in this GitHub Action, please report it responsibly:

### How to Report

**DO NOT** create a public GitHub issue for security vulnerabilities.

Instead, please:

1. **Email**: Send details to the repository owner via the contact information in their GitHub profile
2. **GitHub Security Advisories**: Use the "Security" tab in this repository to create a private security advisory

### What to Include

Please include as much information as possible:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact and attack scenarios
- Any suggested fixes or mitigations

### Response Timeline

- **24 hours**: Initial acknowledgment of your report
- **72 hours**: Initial assessment and severity classification
- **7 days**: Regular updates on investigation progress
- **30 days**: Target resolution timeframe for most issues

### Security Considerations

This GitHub Action:

- Uses only the standard `GITHUB_TOKEN` provided by GitHub Actions
- Requires `contents: write` and `issues: write` permissions
- Creates branches and tags in the repository
- Does not access external systems or third-party services
- Does not handle sensitive user data beyond Git repository contents

### Scope

Security issues within scope:
- Code injection vulnerabilities in shell scripts
- Token exposure or privilege escalation
- Unauthorized access to repository data
- Workflow manipulation attacks

Out of scope:
- Issues in dependencies (report to respective maintainers)
- General GitHub Actions platform vulnerabilities
- Social engineering attacks

## Security Monitoring

### OpenSSF Scorecard

This repository is monitored using [OpenSSF Scorecard](https://github.com/ossf/scorecard) for supply chain security assessment. The scorecard evaluates various security practices and provides a numerical score.

**Current Security Metrics:**
- Automated security scanning: Weekly
- Dependency vulnerability scanning: Enabled via Dependabot
- Code review requirements: Enforced on main branch
- Pinned dependencies: All action dependencies use full commit SHAs

### Security Scanning

- **CodeQL Analysis**: Automated static analysis for code vulnerabilities
- **Dependency Scanning**: Dependabot monitors for vulnerable dependencies  
- **Supply Chain Security**: OpenSSF Scorecard evaluates security posture
- **Branch Protection**: Main branch requires reviews and status checks

## Supply Chain Security

### Action Dependencies

All GitHub Actions used by this project are pinned to specific commit SHAs:

```yaml
# Example: Pinned to specific commit SHA instead of version tag
uses: actions/checkout@08c6903cd8c0fde910a37f88322edcfb5dd907a8 # v5
```

### Verification

To verify the integrity of this action:

1. **Check commit signatures**: All commits to main branch are verified
2. **Review pinned dependencies**: All action dependencies use full commit SHAs
3. **Validate checksums**: Release artifacts include checksums for verification

## Security Best Practices

### For Action Users

1. **Pin to specific versions**: Always use tagged releases, not branch names
   ```yaml
   # Good: Pinned to specific version
   uses: ggfevans/branch-backup-action@v1.1.0
   
   # Avoid: Using branch names
   uses: ggfevans/branch-backup-action@main
   ```

2. **Review permissions**: Only grant necessary permissions
   ```yaml
   permissions:
     contents: write    # Required for creating branches/tags
     issues: write      # Required for failure notifications only
   ```

3. **Monitor audit logs**: Regularly review repository audit logs for unexpected activity

4. **Restrict workflow access**: Limit who can modify `.github/workflows/` files

5. **Validate action behavior**: Test in a non-production environment first

### For Repository Administrators

1. **Enable branch protection**: Protect main branch with required reviews
2. **Configure Dependabot**: Enable security updates for dependencies
3. **Monitor security advisories**: Subscribe to repository security notifications
4. **Regular security reviews**: Periodically audit workflow configurations

## Security Architecture

### Trust Boundaries

```
GitHub Actions Runner
  ├─ Repository Contents (trusted)
  ├─ Action Dependencies (verified via SHA pinning)
  ├─ GitHub Token (scoped permissions)
  └─ Generated Artifacts (branches/tags only)
```

### Data Flow Security

1. **Input validation**: All user inputs are sanitized before shell execution
2. **Output sanitization**: Action outputs are controlled and validated
3. **No external network calls**: Action operates entirely within GitHub ecosystem
4. **Minimal token scope**: Uses standard `GITHUB_TOKEN` with minimal permissions

### Threat Model

**Potential threats and mitigations:**

| Threat | Likelihood | Impact | Mitigation |
|--------|------------|--------|-----------|
| Malicious dependency | Low | High | SHA pinning, automated scanning |
| Code injection | Medium | High | Input sanitization, ShellCheck linting |
| Token compromise | Low | Medium | Minimal permissions, audit logging |
| Workflow manipulation | Medium | Medium | Branch protection, code review |

Thank you for helping keep this project secure!
