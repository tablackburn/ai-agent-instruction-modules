# AIM: AI Agent Instruction Modules

Modular, opt-in AI agent instructions for any codebase.

AIM provides a curated collection of instruction modules that work with all popular AI coding agents including GitHub Copilot, Claude, Cursor, Windsurf, and any agent that supports the [agents.md](https://agents.md/) standard.

## Quick Setup

### Deployment

Copy and paste this prompt into your AI agent with your target repository open:

```text
Clone the ai-agent-instruction-modules repository from
https://github.com/tablackburn/ai-agent-instruction-modules to the current working
directory. Copy AGENTS.template.md to the root of this repository as AGENTS.md.
Create the instructions/ folder if it doesn't exist. Then copy all files from the
cloned instructions/ folder to the local instructions/ folder EXCEPT
repository-specific.instructions.md (do not copy that file—you will create it fresh
in the next step). After copying, immediately remove the cloned repository folder
using Remove-Item -Recurse -Force (PowerShell) or rm -rf (bash) to maintain a clean
workspace.

Then, create a NEW file named repository-specific.instructions.md in the instructions/
folder with repository-specific instructions or information tailored to THIS repository
(for example: special branch policies, unique workflows, required tools, or any details
that apply only to this repository and not all repositories). Do not copy this file from
the template repository.

Update the 'Last sync' placeholder in AGENTS.md to today's date (e.g., 2025-12-27) and
remove the HTML comment block at the top of the file, as instructed in the template.
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

- **PowerShell standards** - Cmdlet naming, parameter conventions, and scripting best practices
- **Markdown standards** - Documentation formatting and structure guidelines
- **GitHub CLI integration** - Efficient PR and issue management workflows
- **Update procedures** - Instructions for keeping downstream repositories current

## Repository Structure

```text
ai-agent-instruction-modules/
├── AGENTS.template.md                    # Template for downstream repositories
├── AGENTS.md                             # This repository's implementation
├── CHANGELOG.md                          # Version history
├── README.md                             # This file
├── CONTRIBUTING.md                       # Contribution guidelines
├── LICENSE                               # MIT License
├── instructions/                         # Instruction files directory
│   ├── agent-workflow.instructions.md    # AI agent task workflow
│   ├── powershell.instructions.md        # PowerShell coding standards
│   ├── markdown.instructions.md          # Markdown formatting standards
│   ├── github-cli.instructions.md        # GitHub CLI usage
│   ├── repository-specific.instructions.md # Repository-specific customizations
│   └── update.instructions.md            # Update procedures
├── tests/                                # Pester test directory
│   └── *.Tests.ps1                       # Validation tests
└── .github/workflows/                    # CI/CD workflows
    └── ci.yml                            # GitHub Actions workflow
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

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## License

MIT License - see [LICENSE](LICENSE) for details.
