# AIM: AI Agent Instruction Modules

Modular, opt-in AI agent instructions for any codebase.

AIM provides a curated collection of instruction modules that work with all popular AI coding agents including GitHub Copilot, Claude, Cursor, Windsurf, and any agent that supports the [agents.md](https://agents.md/) standard.

## Features

- **Modular**: Pick only the instruction modules you need
- **Opt-in Configuration**: Simple JSON config to enable/disable modules
- **Centralized Updates**: Sync latest instructions without losing your customizations
- **Fallback Support**: Leverage [awesome-copilot](https://github.com/github/awesome-copilot) for additional languages
- **Cross-Platform**: PowerShell Core scripts work on Windows, macOS, and Linux

## Quick Start

### Prerequisites

- [PowerShell Core](https://github.com/PowerShell/PowerShell) (pwsh) 7.0 or later
- Git

### Installation

1. Clone this repository into your project:

```powershell
git clone https://github.com/tablackburn/ai-agent-instruction-modules.git .aim
```

2. Run the deploy script:

```powershell
.\.aim\scripts\deploy.ps1
```

3. Edit `aim.json` to enable/disable modules:

```json
{
  "modules": {
    "core/agent-workflow": true,
    "core/code-quality": true,
    "languages/powershell": true,
    "languages/python": "awesome-copilot"
  }
}
```

4. Regenerate your `AGENTS.md`:

```powershell
.\.aim\scripts\build-agents-md.ps1
```

## Updating

To pull the latest instruction modules:

```powershell
.\.aim\scripts\sync.ps1
```

This will:
- Pull latest changes from the AIM repository
- Preserve your `aim.json` configuration
- Regenerate `AGENTS.md` with updated content

## Configuration

### aim.json

The `aim.json` file in your project root controls which modules are enabled:

```json
{
  "$schema": "https://raw.githubusercontent.com/tablackburn/ai-agent-instruction-modules/main/schema.json",
  "version": "1.0.0",
  "modules": {
    "core/agent-workflow": true,
    "core/code-quality": true,
    "languages/powershell": true,
    "languages/python": "awesome-copilot"
  },
  "fallback": {
    "enabled": true,
    "source": "https://github.com/github/awesome-copilot",
    "branch": "main",
    "basePath": "instructions"
  },
  "customInstructionsPath": "./custom-instructions.md"
}
```

### Module Values

- `true` - Use AIM's local module
- `false` - Disabled
- `"awesome-copilot"` - Fetch from the awesome-copilot repository

### Profiles

Use a predefined profile for quick setup:

```powershell
.\.aim\scripts\deploy.ps1 -Profile minimal
```

Available profiles:
- `minimal` - Core modules only
- `web-developer` - JavaScript, TypeScript, React, Node.js
- `python-developer` - Python, FastAPI, testing
- `full-stack` - All available modules

## Available Modules

### Core (Recommended)
| Module | Description |
|--------|-------------|
| `core/agent-workflow` | Pre-flight protocol for AI agents |
| `core/code-quality` | General code quality guidelines |
| `core/security` | Security best practices |

### Languages
| Module | Description |
|--------|-------------|
| `languages/powershell` | PowerShell coding standards |

### Practices
| Module | Description |
|--------|-------------|
| `practices/git-workflow` | Git conventions and workflow |

### Tools
| Module | Description |
|--------|-------------|
| `tools/github-cli` | GitHub CLI usage guidelines |

### Styles
| Module | Description |
|--------|-------------|
| `styles/markdown` | Markdown formatting standards |

## Custom Instructions

Add repository-specific instructions by creating a `custom-instructions.md` file and referencing it in your config:

```json
{
  "customInstructionsPath": "./custom-instructions.md"
}
```

This content will be appended to your generated `AGENTS.md`.

## How It Works

1. **Deploy**: Clones AIM and creates initial `aim.json`
2. **Configure**: Edit `aim.json` to select your modules
3. **Build**: Generates a single `AGENTS.md` from enabled modules
4. **Sync**: Updates modules while preserving your configuration

The generated `AGENTS.md` follows the [agents.md standard](https://agents.md/) and works with any compatible AI coding agent.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.
