---
applyTo: '**/*'
description: 'Procedures for updating AI agent instructions from the centralized repository'
---

# Update Instructions for AI Agents

These instructions are self-contained for update procedures but assume familiarity with Git. For general workflow guidance, see agent-workflow.instructions.md.

When updating AI agent instructions in a repository that uses AIM, AI agents should:

1. **Clone the centralized instructions repository** from GitHub
   - Clone the repository to the current working directory: `git clone https://github.com/tablackburn/ai-agent-instruction-modules.git`
   - Use `AGENTS.template.md` from the cloned repository, NOT `AGENTS.md`
   - The file `AGENTS.md` in the centralized repository is that repository's own implementation
   - The file `AGENTS.template.md` is the template for downstream repositories
   - **Remove the HTML comment block** at the top of the fetched template (the comment that starts with `<!-- THIS IS THE TEMPLATE FILE`)
   - **Immediately clean up**: Remove the cloned repository folder after files have been copied
   - Use `Remove-Item -Recurse -Force` (PowerShell) or `rm -rf` (bash) to ensure complete cleanup
   - Verify the cloned folder is removed to prevent confusion from nested Git repositories

2. **Check for existing repository-specific content** in the current AGENTS.md file
3. **Preserve any "Repository-Specific" sections** from the existing file
4. **Update the sync date and template version** in the header
5. **Merge preserved content** back into the updated instructions
6. **Replace the AGENTS.md file** with the updated content
7. **Sync the instructions folder** by copying all files from the centralized repository's instructions directory to the local instructions directory, overwriting existing files EXCEPT repository-specific.instructions.md (never copy or overwrite that file - it is unique to each downstream repository)
8. **Perform structural validation** to ensure the downstream repository matches the upstream structure

## Handling Breaking Changes

When upstream structural changes occur (e.g., renamed files, moved directories, or removed components), AI agents should:

- Review the upstream changelog for any noted breaking changes or structural updates
- Clone the upstream repository and compare files between the current downstream version and the latest upstream version
- Prioritize matching the upstream structure exactly, even if it requires significant downstream reorganization
- Document any repository-specific customizations that conflict with upstream changes and resolve them by adapting to the new structure
- If a file is renamed upstream, rename the corresponding downstream file and update all references accordingly

## Sync Checklist

- [ ] AGENTS.md content fetched and updated from centralized repository
- [ ] Template version and sync date updated to current date
- [ ] Repository-specific sections preserved from existing file
- [ ] Instructions/ folder synced, overwriting existing files except repository-specific.instructions.md
- [ ] Structural validation completed: downstream file structure matches upstream
- [ ] Validation completed: all expected files from centralized instructions/ folder are present locally

## Content Preservation Rules

- Repository-specific sections (starting with "## Repository-Specific") should be preserved
- The file repository-specific.instructions.md must NEVER be copied from the centralized repository or overwritten during sync - it is unique to each downstream repository
- Template sync date should be updated to current date
- Template version should match the centralized repository version
- Provide user feedback when repository-specific content is found and preserved

## Validation Steps Post-Sync

1. List all files in the local instructions directory
2. Compare the list against the expected files from the centralized repository
3. Ensure all files from the centralized repository have been copied EXCEPT repository-specific.instructions.md
4. Verify that file names and structure match the upstream repository exactly
5. If any files are missing or structural mismatches exist, re-run the sync process

## After Update

The AI agent will have access to:

- Code quality and security guidelines
- Language-specific coding standards (PowerShell, etc.)
- Git workflow and GitHub CLI best practices
- Markdown formatting standards
- Repository-specific customizations

## Version Tracking

- Track template version to know what features are available
- Sync awareness - easily see if updates are needed
- Change management - follow semantic versioning for impact assessment
