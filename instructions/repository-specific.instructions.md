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

1. Update `CHANGELOG.md` following Keep a Changelog format
2. Update version in `AGENTS.template.md` and `AGENTS.md`
3. Ensure all three versions match (template, AGENTS.md, changelog)
4. Commit changes
5. Create git tag matching version
6. Push to trigger any release workflows

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
