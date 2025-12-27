---
applyTo: '**/*'
description: 'Repository-specific instructions for the AIM template repository'
---

# Repository-Specific Instructions

This is the source repository for AIM (AI Agent Instruction Modules).

## Repository Context

- **Purpose**: Maintain modular AI agent instruction templates
- **Language**: PowerShell (tests), Markdown (instructions)
- **Distribution**: Git-based cloning via copy-paste prompts

## Development Guidelines

### Modifying Instruction Files

When editing files in `instructions/`:

1. Maintain YAML frontmatter with required fields:
   - `applyTo`: Glob patterns for file matching (e.g., `'**/*'` or `'**/*.ps1'`)
   - `description`: Brief description of the instruction file

2. Keep instructions generic and universal:
   - Avoid organization-specific references
   - Use placeholder examples (`<owner>`, `<repo>`)
   - Focus on best practices applicable to any project

3. Use the `.instructions.md` file extension for all instruction files

4. Follow Markdown conventions in `markdown.instructions.md`

### Adding New Instruction Files

1. Create the file in `instructions/` with `.instructions.md` extension
2. Add YAML frontmatter with `applyTo` and `description`
3. Update `AGENTS.template.md` to list the new file
4. Update `AGENTS.md` to match the template
5. Run tests to validate

### Testing Changes

```powershell
# Run validation tests
Invoke-Pester -Path .\tests\

# Tests validate:
# - File existence
# - Version consistency
# - Frontmatter presence
# - Changelog format
```

## Release Process

**IMPORTANT: Every change to instruction files or templates requires a release.** Do not push changes without completing this process.

### When to Release

A release is required after ANY of the following:
- Changes to files in `instructions/`
- Changes to `AGENTS.md` or `AGENTS.template.md`
- Changes to `CHANGELOG.md`
- Changes to `README.md` that affect usage or deployment

### Version Numbering (Semantic Versioning)

- **MAJOR** (1.0.0): Breaking changes that require downstream action
- **MINOR** (0.1.0): New features, new instruction files, significant additions
- **PATCH** (0.0.1): Bug fixes, typo corrections, clarifications, small improvements

### Release Steps

1. **Update CHANGELOG.md**
   - Add new version section under `[Unreleased]`
   - Use format: `## [X.Y.Z] - YYYY-MM-DD`
   - Categorize changes: Added, Changed, Fixed, Removed
   - Update comparison links at bottom of file

2. **Update version numbers**
   - `AGENTS.template.md`: Update "Template Version: X.Y.Z"
   - `AGENTS.md`: Update "Template Version: X.Y.Z"
   - Verify all three locations match (template, AGENTS.md, changelog)

3. **Commit the release**
   ```bash
   git add -A
   git commit -m "chore: Release vX.Y.Z"
   ```

4. **Create and push tag**
   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   git push && git push --tags
   ```

5. **Create GitHub release**
   ```bash
   gh release create vX.Y.Z --title "vX.Y.Z" --notes "Release notes here"
   ```
   Or use `--generate-notes` to auto-generate from commits.

### Release Checklist

- [ ] CHANGELOG.md updated with new version section
- [ ] CHANGELOG.md comparison links updated
- [ ] AGENTS.template.md version updated
- [ ] AGENTS.md version updated
- [ ] All three versions match
- [ ] Release commit created
- [ ] Git tag created (vX.Y.Z format)
- [ ] Changes pushed to origin
- [ ] GitHub release created

## File Structure

```
instructions/
├── agent-workflow.instructions.md    # Pre-flight protocol (read first)
├── powershell.instructions.md        # PowerShell standards
├── markdown.instructions.md          # Markdown formatting
├── github-cli.instructions.md        # GitHub CLI usage
├── repository-specific.instructions.md # This file
└── update.instructions.md            # Sync procedures
```

## Template vs Implementation

- `AGENTS.template.md` - The file distributed to downstream repositories
- `AGENTS.md` - This repository's own implementation (should match template content)

Both files must have matching version numbers. The template includes an HTML comment that downstream repos should remove.
