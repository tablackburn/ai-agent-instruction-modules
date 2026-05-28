# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.11.0] - 2026-05-28

### Added

- "Pester" section in `powershell.instructions.md` - documents that `Set-ItResult -Skipped` and
  `-Inconclusive` end the `It` block by throwing internally, so code after them (including a
  trailing `return`) is unreachable dead code, and that `-Skip:$condition` is preferred for
  discovery-time skips while `Set-ItResult` is reserved for runtime conditions. Mirrored into both
  `instruction-templates/` and `instructions/`

## [0.10.0] - 2026-05-25

### Changed

- Reframed the `skills` configuration block from "declare a dependency, install per-agent" (0.9.0)
  to vendoring: AIM now copies each declared Agent Skill verbatim into `skills.vendorPath`
  (default `.agents/skills/`, the cross-client [Agent Skills](https://agentskills.io) convention)
  so skills travel with the repository like instruction modules instead of being installed into
  each developer's agent. Skills are routed from the `AGENTS.md` Instruction Applicability Matrix
  to their `SKILL.md`, and a `CLAUDE.md` that imports `AGENTS.md` (`@AGENTS.md`) carries that
  routing into Claude Code, which reads `CLAUDE.md` and does not scan `AGENTS.md` or
  `.agents/skills/`. Verified empirically against Claude Code 2.1.150: `.agents/skills/` is not
  discovered natively, the `.claude/skills/` control is, and the `@AGENTS.md` bridge surfaces the
  vendored skill on demand
- `update.instructions.md` step 7 ("Handle Skill Dependencies") rewritten for the vendoring flow:
  resolve `source` at the pinned `version`, copy the skill folder to `<vendorPath>/<name>/` with
  confirm-before-overwrite, record attribution in `<vendorPath>/NOTICE.md`, add the matrix row, and
  ensure the `CLAUDE.md` `@AGENTS.md` bridge. Mirrored into both `instruction-templates/` and
  `instructions/`

### Added

- `skills.vendorPath` config field (default `.agents/skills`) and per-dependency `version` for
  pinning and re-syncing the vendored skill from upstream. Reflected in `aim.config.json.example`,
  `AGENTS.template.md`, `AGENTS.md`, and the README `Configuration` and `Skill Dependencies`
  sections

## [0.9.0] - 2026-05-25

### Added

- `skills` configuration block in `aim.config.json` for declaring Agent Skill (SKILL.md /
  agentskills.io) dependencies a repository expects. Skills are declared agent-neutrally
  (`source` repo + `path` to the skill folder + `format`), and installed through the agent's own
  mechanism rather than copied into `instructions/`: cross-agent `npx skills add <source>/<path>`,
  manual copy of the skill folder at `<path>` (containing `SKILL.md`), or the Claude Code plugin
  CLI as an agent-specific convenience. Adds a "Handle Skill Dependencies" step (with
  confirm-before-install) to
  `update.instructions.md`, schema/field docs, a sync-checklist item, and a "Skill Dependencies"
  section in `AGENTS.template.md`. Mirrored into both `instruction-templates/` and `instructions/`

## [0.8.15] - 2026-05-25

### Fixed

- `powershell.instructions.md` "Parameters" rule 1 ("Use full parameter names") read as an
  absolute, which over-applied to single-argument calls and prompted over-naming such as
  `Test-Path -Path $path`. Scoped the rule to calls with two or more arguments; single-argument
  calls may stay positional. Added examples and retuned the quoting example to a positional
  single-argument call for consistency. Mirrored into both `instruction-templates/` and `instructions/`

## [0.8.14] - 2026-05-16

### Fixed

- `contributing.instructions.md` "Make Changes" section pointed contributors at the wrong
  folder for new instruction files (`instructions/` instead of `instruction-templates/`),
  contradicting `CONTRIBUTING.md` and the README's folder description. Following the bad
  guidance landed new modules in the dogfood mirror where downstream sync workflows would
  not pick them up. Fix mirrored into both `instruction-templates/` and `instructions/`.
  Surfaced during Copilot review of `psake/PowerShellBuild#122`
- `github-cli.instructions.md` "Creating Releases" example used `gh release create --notes`,
  contradicting `releases.instructions.md` which mandates `--notes-file` to avoid escaping
  issues with backticks, backslashes, and quotes. Replaced the example with a temp-file
  pattern and added an explicit note that `releases.instructions.md` takes precedence for
  project releases. Mirrored into both `instruction-templates/` and `instructions/`
- Sync drift in `instruction-templates/shorthand.instructions.md` (downstream-distributed
  template was missing the `Dir → Directory` row added in 0.8.12 to the active copy).
  Backfilled to bring the template in line with `instructions/shorthand.instructions.md`

## [0.8.13] - 2026-05-06

### Added

- "Line Continuation" section in `powershell.instructions.md` - forbids backtick (`` ` ``) line
  continuation (hard to spot, breaks silently with trailing whitespace) and semicolon-chained
  statements; points at splatting, parenthesized continuation, pipe-at-end-of-line, and one
  hashtable-element-per-line as the preferred alternatives. Includes an explicit Good example
  showing `for`-loop syntactic semicolons (`for ($i = 0; $i -lt 10; $i++)`) as a carve-out
  from the no-chaining rule
- Cross-reference in `markdown.instructions.md` Code Blocks section pointing readers to the
  relevant language's instruction file (e.g., `powershell.instructions.md`) for code-block
  content conventions, so PowerShell snippets in markdown follow the PowerShell rules without
  needing to broaden the PowerShell module's `applyTo` glob

### Changed

- Revised "Path vs Directory Naming" subsection in `powershell.instructions.md` - `Path` suffix
  is now recommended for any variable holding a path string (file or folder); `Directory` is
  reserved for directory objects (e.g., `[System.IO.DirectoryInfo]`) or bare folder names. Aligns
  with Microsoft's cmdlet design guidance (`-Path` is the canonical parameter name for "a file or
  a data source") and the dominant convention in PowerShell Core, PSReadLine, Pester, and dbatools
- Renamed `$backupDirectory` → `$backupPath` and `$documentsDirectory` → `$documentsPath` in
  `powershell.instructions.md` examples to follow the revised naming rule
- Audited remaining "Good" code examples in `powershell.instructions.md` against the file's own
  rules and updated each one for full compliance: `$parameters` → `$invokeRestMethodParameters`
  in Formatting splatting (descriptive name); `$options` → `$webRequestOptions` in the hashtable
  formatting example (descriptive name); `Process-Item $item` → `Format-Item -InputObject $item`
  in Output (approved verb + named parameter); added `[OutputType([psobject])]`,
  `[ValidateNotNull()]`, and `[psobject]` to Format-Result helper; added `[ValidateNotNull()]`
  to Get-Setting's `$Configuration` parameter; updated Line Continuation rule #2 reference
  from `@parameters` to `@copyItemParameters` to match the example below the rules
- Consolidated the standalone "Semicolons" section in `powershell.instructions.md` into "Line
  Continuation" - both forbid the same anti-pattern (chained statements via `;`), so the
  hashtable element rule and Good/Bad examples now appear within Line Continuation alongside
  the backtick guidance instead of as a separate section

### Fixed

- Sync drift in `instruction-templates/powershell.instructions.md` (downstream-distributed
  template was behind active copy after 0.8.12): added "Path vs Directory Naming" subsection;
  added `$backupPath` predefinition in Naming Conventions example; renamed `$configPath` →
  `$configurationPath` and `$userPath` → `$documentsPath` in Paths examples; added `$filePath`
  predefinition and quoted `'Stop'` in Error Handling example

## [0.8.12] - 2026-01-14

### Added

- `Dir` → `Directory` mapping in `shorthand.instructions.md` abbreviations table
- "Directory vs Path Naming" subsection in `powershell.instructions.md` - guidance for when to use
  `Path` suffix (file paths), `Directory` suffix (folders), or neutral names (intentionally flexible)

### Changed

- Updated "Paths and File System" section in `powershell.instructions.md` to use consistent naming
  (`$configurationPath`, `$documentsDirectory`) aligned with new Directory vs Path guidance
- Defined `$backupDirectory` and `$filePath` variables before use in PowerShell examples

## [0.8.11] - 2026-01-11

### Added

- "Working on Branches" section in `git-workflow.instructions.md` - agents must always work on
  branches, never directly on main
- "After Creating a PR" section in `git-workflow.instructions.md` - agents should monitor CI, check
  for comments, address feedback, and report status before merging
- Expanded branch naming conventions with table of branch types, ticket number format, best
  practices, and technical constraints

### Changed

- Simplify `releases.instructions.md` pre-release checklist to reference general git workflow
  instead of duplicating branching and PR steps

## [0.8.10] - 2026-01-10

### Added

- Nested function avoidance guideline in `powershell.instructions.md` - define helper functions at
  module or script scope rather than inside other functions

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

[Unreleased]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.11.0...HEAD
[0.11.0]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.10.0...v0.11.0
[0.10.0]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.15...v0.9.0
[0.8.15]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.14...v0.8.15
[0.8.14]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.13...v0.8.14
[0.8.13]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.12...v0.8.13
[0.8.12]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.11...v0.8.12
[0.8.11]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.10...v0.8.11
[0.8.10]: https://github.com/tablackburn/ai-agent-instruction-modules/compare/v0.8.9...v0.8.10
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
