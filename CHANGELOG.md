# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/tablackburn/ai-agent-instruction-modules/releases/tag/v0.1.0
