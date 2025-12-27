# AI Agent Instructions for AIM Repository

This is the source repository for AIM (AI Agent Instruction Modules).

## Repository Context

- **Purpose**: Maintain modular AI agent instruction templates
- **Language**: PowerShell (scripts), Markdown (instructions)
- **Distribution**: Git-based cloning and syncing

## Development Guidelines

### Modifying Instruction Modules

When editing files in `instructions/`:

1. Maintain YAML frontmatter with required fields:
   - `id`: Module identifier matching path (e.g., `core/agent-workflow`)
   - `name`: Human-readable name
   - `description`: Brief description
   - `applyTo`: Glob patterns for file matching
   - `requires`: Hard dependencies (array)
   - `recommends`: Soft dependencies (array)
   - `tags`: Categorization tags (array)

2. Keep instructions generic and universal:
   - Avoid organization-specific references
   - Use placeholder examples (`<owner>`, `<repo>`)
   - Focus on best practices applicable to any project

3. Follow Markdown conventions in `instructions/styles/markdown.md`

### Modifying Scripts

PowerShell scripts in `scripts/` should:

1. Follow conventions in `instructions/languages/powershell.md`
2. Include comment-based help
3. Support cross-platform execution (PowerShell Core)
4. Handle errors gracefully with informative messages

### Adding New Modules

1. Create the module file in appropriate category folder
2. Add complete YAML frontmatter
3. Update relevant profile files in `config/profiles/`
4. Test with `build-agents-md.ps1`

### Testing Changes

```powershell
# Test building AGENTS.md
.\scripts\build-agents-md.ps1 -TargetPath .

# Validate JSON schema
# (Use VS Code or jsonschema validator)
```

## Release Process

1. Update `CHANGELOG.md` following Keep a Changelog format
2. Bump version in CHANGELOG
3. Create git tag matching version
4. Push tag to trigger release workflow

## File Structure

```
instructions/
├── core/           # Always-recommended modules
├── languages/      # Language-specific guidelines
├── frameworks/     # Framework-specific guidelines
├── practices/      # Development practice guidelines
├── tools/          # Tool-specific guidelines
└── styles/         # Code style guidelines
```
