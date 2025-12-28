![AIM: AI Agent Instruction Modules](https://tablackburn.github.io/img/aim-banner.svg)

[![Latest Release][release-badge]][releases]
[![License][license-badge]][license]
[![GitHub Stars][stars-badge]][stargazers]
![Agents Supported][agents-badge]

Modular, opt-in AI agent instructions for any codebase.

AIM provides a curated collection of instruction modules that work with all popular AI coding
agents including GitHub Copilot, Claude, Cursor, Windsurf, and any agent that supports the
[agents.md](https://agents.md/) standard.

- [Announcement Blog Post](https://tablackburn.github.io/post/announcing-ai-agent-instruction-modules/)

[release-badge]: https://img.shields.io/github/v/release/tablackburn/ai-agent-instruction-modules?display_name=tag
[license-badge]: https://img.shields.io/github/license/tablackburn/ai-agent-instruction-modules
[stars-badge]: https://img.shields.io/github/stars/tablackburn/ai-agent-instruction-modules
[agents-badge]: https://img.shields.io/badge/agents-Copilot%20%7C%20Claude%20%7C%20Cursor-blue

[releases]: https://github.com/tablackburn/ai-agent-instruction-modules/releases/latest
[license]: https://github.com/tablackburn/ai-agent-instruction-modules/blob/main/LICENSE
[stargazers]: https://github.com/tablackburn/ai-agent-instruction-modules/stargazers

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

LANGUAGE AND MODULE DETECTION:

Scan the destination repository for source files to detect languages and frameworks:
- Look for file extensions: *.py (Python), *.ts/*.tsx (TypeScript), *.js/*.jsx
  (JavaScript), *.go (Go), *.rs (Rust), *.cs (C#), *.ps1 (PowerShell), etc.
- Look for framework indicators: package.json (Node/React), requirements.txt
  (Python), go.mod (Go), Cargo.toml (Rust), *.csproj (C#/.NET)

Based on detected languages, suggest which instruction modules to include. Always
include core modules: agent-workflow, shorthand, update.

If no source files are detected (new or empty repository), ask the user:
"What languages and frameworks will this repository use? (e.g., Python, TypeScript,
React, PowerShell, Go)"

Present the user with a list of available modules and let them confirm or adjust
the selection before proceeding.

CONFIGURATION:

Copy aim.config.json.example to aim.config.json and configure it based on the
user's module selections. Set externalSources.enabled to true to enable fallback
to awesome-copilot for languages not covered by AIM.

COPYING FILES:

Proceed based on the user's choice: Copy AGENTS.template.md to the root as
AGENTS.md. Create the instructions/ folder if it doesn't exist. Copy ONLY the
selected instruction files from the cloned instruction-templates/ folder. Do not
copy repository-specific.instructions.md from the template repository.

For any languages detected that don't have a matching instruction file in AIM,
check if externalSources is enabled. If so, fetch the corresponding instruction
file from the awesome-copilot repository (https://github.com/github/awesome-copilot)
and copy it to the instructions/ folder.

After copying, remove the cloned repository folder using Remove-Item -Recurse
-Force (PowerShell) or rm -rf (bash).

Check for existing instruction files (CLAUDE.md, .claude/, COPILOT.md, .cursorrules,
.github/copilot-instructions.md). If found, review their content and migrate any
repository-specific instructions (branch policies, workflows, tooling requirements)
into the new repository-specific.instructions.md file. Do not migrate content that
duplicates or conflicts with the standard AIM instruction modules. Ask the user
whether to remove or archive the original instruction files after migration.

Then, create a NEW file named repository-specific.instructions.md in instructions/
with repository-specific instructions tailored to THIS repository (for example:
special branch policies, unique workflows, required tools, or any details that
apply only to this repository).

Update the 'Last sync' placeholder in AGENTS.md to today's date (e.g., 2025-12-28)
and remove the HTML comment block at the top of the file.
```

### Manual Alternative

1. Copy `AGENTS.template.md` to your repository root as `AGENTS.md`
1. Copy `aim.config.json.example` to `aim.config.json` and configure your modules
1. Copy desired instruction files from `instruction-templates/` to your `instructions/` folder
1. Create a new `repository-specific.instructions.md` file tailored to your repository
1. Update the sync date and remove the HTML comment from `AGENTS.md`

## Updating Instructions

To update instructions in a downstream repository, ask your AI agent:

```text
Update the AI agent instructions from the centralized repository at
https://github.com/tablackburn/ai-agent-instruction-modules following the procedures
in instructions/update.instructions.md
```

The agent will sync the latest template and instruction files while preserving your
repository-specific customizations.

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
├── aim.config.json                           # This repository's AIM configuration
├── aim.config.json.example                   # Template config for downstream repos
├── instruction-templates/                    # Source templates for distribution
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
│   └── repository-specific.instructions.md   # Template for customizations
├── instructions/                             # This repository's active instructions
│   └── (configured via aim.config.json)
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

## Configuration

AIM uses `aim.config.json` to control which instruction modules are active and enable external
sources for additional language coverage.

### Configuration Options

```json
{
  "version": "latest",
  "modules": {
    "include": ["agent-workflow", "powershell", "markdown"],
    "exclude": ["github-cli"]
  },
  "externalSources": {
    "enabled": true,
    "repositories": [
      {
        "name": "awesome-copilot",
        "url": "https://github.com/github/awesome-copilot",
        "path": "instructions",
        "description": "Community-contributed instructions from GitHub"
      }
    ]
  }
}
```

- **version**: Pin to `"latest"` or a specific version (e.g., `"0.8.0"`)
- **modules.include**: List of modules to include (without `.instructions.md` extension)
- **modules.exclude**: List of modules to exclude
- **externalSources.enabled**: Enable fallback to external repositories for missing modules
- **externalSources.repositories**: List of external instruction repositories

### External Sources

When a language or framework isn't covered by AIM, the agent can fetch instructions from
external repositories like [github/awesome-copilot](https://github.com/github/awesome-copilot).
This provides access to community-contributed instructions for Python, TypeScript, React,
and many other languages and frameworks.

## For Maintainers

To update centralized instructions:

1. Edit files in `instruction-templates/` folder
1. Sync changes to `instructions/` for this repository
1. Update `AGENTS.template.md` version and content
1. Update `AGENTS.md` to match (sync from template)
1. Update `CHANGELOG.md` with changes
1. Commit and push

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
