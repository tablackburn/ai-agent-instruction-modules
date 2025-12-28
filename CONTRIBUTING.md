# Contributing to AIM

Thank you for your interest in contributing to AI Agent Instruction Modules!

## Ways to Contribute

### Improving Existing Modules

- Fix errors or outdated information
- Clarify confusing instructions
- Add missing best practices

### Adding New Modules

- Language-specific guidelines (Python, TypeScript, Go, Rust, C#)
- Framework conventions (React, FastAPI, ASP.NET, Django)
- Tool integrations (Docker, Terraform, Kubernetes)
- Development practices

### Improving Documentation

- README improvements
- Changelog updates
- Example enhancements

## Contribution Process

1. **Fork the repository**

   ```bash
   gh repo fork tablackburn/ai-agent-instruction-modules --clone
   cd ai-agent-instruction-modules
   ```

1. **Create a feature branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

1. **Make your changes**
   - Follow existing patterns and conventions
   - Test your changes locally

1. **Run tests**

   ```powershell
   Invoke-Pester -Path .\tests\
   ```

1. **Commit with conventional commits**

   ```bash
   git commit -m "feat: Add Python type hints module"
   ```

1. **Push and create a Pull Request**

   ```bash
   git push origin feature/your-feature-name
   gh pr create
   ```

## Module Guidelines

### Frontmatter

Every instruction module must include YAML frontmatter:

```yaml
---
applyTo: '**/*.py'
description: 'Brief description of the module'
---
```

**Required fields:**

- `applyTo` - Glob pattern for applicable files
- `description` - One-line description of the module's purpose

### Content

- Keep instructions generic and universally applicable
- Use placeholder examples (`<owner>`, `<repo>`, `example.com`)
- Focus on best practices, not specific tools or vendors
- Include code examples where helpful
- Follow Markdown conventions in `markdown.instructions.md`

### File Naming

- Use `.instructions.md` extension
- Use lowercase with hyphens (e.g., `python-typing.instructions.md`)
- Place files in the `instruction-templates/` folder

### Testing

Before submitting:

1. Run `Invoke-Pester -Path .\tests\` to verify all tests pass
1. Check that frontmatter is valid YAML with required fields
1. Verify links and references work

## Code of Conduct

- Be respectful and constructive
- Focus on improving the project
- Help others learn and contribute

## Questions?

Open an issue for questions or discussion.
