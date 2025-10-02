# Security Policy

## Supported Versions

This project follows semantic versioning. Security updates are provided for the latest major version.

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

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

## Security Best Practices

When using this action:

1. **Review Permissions**: Only grant necessary permissions (`contents: write`, `issues: write`)
2. **Pin Versions**: Use specific version tags rather than `@main` in production
3. **Audit Logs**: Monitor your repository's audit logs for unexpected activity
4. **Limit Access**: Restrict who can modify workflow files in your repository

Thank you for helping keep this project secure!