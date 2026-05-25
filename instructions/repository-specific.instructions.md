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

When editing files in `instruction-templates/`:

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

1. Create the file in `instruction-templates/` with `.instructions.md` extension
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

**IMPORTANT: Every change to instruction files or templates requires a release.** Do not push
changes without completing this process.

### When to Release

A release is required after ANY of the following:

- Changes to files in `instruction-templates/`
- Changes to `AGENTS.md` or `AGENTS.template.md`
- Changes to `CHANGELOG.md`
- Changes to `README.md` that affect usage or deployment

### Version Numbering (Semantic Versioning)

- **MAJOR** (1.0.0): Breaking changes that require downstream action
- **MINOR** (0.1.0): New features, new instruction files, significant additions
- **PATCH** (0.0.1): Bug fixes, typo corrections, clarifications, small improvements

### Release Steps

Releases are automated. On every push to `main`, the `.github/workflows/release.yml` workflow
reads the first dated section in `CHANGELOG.md`, creates the matching `vX.Y.Z` tag on the commit
that was pushed to `main`, and publishes a GitHub release with notes extracted from that section.
The workflow is idempotent: it skips creation when the release already exists.

Your job is to prepare the release inside a pull request so the workflow has what it needs:

1. **Update CHANGELOG.md**
   - Move the `[Unreleased]` changes into a new dated section: `## [X.Y.Z] - YYYY-MM-DD`
   - Categorize changes using the standard Keep a Changelog sections (Added, Changed, Deprecated,
     Removed, Fixed, Security); use the sections that apply
   - Repoint the `[Unreleased]` comparison link to `vX.Y.Z...HEAD` and add the `[X.Y.Z]` link

2. **Update version numbers**
   - `AGENTS.template.md`: Update "Template Version: X.Y.Z"
   - `AGENTS.md`: Update "Template Version: X.Y.Z" and the "Last sync" date
   - Verify all three versions match (template, AGENTS.md, latest changelog section)

3. **Open a pull request and merge it** following `git-workflow.instructions.md`. When the branch
   lands on `main`, the Release workflow tags that pushed commit and publishes the release.

Do not create the tag or run `gh release create` by hand. The workflow owns those steps, and a
manual tag collides with it. If you ever need to author release notes manually, follow
`releases.instructions.md` and use `--notes-file` rather than `--notes`.

### Release Checklist

- [ ] CHANGELOG.md updated with new dated version section
- [ ] CHANGELOG.md comparison links updated
- [ ] AGENTS.template.md version updated
- [ ] AGENTS.md version and "Last sync" date updated
- [ ] All three versions match
- [ ] Pull request merged to `main`
- [ ] Release workflow created the tag and GitHub release (verify on the Releases page)

## File Structure

```text
instruction-templates/                  # Source templates for distribution
├── agent-workflow.instructions.md      # Pre-flight protocol (read first)
├── powershell.instructions.md          # PowerShell standards
├── markdown.instructions.md            # Markdown formatting
├── github-cli.instructions.md          # GitHub CLI usage
├── repository-specific.instructions.md # Template for repo-specific customizations
└── update.instructions.md              # Sync procedures

instructions/                           # This repository's active instructions
└── (configured via aim.config.json)
```

## Template vs Implementation

- `AGENTS.template.md` - The file distributed to downstream repositories
- `AGENTS.md` - This repository's own implementation (should match template content)

Both files must have matching version numbers. The template includes an HTML comment that
downstream repos should remove.
