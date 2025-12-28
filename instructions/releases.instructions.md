---
applyTo: '**/*'
description: 'Release management guidelines for AI agents'
---

# Release Instructions for AI Agents

When creating releases, AI agents must follow these guidelines to ensure proper release
management and avoid formatting issues.

These instructions are self-contained for release processes but reference
repository-specific.instructions.md for additional requirements.

## Creating Releases

Always use `--notes-file` instead of `--notes` when creating GitHub releases to avoid escaping
issues with special characters (backticks, backslashes, quotes, etc.):

```powershell
# Create a temporary file with release notes
$releaseNotes = @"
## Added

- Your changes here

## Changed

- Your changes here

## Fixed

- Your changes here
"@

$releaseNotes | Out-File -FilePath "release-notes.md" -Encoding utf8
gh release create v0.x.y --title "v0.x.y - Release Title" --notes-file release-notes.md
Remove-Item "release-notes.md"
```

## Release Notes Format

Release notes should follow the [Keep a Changelog](https://keepachangelog.com/) format:

- Use standard sections: Added, Changed, Deprecated, Removed, Fixed, Security
- Write clear, user-focused descriptions
- Reference issue numbers or PRs where relevant
- Use present tense for changes ("Add feature" not "Added feature" in the section items)
- Keep descriptions concise but informative

## Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** version (x.0.0): Breaking changes or incompatible API changes
- **MINOR** version (0.x.0): New features in a backward-compatible manner
- **PATCH** version (0.0.x): Backward-compatible bug fixes

## Pre-Release Checklist

Before creating a release:

1. **Verify current release state**: Run `gh release list --limit 5` to check the most recent
   releases. Compare the latest released version against the version in CHANGELOG.md. If they
   match, the changelog version needs to be incremented. If the changelog is already ahead, use
   that version. NEVER release a version that already exists.
1. **Check repository-specific instructions**: Review `repository-specific.instructions.md` for
   any additional release requirements specific to this repository
1. **Update CHANGELOG.md**: Add new version section with all changes
1. **Update version numbers**: Bump version in relevant files as needed
1. **Update changelog links**: Add comparison link for the new version at the bottom of
   CHANGELOG.md (e.g., `[0.2.0]: https://github.com/owner/repo/compare/v0.1.0...v0.2.0`)
1. **Run tests**: Ensure all tests pass
1. **Commit changes**: Commit all version updates before creating the release
1. **Push to remote**: Push commits to the repository
1. **Create release**: Use the `gh release create` command with `--notes-file`

## Post-Release

After creating a release:

1. Verify the release appears correctly on GitHub
1. Check that release notes display properly (no formatting issues)
1. Confirm download links work if applicable
1. Notify team members if this is a significant release
