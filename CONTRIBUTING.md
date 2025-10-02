# Contributing

Thanks for your interest in contributing to the Weekly GitHub Branch Backup action!

## Important Notice

This is a **personal project** I'm sharing as-is with the community. While I appreciate contributions, please understand:

- **Limited response time** - This is a side project with no guaranteed response timeline
- **Selective implementation** - I may not implement all feature requests as the current functionality meets my needs
- **Forks encouraged** - Feel free to fork and create your own version with different features

## How to Contribute

### Reporting Issues

Before creating an issue, please:

1. **Search existing issues** - Your issue might already be reported
2. **Test the current version** - Ensure you're using the latest release
3. **Provide details** - Include:
   - Workflow run URL (if applicable)
   - Complete error messages
   - Repository details (size, visibility, branch protection, GitHub plan)
   - Steps to reproduce

### Suggesting Features

Feature requests are welcome for discussion, but:

- **Be specific** - Clearly describe the use case and expected behavior
- **Consider alternatives** - Explain why existing solutions don't work
- **Understand scope** - Large features may be better suited for forks

### Code Contributions

If you'd like to submit code changes:

1. **Fork the repository** and create a feature branch
2. **Make focused changes** - One feature or fix per PR
3. **Test thoroughly** - Verify the action works in a test repository
4. **Follow existing patterns** - Keep consistent with current code style
5. **Update documentation** - Include relevant doc updates

### Pull Request Process

1. **Clear description** - Explain what changes you made and why
2. **Reference issues** - Link to related issue numbers if applicable  
3. **Test evidence** - Show that your changes work as expected
4. **Be patient** - Response times may vary significantly

## Development Setup

This is a composite GitHub Action, so development is straightforward:

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/branch-backup-action
cd branch-backup-action

# Make changes to action.yml or documentation
# Test in a separate repository by referencing your fork:
# uses: YOUR_USERNAME/branch-backup-action@your-branch
```

## Testing

Since this is a GitHub Action, testing requires:

1. **Create a test repository** or use an existing one
2. **Add your modified action** to a workflow in that repository
3. **Run the workflow** manually or wait for scheduled execution
4. **Verify the backup** was created correctly
5. **Check failure scenarios** (if applicable)

## Documentation

When contributing:

- **Update README** if changing core functionality
- **Update docs/** files for advanced features
- **Update CHANGELOG.md** following [Keep a Changelog](https://keepachangelog.com/) format
- **Update action.yml** if adding new inputs or changing outputs

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Alternative Approaches

If you need:
- **Faster iteration** - Consider forking for your specific needs
- **Different functionality** - Fork and customize rather than requesting features
- **Production support** - This project offers limited support; consider commercial alternatives

## Questions?

For questions about contributing, feel free to open an issue. Just remember that response times are not guaranteed.

---

**Remember:** This project is shared as-is. The best way to get exactly what you need might be to fork and customize it for your use case!