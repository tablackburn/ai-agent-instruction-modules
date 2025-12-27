#Requires -Modules Pester

Describe 'AI Agent Instructions Validation' {

    BeforeAll {
        # File paths
        $script:repoRoot = Join-Path -Path $PSScriptRoot -ChildPath '..'
        $script:templateFilePath = Join-Path -Path $script:repoRoot -ChildPath 'AGENTS.template.md'
        $script:agentsFilePath = Join-Path -Path $script:repoRoot -ChildPath 'AGENTS.md'
        $script:changelogFilePath = Join-Path -Path $script:repoRoot -ChildPath 'CHANGELOG.md'
        $script:instructionsPath = Join-Path -Path $script:repoRoot -ChildPath 'instructions'

        # Check file existence
        $script:templateFileExists = Test-Path -Path $script:templateFilePath
        $script:agentsFileExists = Test-Path -Path $script:agentsFilePath
        $script:changelogFileExists = Test-Path -Path $script:changelogFilePath

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
    }

    Context 'Instruction Files' {

        It 'agent-workflow.instructions.md exists' {
            $filePath = Join-Path -Path $script:instructionsPath -ChildPath 'agent-workflow.instructions.md'
            Test-Path -Path $filePath | Should -BeTrue
        }


        It 'update.instructions.md exists' {
            $filePath = Join-Path -Path $script:instructionsPath -ChildPath 'update.instructions.md'
            Test-Path -Path $filePath | Should -BeTrue
        }

        It 'repository-specific.instructions.md exists' {
            $filePath = Join-Path -Path $script:instructionsPath -ChildPath 'repository-specific.instructions.md'
            Test-Path -Path $filePath | Should -BeTrue
        }

        It 'All instruction files have .instructions.md extension' {
            $invalidFiles = Get-ChildItem -Path $script:instructionsPath -Filter '*.md' |
                Where-Object { $_.Name -notmatch '\.instructions\.md$' }
            $invalidFiles | Should -BeNullOrEmpty -Because 'All markdown files in instructions/ should use .instructions.md extension'
        }

        It 'All instruction files have YAML frontmatter' {
            $instructionFiles = Get-ChildItem -Path $script:instructionsPath -Filter '*.instructions.md'
            foreach ($file in $instructionFiles) {
                $content = Get-Content -Path $file.FullName -Raw
                $content | Should -Match '^---\r?\n' -Because "$($file.Name) should start with YAML frontmatter"
            }
        }

        It 'All instruction files have applyTo in frontmatter' {
            $instructionFiles = Get-ChildItem -Path $script:instructionsPath -Filter '*.instructions.md'
            foreach ($file in $instructionFiles) {
                $content = Get-Content -Path $file.FullName -Raw
                $content | Should -Match 'applyTo:' -Because "$($file.Name) should have applyTo in frontmatter"
            }
        }

        It 'All instruction files have description in frontmatter' {
            $instructionFiles = Get-ChildItem -Path $script:instructionsPath -Filter '*.instructions.md'
            foreach ($file in $instructionFiles) {
                $content = Get-Content -Path $file.FullName -Raw
                $content | Should -Match 'description:' -Because "$($file.Name) should have description in frontmatter"
            }
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
    }
}
