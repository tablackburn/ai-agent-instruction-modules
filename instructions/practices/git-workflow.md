---
id: practices/git-workflow
name: Git Workflow
description: Git conventions and workflow guidelines
applyTo: "**/*"
requires: []
recommends: []
tags: ["practice", "git", "workflow"]
---

# Git Workflow Guidelines

Standard Git conventions and best practices.

## Commit Messages

### Format

```
<type>: <subject>

[optional body]

[optional footer]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code restructuring, no behavior change
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Subject Line

- Use imperative mood ("Add feature" not "Added feature")
- Keep under 50 characters
- Don't end with a period
- Capitalize the first letter

### Body

- Wrap at 72 characters
- Explain what and why, not how
- Separate from subject with blank line

### Examples

```
feat: Add user authentication

Implement JWT-based authentication for API endpoints.
Includes login, logout, and token refresh functionality.

Closes #123
```

```
fix: Prevent crash on empty input

Check for null/empty values before processing user input.
```

## Branching Strategy

### Branch Naming

- `main` or `master`: Production-ready code
- `feature/<description>`: New features
- `fix/<description>`: Bug fixes
- `docs/<description>`: Documentation updates
- `refactor/<description>`: Code refactoring

### Examples

```
feature/user-authentication
fix/login-validation-error
docs/api-documentation
```

## Pull Requests

### Before Creating

- Ensure all tests pass
- Update documentation if needed
- Rebase on latest main if behind
- Review your own changes first

### PR Description

- Summarize what changed and why
- Link related issues
- Include testing instructions
- Note any breaking changes

### Review Process

- Address all feedback before merging
- Request re-review after significant changes
- Squash commits if requested
- Delete branch after merging

## Common Operations

### Keeping Branch Updated

```bash
git fetch origin
git rebase origin/main
```

### Amending Last Commit

```bash
git commit --amend
```

Only amend commits that haven't been pushed.

### Interactive Rebase

```bash
git rebase -i HEAD~3  # Last 3 commits
```

Use for cleaning up local history before pushing.

## What Not to Do

- Don't force push to shared branches
- Don't commit secrets or credentials
- Don't commit large binary files
- Don't commit generated files (build outputs, node_modules)
- Don't rewrite published history
