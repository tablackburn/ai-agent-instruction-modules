# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.8.9] - 2026-01-07

### Added

- "Common Mistakes to Avoid" section in `powershell.instructions.md` - prominent reminder that
  function names must use singular nouns

## [0.8.8] - 2026-01-07

### Changed

- Update ordered list guidance in `markdown.instructions.md` to use sequential numbering (`1.`,
  `2.`, `3.`, etc.) instead of repeating `1.` - improves readability for humans and agents

## [0.8.7] - 2026-01-06

### Added

- "Discovering Existing Test Tooling" section in `testing.instructions.md` - agents should check
  for build systems and existing tooling before creating scripts for test-related tasks

## [0.8.6] - 2026-01-06

### Added

- Example in `powershell.instructions.md` showing quoted string parameter values - string
  arguments should use single quotes rather than bare values

## [0.8.5] - 2026-01-05

### Added

- `CLAUDE.md` file referencing `AGENTS.md` for Claude Code compatibility

## [0.8.4] - 2026-01-03

### Added

- Static Analysis section in `powershell.instructions.md` - agents should fix PSScriptAnalyzer
  warnings rather than suppressing them, and must include justification when suppression is
  necessary

## [0.8.3] - 2025-12-31

### Added

- Build Systems section in `powershell.instructions.md` - agents should use existing build tools
  (psake, Invoke-Build) rather than running commands directly or creating separate scripts
- Post-deployment issue scanning step in README deployment prompt - agents now suggest improvements
  after deploying instructions

## [0.8.2] - 2025-12-28

### Added

- Test-first bug fixing workflow in `testing.instructions.md` - agents should write a failing test
  before fixing bugs to prevent regressions and document expected behavior

## [0.8.1] - 2025-12-28

### Added

- Post-task protocol in `agent-workflow.instructions.md` directing agents to check
  `repository-specific.instructions.md` for release processes and other requirements

### Fixed

- Updated outdated `instructions/` references to `instruction-templates/` in
  `repository-specific.instructions.md`

## [0.8.0] - 2025-12-28

### Added

- `aim.config.json` - Configuration file for module selection and external sources
- `aim.config.json.example` - Template configuration with external sources enabled
- `instruction-templates/` folder - Source templates for distribution to downstream repositories
- Module opt-in during deployment - Users can now select which instruction modules to include
- Language detection during deployment - Automatically suggests modules based on detected languages
- External source fallback - Fetch missing language instructions from github/awesome-copilot
- User prompting before overwriting existing files during updates

### Changed

- **BREAKING**: Instruction templates moved from `instructions/` to `instruction-templates/`
- **BREAKING**: Downstream repositories now copy from `instruction-templates/` instead of `instructions/`
- `instructions/` folder now contains this repository's active instructions (dogfooding)
- Updated deployment prompt with language detection and module selection
- Enhanced `update.instructions.md` with intelligent module syncing and external source handling
- Updated tests to validate new configuration schema and folder structure

## [0.7.0] - 2025-12-27

### Added

- `.markdownlint.json` - Configuration file for automated markdown linting
- New rules in `markdown.instructions.md`: ATX heading style, code fence style, emphasis
  spacing, image alt text, no inline HTML, no hard tabs

### Changed

- Updated all markdown files for markdownlint compliance (200+ fixes)
- Standardized ordered list prefixes to use `1. 1. 1.` style
- Added language identifiers to all fenced code blocks
- Fixed line lengths to stay within 100 characters
- Added blank lines around code blocks and lists per MD031/MD032

## [0.6.0] - 2025-12-27

### Added

- `git-workflow.instructions.md` - Git branching, commit messages, and PR conventions
- `testing.instructions.md` - Language-agnostic test writing best practices

### Changed

- Updated `README.md` with comprehensive module list and updated repository structure

## [0.5.0] - 2025-12-27

### Added

- `contributing.instructions.md` - Agent-assisted workflow for contributing improvements back to
  upstream AIM repository

### Changed

- Updated `CONTRIBUTING.md` to match current repository structure (removed outdated script
  references, updated frontmatter format)

## [0.4.0] - 2025-12-27

### Added

- `readme.instructions.md` - README maintenance guidelines
- `releases.instructions.md` - Release management guidelines (semantic versioning, changelogs,
  pre/post-release checklists)

## [0.3.0] - 2025-12-27

### Added

- `shorthand.instructions.md` - Guidelines for avoiding shorthand and abbreviations in code and documentation

## [0.2.4] - 2025-12-27

### Removed

- Redundant PowerShell-specific sections from README (template prompt and example)

## [0.2.3] - 2025-12-27

### Added

- Migration guidance for existing instruction files (CLAUDE.md, .cursorrules, etc.) in deployment prompts

## [0.2.2] - 2025-12-27

### Changed

- Expanded Release Process section in repository-specific instructions with clear triggers,
  semantic versioning guidance, step-by-step process, and checklist

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

[Unreleased]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.9...HEAD
[0.8.9]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.8...v0.8.9
[0.8.8]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.7...v0.8.8
[0.8.7]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.6...v0.8.7
[0.8.6]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.5...v0.8.6
[0.8.5]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.4...v0.8.5
[0.8.4]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.3...v0.8.4
[0.8.3]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.2...v0.8.3
[0.8.2]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.1...v0.8.2
[0.8.1]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.0...v0.8.1
[0.8.0]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.2.4...v0.3.0
[0.2.4]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/tablackburn/ai-agent-instruction-modules/releases/tag/v0.1.0
