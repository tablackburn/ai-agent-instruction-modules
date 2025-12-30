Describe 'AI Agent Instructions Validation' {

    BeforeAll {
        # File paths
        $script:repoRoot = Join-Path -Path $PSScriptRoot -ChildPath '..'
        $script:templateFilePath = Join-Path -Path $script:repoRoot -ChildPath 'AGENTS.template.md'
        $script:agentsFilePath = Join-Path -Path $script:repoRoot -ChildPath 'AGENTS.md'
        $script:changelogFilePath = Join-Path -Path $script:repoRoot -ChildPath 'CHANGELOG.md'
        $script:instructionsPath = Join-Path -Path $script:repoRoot -ChildPath 'instructions'
        $script:instructionTemplatesPath = Join-Path -Path $script:repoRoot -ChildPath 'instruction-templates'
        $script:configFilePath = Join-Path -Path $script:repoRoot -ChildPath 'aim.config.json'
        $script:configExamplePath = Join-Path -Path $script:repoRoot -ChildPath 'aim.config.json.example'

        # Check file existence
        $script:templateFileExists = Test-Path -Path $script:templateFilePath
        $script:agentsFileExists = Test-Path -Path $script:agentsFilePath
        $script:changelogFileExists = Test-Path -Path $script:changelogFilePath
        $script:configFileExists = Test-Path -Path $script:configFilePath
        $script:configExampleExists = Test-Path -Path $script:configExamplePath

        # Regular expression patterns
        $script:templateVersionPattern = '(?im)^\s*[>*\s-]*\**Template Version\**\s*[::]?\s*([\d]+\.[\d]+\.[\d]+)'
        $script:lastSyncPattern = '(?im)^\s*[>*\s-]*\**Last sync\**\s*[::]?\s*(\d{4}-\d{2}-\d{2})'
        $script:changelogVersionPattern = '(?m)^## \[([\d]+\.[\d]+\.[\d]+)\]'
        $script:changelogDatePattern = '## \[[\d]+\.[\d]+\.[\d]+\] - \d{4}-\d{2}-\d{2}'
        $script:changelogSectionPattern = '### (Added|Changed|Deprecated|Removed|Fixed|Security)'

        # Read file contents
        if ($script:templateFileExists) {
            $script:templateContent = Get-Content -Path $script:templateFilePath -Raw
        }
        if ($script:agentsFileExists) {
            $script:agentsContent = Get-Content -Path $script:agentsFilePath -Raw
        }
        if ($script:changelogFileExists) {
            $script:changelogContent = Get-Content -Path $script:changelogFilePath -Raw
        }
        if ($script:configFileExists) {
            $script:configContent = Get-Content -Path $script:configFilePath -Raw
            $script:config = $script:configContent | ConvertFrom-Json
        }
        if ($script:configExampleExists) {
            $script:configExampleContent = Get-Content -Path $script:configExamplePath -Raw
            $script:configExample = $script:configExampleContent | ConvertFrom-Json
        }

        # Extract versions
        if ($script:templateContent -and $script:templateContent -match $script:templateVersionPattern) {
            $script:templateVersion = $matches[1]
        }
        if ($script:agentsContent -and $script:agentsContent -match $script:templateVersionPattern) {
            $script:agentsVersion = $matches[1]
        }
        if ($script:changelogContent -and $script:changelogContent -match $script:changelogVersionPattern) {
            $script:changelogVersion = $matches[1]
        }
    }

    Context 'File Existence' {

        It 'AGENTS.template.md exists' {
            Test-Path -Path $script:templateFilePath | Should -BeTrue
        }

        It 'AGENTS.md exists' {
            Test-Path -Path $script:agentsFilePath | Should -BeTrue
        }

        It 'CHANGELOG.md exists' {
            Test-Path -Path $script:changelogFilePath | Should -BeTrue
        }

        It 'instructions folder exists' {
            Test-Path -Path $script:instructionsPath | Should -BeTrue
        }

        It 'instruction-templates folder exists' {
            Test-Path -Path $script:instructionTemplatesPath | Should -BeTrue
        }

        It 'aim.config.json exists' {
            Test-Path -Path $script:configFilePath | Should -BeTrue
        }

        It 'aim.config.json.example exists' {
            Test-Path -Path $script:configExamplePath | Should -BeTrue
        }
    }

    Context 'Instruction Template Files' {

        It 'agent-workflow.instructions.md exists in instruction-templates' {
            $filePath = Join-Path -Path $script:instructionTemplatesPath -ChildPath 'agent-workflow.instructions.md'
            Test-Path -Path $filePath | Should -BeTrue
        }

        It 'update.instructions.md exists in instruction-templates' {
            $filePath = Join-Path -Path $script:instructionTemplatesPath -ChildPath 'update.instructions.md'
            Test-Path -Path $filePath | Should -BeTrue
        }

        It 'repository-specific.instructions.md exists in instruction-templates' {
            $filePath = Join-Path -Path $script:instructionTemplatesPath -ChildPath 'repository-specific.instructions.md'
            Test-Path -Path $filePath | Should -BeTrue
        }

        It 'All instruction template files have .instructions.md extension' {
            $invalidFiles = Get-ChildItem -Path $script:instructionTemplatesPath -Filter '*.md' |
                Where-Object { $_.Name -notmatch '\.instructions\.md$' }
            $invalidFiles | Should -BeNullOrEmpty -Because 'All markdown files in instruction-templates/ should use .instructions.md extension'
        }

        It 'All instruction template files have YAML frontmatter' {
            $instructionFiles = Get-ChildItem -Path $script:instructionTemplatesPath -Filter '*.instructions.md'
            foreach ($file in $instructionFiles) {
                $content = Get-Content -Path $file.FullName -Raw
                $content | Should -Match '^---\r?\n' -Because "$($file.Name) should start with YAML frontmatter"
            }
        }

        It 'All instruction template files have applyTo in frontmatter' {
            $instructionFiles = Get-ChildItem -Path $script:instructionTemplatesPath -Filter '*.instructions.md'
            foreach ($file in $instructionFiles) {
                $content = Get-Content -Path $file.FullName -Raw
                $content | Should -Match 'applyTo:' -Because "$($file.Name) should have applyTo in frontmatter"
            }
        }

        It 'All instruction template files have description in frontmatter' {
            $instructionFiles = Get-ChildItem -Path $script:instructionTemplatesPath -Filter '*.instructions.md'
            foreach ($file in $instructionFiles) {
                $content = Get-Content -Path $file.FullName -Raw
                $content | Should -Match 'description:' -Because "$($file.Name) should have description in frontmatter"
            }
        }
    }

    Context 'Active Instruction Files' {

        It 'agent-workflow.instructions.md exists in instructions' {
            $filePath = Join-Path -Path $script:instructionsPath -ChildPath 'agent-workflow.instructions.md'
            Test-Path -Path $filePath | Should -BeTrue
        }

        It 'update.instructions.md exists in instructions' {
            $filePath = Join-Path -Path $script:instructionsPath -ChildPath 'update.instructions.md'
            Test-Path -Path $filePath | Should -BeTrue
        }

        It 'All active instruction files have .instructions.md extension' {
            $invalidFiles = Get-ChildItem -Path $script:instructionsPath -Filter '*.md' |
                Where-Object { $_.Name -notmatch '\.instructions\.md$' }
            $invalidFiles | Should -BeNullOrEmpty -Because 'All markdown files in instructions/ should use .instructions.md extension'
        }

        It 'All active instruction files have YAML frontmatter' {
            $instructionFiles = Get-ChildItem -Path $script:instructionsPath -Filter '*.instructions.md'
            foreach ($file in $instructionFiles) {
                $content = Get-Content -Path $file.FullName -Raw
                $content | Should -Match '^---\r?\n' -Because "$($file.Name) should start with YAML frontmatter"
            }
        }
    }

    Context 'Configuration Schema' {

        It 'aim.config.json is valid JSON' {
            if (-not $script:configFileExists) {
                Set-ItResult -Skipped -Because 'Config file does not exist'
                return
            }
            { $script:configContent | ConvertFrom-Json } | Should -Not -Throw
        }

        It 'aim.config.json has version field' {
            if (-not $script:configFileExists) {
                Set-ItResult -Skipped -Because 'Config file does not exist'
                return
            }
            $script:config.version | Should -Not -BeNullOrEmpty
        }

        It 'aim.config.json has modules field' {
            if (-not $script:configFileExists) {
                Set-ItResult -Skipped -Because 'Config file does not exist'
                return
            }
            $script:config.modules | Should -Not -BeNull
        }

        It 'aim.config.json has modules.include field' {
            if (-not $script:configFileExists) {
                Set-ItResult -Skipped -Because 'Config file does not exist'
                return
            }
            $script:config.modules.include | Should -Not -BeNullOrEmpty
        }

        It 'aim.config.json has externalSources field' {
            if (-not $script:configFileExists) {
                Set-ItResult -Skipped -Because 'Config file does not exist'
                return
            }
            $script:config.externalSources | Should -Not -BeNull
        }

        It 'aim.config.json.example is valid JSON' {
            if (-not $script:configExampleExists) {
                Set-ItResult -Skipped -Because 'Config example file does not exist'
                return
            }
            { $script:configExampleContent | ConvertFrom-Json } | Should -Not -Throw
        }

        It 'aim.config.json.example has externalSources.enabled set to true' {
            if (-not $script:configExampleExists) {
                Set-ItResult -Skipped -Because 'Config example file does not exist'
                return
            }
            $script:configExample.externalSources.enabled | Should -BeTrue
        }

        It 'aim.config.json.example has awesome-copilot in repositories' {
            if (-not $script:configExampleExists) {
                Set-ItResult -Skipped -Because 'Config example file does not exist'
                return
            }
            $awesomeCopilot = $script:configExample.externalSources.repositories | Where-Object { $_.name -eq 'awesome-copilot' }
            $awesomeCopilot | Should -Not -BeNull
            $awesomeCopilot.url | Should -Be 'https://github.com/github/awesome-copilot'
        }
    }

    Context 'Version Consistency' {

        It 'AGENTS.template.md contains valid version number' {
            if (-not $script:templateFileExists) {
                Set-ItResult -Skipped -Because 'Template file does not exist'
                return
            }
            $script:templateVersion | Should -Not -BeNullOrEmpty
        }

        It 'AGENTS.md contains valid version number' {
            if (-not $script:agentsFileExists) {
                Set-ItResult -Skipped -Because 'AGENTS.md does not exist'
                return
            }
            $script:agentsVersion | Should -Not -BeNullOrEmpty
        }

        It 'CHANGELOG.md contains valid version number' {
            if (-not $script:changelogFileExists) {
                Set-ItResult -Skipped -Because 'Changelog does not exist'
                return
            }
            $script:changelogVersion | Should -Not -BeNullOrEmpty
        }

        It 'Template version matches AGENTS.md version' {
            if (-not ($script:templateFileExists -and $script:agentsFileExists)) {
                Set-ItResult -Skipped -Because 'Required files do not exist'
                return
            }
            $script:agentsVersion | Should -Be $script:templateVersion
        }

        It 'Template version matches latest changelog version' {
            if (-not ($script:templateFileExists -and $script:changelogFileExists)) {
                Set-ItResult -Skipped -Because 'Required files do not exist'
                return
            }
            $script:templateVersion | Should -Be $script:changelogVersion
        }
    }

    Context 'Changelog Format' {

        It 'Changelog contains version entry with date' {
            if (-not $script:changelogFileExists) {
                Set-ItResult -Skipped -Because 'Changelog does not exist'
                return
            }
            $script:changelogContent | Should -Match $script:changelogDatePattern
        }

        It 'Changelog contains standard sections' {
            if (-not $script:changelogFileExists) {
                Set-ItResult -Skipped -Because 'Changelog does not exist'
                return
            }
            $script:changelogContent | Should -Match $script:changelogSectionPattern
        }
    }

    Context 'AGENTS.md Sync' {

        It 'AGENTS.md contains last sync date' {
            if (-not $script:agentsFileExists) {
                Set-ItResult -Skipped -Because 'AGENTS.md does not exist'
                return
            }
            $script:agentsContent | Should -Match $script:lastSyncPattern
        }

        It 'AGENTS.md last sync date is valid format' {
            if (-not $script:agentsFileExists) {
                Set-ItResult -Skipped -Because 'AGENTS.md does not exist'
                return
            }
            if ($script:agentsContent -match $script:lastSyncPattern) {
                $syncDate = $matches[1]
                { [DateTime]::ParseExact($syncDate, 'yyyy-MM-dd', $null) } | Should -Not -Throw
            }
        }

        It 'AGENTS.md references agent-workflow.instructions.md' {
            if (-not $script:agentsFileExists) {
                Set-ItResult -Skipped -Because 'AGENTS.md does not exist'
                return
            }
            $script:agentsContent | Should -Match 'agent-workflow\.instructions\.md'
        }

        It 'AGENTS.template.md references agent-workflow.instructions.md' {
            if (-not $script:templateFileExists) {
                Set-ItResult -Skipped -Because 'Template does not exist'
                return
            }
            $script:templateContent | Should -Match 'agent-workflow\.instructions\.md'
        }

        It 'AGENTS.md references aim.config.json' {
            if (-not $script:agentsFileExists) {
                Set-ItResult -Skipped -Because 'AGENTS.md does not exist'
                return
            }
            $script:agentsContent | Should -Match 'aim\.config\.json'
        }
    }

    Context 'Content Validation - Heading Structure' {

        It 'All instruction templates have a level 1 heading after frontmatter' {
            $instructionFiles = Get-ChildItem -Path $script:instructionTemplatesPath -Filter '*.instructions.md'
            foreach ($file in $instructionFiles) {
                $content = Get-Content -Path $file.FullName -Raw
                # Remove YAML frontmatter and check for H1
                $contentAfterFrontmatter = $content -replace '^---[\s\S]*?---\r?\n', ''
                $contentAfterFrontmatter | Should -Match '^\s*# ' -Because "$($file.Name) should have a level 1 heading after frontmatter"
            }
        }

        It 'All instruction templates have no skipped heading levels' {
            $instructionFiles = Get-ChildItem -Path $script:instructionTemplatesPath -Filter '*.instructions.md'
            foreach ($file in $instructionFiles) {
                $content = Get-Content -Path $file.FullName
                $previousLevel = 0
                $lineNumber = 0
                $inCodeBlock = $false
                foreach ($line in $content) {
                    $lineNumber++
                    # Track code block state
                    if ($line -match '^```') {
                        $inCodeBlock = -not $inCodeBlock
                        continue
                    }
                    # Skip lines inside code blocks
                    if ($inCodeBlock) { continue }
                    if ($line -match '^(#{1,6})\s+\S') {
                        $currentLevel = $matches[1].Length
                        # Allow going from any level to a lower level (e.g., ### to ##)
                        # Only check for skips when going deeper (e.g., # to ### skips ##)
                        if ($currentLevel -gt $previousLevel -and $currentLevel -gt ($previousLevel + 1) -and $previousLevel -gt 0) {
                            throw "$($file.Name) line $lineNumber skips heading level (from H$previousLevel to H$currentLevel)"
                        }
                        $previousLevel = $currentLevel
                    }
                }
            }
        }

        It 'All active instructions have a level 1 heading after frontmatter' {
            $instructionFiles = Get-ChildItem -Path $script:instructionsPath -Filter '*.instructions.md'
            foreach ($file in $instructionFiles) {
                $content = Get-Content -Path $file.FullName -Raw
                $contentAfterFrontmatter = $content -replace '^---[\s\S]*?---\r?\n', ''
                $contentAfterFrontmatter | Should -Match '^\s*# ' -Because "$($file.Name) should have a level 1 heading after frontmatter"
            }
        }

        It 'All active instructions have no skipped heading levels' {
            $instructionFiles = Get-ChildItem -Path $script:instructionsPath -Filter '*.instructions.md'
            foreach ($file in $instructionFiles) {
                $content = Get-Content -Path $file.FullName
                $previousLevel = 0
                $lineNumber = 0
                $inCodeBlock = $false
                foreach ($line in $content) {
                    $lineNumber++
                    if ($line -match '^```') {
                        $inCodeBlock = -not $inCodeBlock
                        continue
                    }
                    if ($inCodeBlock) { continue }
                    if ($line -match '^(#{1,6})\s+\S') {
                        $currentLevel = $matches[1].Length
                        if ($currentLevel -gt $previousLevel -and $currentLevel -gt ($previousLevel + 1) -and $previousLevel -gt 0) {
                            throw "$($file.Name) line $lineNumber skips heading level (from H$previousLevel to H$currentLevel)"
                        }
                        $previousLevel = $currentLevel
                    }
                }
            }
        }
    }

    Context 'Content Validation - Internal Links' {

        It 'All internal file references in instruction templates point to existing files' {
            $instructionFiles = Get-ChildItem -Path $script:instructionTemplatesPath -Filter '*.instructions.md'
            foreach ($file in $instructionFiles) {
                $content = Get-Content -Path $file.FullName -Raw
                # Match markdown links to .md files: [text](file.md) or [text](./file.md)
                $linkPattern = '\[([^\]]+)\]\(\.?/?([^)]+\.md)\)'
                $matches = [regex]::Matches($content, $linkPattern)
                foreach ($match in $matches) {
                    $linkedFile = $match.Groups[2].Value
                    # Skip external URLs
                    if ($linkedFile -match '^https?://') { continue }
                    # Check relative to instruction-templates folder
                    $fullPath = Join-Path -Path $script:instructionTemplatesPath -ChildPath $linkedFile
                    if (-not (Test-Path -Path $fullPath)) {
                        # Also check relative to repo root
                        $fullPath = Join-Path -Path $script:repoRoot -ChildPath $linkedFile
                    }
                    Test-Path -Path $fullPath | Should -BeTrue -Because "$($file.Name) references '$linkedFile' which should exist"
                }
            }
        }

        It 'All internal file references in AGENTS.md point to existing files' {
            if (-not $script:agentsFileExists) {
                Set-ItResult -Skipped -Because 'AGENTS.md does not exist'
                return
            }
            $linkPattern = '\[([^\]]+)\]\(\.?/?([^)]+\.md)\)'
            $matches = [regex]::Matches($script:agentsContent, $linkPattern)
            foreach ($match in $matches) {
                $linkedFile = $match.Groups[2].Value
                if ($linkedFile -match '^https?://') { continue }
                $fullPath = Join-Path -Path $script:repoRoot -ChildPath $linkedFile
                Test-Path -Path $fullPath | Should -BeTrue -Because "AGENTS.md references '$linkedFile' which should exist"
            }
        }
    }

    Context 'Content Validation - Code Blocks' {

        It 'All code blocks in instruction templates have language specifiers' {
            $instructionFiles = Get-ChildItem -Path $script:instructionTemplatesPath -Filter '*.instructions.md'
            foreach ($file in $instructionFiles) {
                $content = Get-Content -Path $file.FullName
                $lineNumber = 0
                $inCodeBlock = $false
                foreach ($line in $content) {
                    $lineNumber++
                    if ($line -match '^```(\S*)') {
                        if (-not $inCodeBlock) {
                            $language = $matches[1]
                            if ([string]::IsNullOrWhiteSpace($language)) {
                                throw "$($file.Name) line $lineNumber has a code block without a language specifier"
                            }
                            $inCodeBlock = $true
                        } else {
                            $inCodeBlock = $false
                        }
                    }
                }
            }
        }

        It 'All code blocks in active instructions have language specifiers' {
            $instructionFiles = Get-ChildItem -Path $script:instructionsPath -Filter '*.instructions.md'
            foreach ($file in $instructionFiles) {
                $content = Get-Content -Path $file.FullName
                $lineNumber = 0
                $inCodeBlock = $false
                foreach ($line in $content) {
                    $lineNumber++
                    if ($line -match '^```(\S*)') {
                        if (-not $inCodeBlock) {
                            $language = $matches[1]
                            if ([string]::IsNullOrWhiteSpace($language)) {
                                throw "$($file.Name) line $lineNumber has a code block without a language specifier"
                            }
                            $inCodeBlock = $true
                        } else {
                            $inCodeBlock = $false
                        }
                    }
                }
            }
        }
    }
}
