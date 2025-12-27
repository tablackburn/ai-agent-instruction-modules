# Contributing to AIM

Thank you for your interest in contributing to AI Agent Instruction Modules!

## Ways to Contribute

### Improving Existing Modules

- Fix errors or outdated information
- Clarify confusing instructions
- Add missing best practices

### Adding New Modules

- Language-specific guidelines
- Framework conventions
- Tool integrations
- Development practices

### Improving Infrastructure

- Script enhancements
- Profile presets
- Documentation

## Contribution Process

1. **Fork the repository**

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow existing patterns and conventions
   - Test your changes locally

4. **Commit with clear messages**
   ```bash
   git commit -m "feat: Add Python type hints module"
   ```

5. **Push and create a Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Module Guidelines

### Frontmatter

Every instruction module must include YAML frontmatter:

```yaml
---
id: category/module-name
name: Human Readable Name
description: Brief description of the module
applyTo: "**/*.ext"
requires: []
recommends: []
tags: ["category", "topic"]
---
```

### Content

- Keep instructions generic and universally applicable
- Use placeholder examples (`<owner>`, `<repo>`, `example.com`)
- Focus on best practices, not specific tools or vendors
- Include code examples where helpful
- Follow Markdown conventions in `styles/markdown.md`

### Testing

Before submitting:

1. Run `build-agents-md.ps1` to verify your module builds correctly
2. Check that frontmatter is valid YAML
3. Verify links and references work

## Code of Conduct

- Be respectful and constructive
- Focus on improving the project
- Help others learn and contribute

## Questions?

Open an issue for questions or discussion.
