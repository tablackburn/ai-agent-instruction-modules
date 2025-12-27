---
id: core/security
name: Security
description: Security best practices and guidelines
applyTo: "**/*"
requires: []
recommends: []
tags: ["core", "security", "owasp"]
---

# Security Guidelines

## Core Principles

### Defense in Depth

- Never rely on a single security control
- Validate at system boundaries and critical points
- Assume any layer could be bypassed

### Least Privilege

- Request only necessary permissions
- Limit access scope to what's required
- Use time-limited credentials when possible

### Fail Securely

- Default to denying access
- Handle errors without exposing sensitive information
- Log security events appropriately

## Input Validation

### Never Trust User Input

- Validate all input from external sources
- Sanitize data before use in queries or commands
- Use allowlists over denylists when possible

### Prevent Injection Attacks

- SQL: Use parameterized queries, never string concatenation
- Command: Avoid shell execution, use libraries instead
- XSS: Escape output in HTML contexts
- Path: Validate and sanitize file paths

## Secrets Management

### Never Hardcode Secrets

- Use environment variables or secret managers
- Never commit secrets to version control
- Rotate secrets regularly

### Sensitive Files to Exclude

Always add to `.gitignore`:
- `.env` files
- Private keys (`*.pem`, `*.key`)
- Credentials files
- API tokens

### If Secrets Are Committed

1. Revoke the secret immediately
2. Remove from git history if possible
3. Generate new credentials
4. Review access logs for misuse

## Authentication and Authorization

### Password Handling

- Never store plain-text passwords
- Use strong hashing (bcrypt, argon2)
- Enforce minimum password complexity

### Session Management

- Use secure, httpOnly cookies
- Implement session timeouts
- Regenerate session IDs after login

### API Security

- Authenticate all API endpoints
- Use rate limiting
- Validate API tokens on every request

## Data Protection

### Encryption

- Use TLS for data in transit
- Encrypt sensitive data at rest
- Use current cryptographic standards

### Logging

- Never log sensitive data (passwords, tokens, PII)
- Mask or redact sensitive fields
- Retain logs appropriately

## Dependency Security

### Keep Dependencies Updated

- Regularly update dependencies
- Monitor for security advisories
- Use lockfiles for reproducible builds

### Minimize Dependencies

- Only add necessary dependencies
- Prefer well-maintained packages
- Review dependencies before adding

## Common Vulnerabilities (OWASP Top 10)

Be aware of and guard against:

1. **Injection** - SQL, NoSQL, command injection
2. **Broken Authentication** - Weak credentials, session issues
3. **Sensitive Data Exposure** - Unencrypted data, weak crypto
4. **XML External Entities** - XXE attacks
5. **Broken Access Control** - Privilege escalation
6. **Security Misconfiguration** - Default settings, verbose errors
7. **Cross-Site Scripting (XSS)** - Reflected, stored, DOM-based
8. **Insecure Deserialization** - Untrusted data deserialization
9. **Using Components with Known Vulnerabilities** - Outdated deps
10. **Insufficient Logging & Monitoring** - Blind to attacks

## Security Review Checklist

Before deploying code, verify:

- [ ] No hardcoded secrets
- [ ] Input validation in place
- [ ] Parameterized queries used
- [ ] Authentication/authorization checked
- [ ] Sensitive data encrypted
- [ ] Dependencies up to date
- [ ] Error messages don't leak info
- [ ] Logging doesn't capture secrets
