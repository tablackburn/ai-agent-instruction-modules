# AIM: AI Agent Instruction Modules

Modular, opt-in AI agent instructions for any codebase.

AIM provides a curated collection of instruction modules that work with all popular AI coding agents including GitHub Copilot, Claude, Cursor, Windsurf, and any agent that supports the [agents.md](https://agents.md/) standard.

## Quick Setup

### Deployment

Copy and paste this prompt into your AI agent with your target repository open:

```text
Clone the ai-agent-instruction-modules repository from
https://github.com/tablackburn/ai-agent-instruction-modules to the current working
directory.

Before copying any files, check if AGENTS.md or the instructions/ folder already
exists in this repository. If either exists, ask the user whether to:
1. Overwrite existing files (fresh deployment)
2. Only copy files that don't already exist (preserve customizations)
3. Abort

Check for existing instruction files (CLAUDE.md, .claude/, COPILOT.md, .cursorrules,
.github/copilot-instructions.md). If found, review their content and migrate any
repository-specific instructions (branch policies, workflows, tooling requirements)
into the new repository-specific.instructions.md file. Do not migrate content that
duplicates or conflicts with the standard AIM instruction modules. Ask the user
whether to remove or archive the original instruction files after migration.

Then proceed based on the user's choice: Copy AGENTS.template.md to the root as
AGENTS.md. Create the instructions/ folder if it doesn't exist. Copy all files
from the cloned instructions/ folder EXCEPT repository-specific.instructions.md.
After copying, remove the cloned repository folder using Remove-Item -Recurse
-Force (PowerShell) or rm -rf (bash).

Then, create a NEW file named repository-specific.instructions.md in instructions/
with repository-specific instructions tailored to THIS repository (for example:
special branch policies, unique workflows, required tools, or any details that
apply only to this repository). Do not copy this file from the template repository.

Update the 'Last sync' placeholder in AGENTS.md to today's date (e.g., 2025-12-27)
and remove the HTML comment block at the top of the file.
```

### Manual Alternative

1. Copy `AGENTS.template.md` to your repository root as `AGENTS.md`
2. Copy all files from `instructions/` folder (except `repository-specific.instructions.md`)
3. Create a new `repository-specific.instructions.md` file tailored to your repository
4. Update the sync date and remove the HTML comment from `AGENTS.md`

## Updating Instructions

To update instructions in a downstream repository, ask your AI agent:

```text
Update the AI agent instructions from the centralized repository at
https://github.com/tablackburn/ai-agent-instruction-modules following the procedures
in instructions/update.instructions.md
```

The agent will sync the latest template and instruction files while preserving your repository-specific customizations.

## What This Provides

### Core Modules
- **Agent workflow** - Pre-flight protocol for AI agents
- **Shorthand** - Guidelines for avoiding abbreviations in code
- **Git workflow** - Branching, commits, and pull request conventions
- **Testing** - Test writing best practices and conventions

### Language & Tool Modules
- **PowerShell** - Cmdlet naming, parameter conventions, and scripting best practices
- **Markdown** - Documentation formatting and structure guidelines
- **README** - README maintenance guidelines
- **GitHub CLI** - Efficient PR and issue management workflows

### Repository Management
- **Releases** - Release management with semantic versioning
- **Update** - Procedures for keeping downstream repositories current
- **Contributing** - Workflow for contributing improvements to upstream

## Repository Structure

```text
ai-agent-instruction-modules/
├── AGENTS.template.md                        # Template for downstream repositories
├── AGENTS.md                                 # This repository's implementation
├── CHANGELOG.md                              # Version history
├── README.md                                 # This file
├── CONTRIBUTING.md                           # Contribution guidelines
├── LICENSE                                   # MIT License
├── instructions/                             # Instruction modules
│   ├── agent-workflow.instructions.md        # AI agent task workflow
│   ├── shorthand.instructions.md             # Avoid abbreviations
│   ├── git-workflow.instructions.md          # Git conventions
│   ├── testing.instructions.md               # Test writing practices
│   ├── powershell.instructions.md            # PowerShell standards
│   ├── markdown.instructions.md              # Markdown formatting
│   ├── readme.instructions.md                # README maintenance
│   ├── github-cli.instructions.md            # GitHub CLI usage
│   ├── releases.instructions.md              # Release management
│   ├── contributing.instructions.md          # Contributing to upstream
│   ├── update.instructions.md                # Update procedures
│   └── repository-specific.instructions.md   # Repository customizations
├── tests/                                    # Pester test directory
│   └── *.Tests.ps1                           # Validation tests
└── .github/workflows/                        # CI/CD workflows
    └── ci.yml                                # GitHub Actions workflow
```

## Testing

Run tests locally:

```powershell
Invoke-Pester -Path .\tests\
```

Tests verify:

- Instruction file integrity
- Template structure
- Version consistency

## For Maintainers

To update centralized instructions:

1. Edit files in `instructions/` folder
2. Update `AGENTS.template.md` version and content
3. Update `AGENTS.md` to match (sync from template)
4. Update `CHANGELOG.md` with changes
5. Commit and push

Downstream repositories must manually request updates from AI agents.

## Community Contributions

AIM provides 12 instruction modules covering workflows, standards, and practices.
We welcome contributions for additional languages and frameworks.

**Wanted:**

- Language modules: Python, TypeScript, Go, Rust, C#
- Framework guides: React, FastAPI, ASP.NET, Django
- Tool integrations: Docker, Terraform, Kubernetes

To contribute a new instruction module, see [CONTRIBUTING.md](CONTRIBUTING.md). Each
module should include YAML frontmatter with `applyTo` patterns and follow the
conventions established in existing modules.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## License

MIT License - see [LICENSE](LICENSE) for details.
