# AI Agent Instructions

<!-- THIS IS THE TEMPLATE FILE for downstream repositories.
     When deploying to a repository, DELETE THIS COMMENT.
     When updating instructions from the centralized repository, fetch THIS file (AGENTS.template.md).
     DO NOT fetch AGENTS.md from the template repository - that's the template repository's own implementation. -->

AI agents working in this repository must follow these instructions.

Template Version: 0.2.2

Last sync: YYYY-MM-DD (Update this date when syncing from the centralized repository)

## Instructions for AI Agents

AI agents **must**:

1. **When deploying or updating this template, follow `instructions/update.instructions.md` and update the Last sync date above.**

2. **Read `instructions/agent-workflow.instructions.md` FIRST to determine which other instruction files apply to your task.** Follow all applicable instructions before proceeding with work.

## Instruction Applicability Matrix

Use this matrix to determine which instruction files to read based on your task:

| Task Type | Required Instructions |
|-----------|----------------------|
| Any task | `agent-workflow.instructions.md` |
| PowerShell code | `powershell.instructions.md` |
| Documentation | `markdown.instructions.md` |
| GitHub CLI usage | `github-cli.instructions.md` |
| Repository-specific work | `repository-specific.instructions.md` |
| Updating instructions | `update.instructions.md` |

## Available Instruction Files

- `agent-workflow.instructions.md` - Pre-flight protocol and task workflow
- `powershell.instructions.md` - PowerShell coding standards
- `markdown.instructions.md` - Markdown formatting standards
- `github-cli.instructions.md` - GitHub CLI usage guidelines
- `repository-specific.instructions.md` - Repository-specific customizations
- `update.instructions.md` - Procedures for updating instructions

## Quick Reference

### Before Starting Any Task

1. Identify the task type from the matrix above
2. Read all applicable instruction files
3. Follow the guidelines when implementing

### Best Practices

- Follow existing patterns in the codebase
- Keep solutions simple and focused
- Only make changes that are directly requested
- Follow language-specific guidelines

## Repository-Specific Instructions

See `instructions/repository-specific.instructions.md` for customizations specific to this repository.
