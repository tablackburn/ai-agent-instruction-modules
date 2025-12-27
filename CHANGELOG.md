# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.2] - 2025-12-27

### Changed

- Expanded Release Process section in repository-specific instructions with clear triggers, semantic versioning guidance, step-by-step process, and checklist

## [0.2.1] - 2025-12-27

### Added

- Version pinning via `aim.config.json` - pin to "latest" or specific version (e.g., "0.2.0")
- CHANGELOG-based change summaries during updates - agents now summarize what changed between versions
- Credential Handling section in PowerShell instructions with `[PSCredential]` patterns

### Fixed

- PowerShell: Renamed `Process-Data` to `Get-PipelineInput` (unapproved verb)
- PowerShell: Renamed `Get-Settings` to `Get-Setting` (singular noun rule)
- PowerShell: Expanded type accelerator example to show full `param()` context
- GitHub CLI: Dynamic issue number capture instead of hardcoded `#123`
- GitHub CLI: Clarified operational nature in description (not file-specific)
- Agent Workflow: Fixed confusing "this AGENTS.md file" reference
- Markdown: Removed "code comments" from scope (only applies to .md files)

## [0.2.0] - 2025-12-27

### Changed

- **BREAKING**: Restructured to follow private repository pattern
  - Removed automation scripts (`deploy.ps1`, `build-agents-md.ps1`, `sync.ps1`)
  - Removed JSON configuration system (`aim.json`, `schema.json`, profiles)
  - Flattened instructions folder structure (removed nested categories)
  - Renamed instruction files to use `.instructions.md` extension
  - Simplified YAML frontmatter to `applyTo` and `description` only

### Added

- `AGENTS.template.md` - Template file for downstream repositories
- `update.instructions.md` - Agent-driven update procedures
- `repository-specific.instructions.md` - Template for repo-specific customizations
- Copy-paste deployment prompts in README (agent-driven setup)
- New validation tests for file structure and version consistency

### Removed

- `scripts/deploy.ps1` - Replaced by copy-paste prompt
- `scripts/build-agents-md.ps1` - No longer needed (direct file copying)
- `scripts/sync.ps1` - Replaced by agent-driven update procedure
- `config/` folder and all profile presets
- `schema.json` - No longer using JSON configuration
- Nested instruction folder structure (`core/`, `languages/`, etc.)
- awesome-copilot fallback system

## [0.1.0] - 2025-12-26

### Added

- Initial release of AIM (AI Agent Instruction Modules)
- Core infrastructure
  - `deploy.ps1` - Initial deployment script
  - `sync.ps1` - Update/sync script with awesome-copilot fallback support
  - `build-agents-md.ps1` - AGENTS.md generator from enabled modules
  - JSON schema for `aim.json` configuration validation
- Profile presets
  - `minimal` - Core modules only
  - `web-developer` - JavaScript, TypeScript, React, Node.js
  - `python-developer` - Python, FastAPI, testing
  - `full-stack` - All available modules
- Core instruction modules
  - `core/agent-workflow` - Pre-flight protocol for AI agents
  - `core/code-quality` - General code quality guidelines
  - `core/security` - Security best practices (OWASP)
- Practice modules
  - `practices/git-workflow` - Git conventions and workflow
- Style modules
  - `styles/markdown` - Markdown formatting standards
- Language modules
  - `languages/powershell` - PowerShell coding standards
- Tool modules
  - `tools/github-cli` - GitHub CLI usage guidelines
- awesome-copilot fallback support for additional languages and frameworks

[Unreleased]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.2.2...HEAD
[0.2.2]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/tablackburn/ai-agent-instruction-modules/releases/tag/v0.1.0
