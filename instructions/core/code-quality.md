---
id: core/code-quality
name: Code Quality
description: General code quality guidelines and best practices
applyTo: "**/*"
requires: []
recommends: ["practices/testing"]
tags: ["core", "quality", "best-practices"]
---

# Code Quality Guidelines

## General Principles

### Readability First

- Write code that is easy to read and understand
- Use clear, descriptive names for variables, functions, and classes
- Prefer explicit over implicit behavior
- Add comments only when the code cannot speak for itself

### Keep It Simple

- Avoid over-engineering and premature optimization
- Write the simplest code that solves the problem
- Don't add abstractions until they're needed
- Three similar lines is better than a premature abstraction

### Consistency

- Follow existing patterns in the codebase
- Match the style of surrounding code
- Use consistent naming conventions throughout

## Naming Conventions

### Variables and Functions

- Use descriptive names that convey purpose
- Avoid abbreviations unless universally understood
- Use consistent casing per language conventions:
  - JavaScript/TypeScript: camelCase for variables/functions, PascalCase for classes
  - Python: snake_case for variables/functions, PascalCase for classes
  - Go: camelCase for private, PascalCase for public

### Files and Directories

- Use lowercase with hyphens for file names when possible
- Group related files in descriptive directories
- Match file names to their primary export when applicable

## Code Structure

### Functions and Methods

- Keep functions focused on a single responsibility
- Limit function length (aim for under 30 lines)
- Limit parameters (3-4 maximum, use objects for more)
- Return early to reduce nesting

### Error Handling

- Handle errors at appropriate levels
- Provide meaningful error messages
- Don't swallow errors silently
- Use typed errors when the language supports it

### Comments

- Explain "why" not "what"
- Keep comments up to date with code changes
- Use documentation comments for public APIs
- Delete commented-out code

## Code Review Readiness

Before submitting code:

- Run all tests and ensure they pass
- Check for linting errors
- Review your own diff first
- Ensure commit messages are clear and descriptive

## Anti-Patterns to Avoid

- Magic numbers and strings (use constants)
- Deep nesting (refactor to reduce complexity)
- God objects/functions (break into smaller pieces)
- Copy-paste programming (extract shared logic)
- Premature optimization (profile first)
