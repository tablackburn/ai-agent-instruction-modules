#Requires -Modules Pester

BeforeAll {
    # Import test helpers
    Import-Module "$PSScriptRoot\TestHelpers.psm1" -Force

    # Get script paths
    $script:Paths = Get-TestScriptPaths
    $script:BuildScript = $Paths.BuildScript
    $script:AimRoot = $Paths.AimRoot
}

Describe 'build-agents-md.ps1' {
    BeforeEach {
        # Create a temp directory for each test
        $script:TempDir = Join-Path ([System.IO.Path]::GetTempPath()) "aim-test-$([Guid]::NewGuid().ToString('N').Substring(0,8))"
        New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

        # Create a mock .aim folder structure
        $script:MockAimDir = Join-Path $TempDir '.aim'
        New-Item -ItemType Directory -Path $MockAimDir -Force | Out-Null
        $script:MockScriptsDir = Join-Path $MockAimDir 'scripts'
        New-Item -ItemType Directory -Path $MockScriptsDir -Force | Out-Null

        # Copy scripts to temp location
        Copy-Item -Path "$($Paths.ScriptsPath)\*.ps1" -Destination $MockScriptsDir

        # Create mock instructions directory
        $script:MockInstructionsDir = Join-Path $MockAimDir 'instructions'
        New-Item -ItemType Directory -Path "$MockInstructionsDir\core" -Force | Out-Null
        New-Item -ItemType Directory -Path "$MockInstructionsDir\languages" -Force | Out-Null

        $script:TempBuildScript = Join-Path $MockScriptsDir 'build-agents-md.ps1'
    }

    AfterEach {
        # Cleanup temp directory
        if (Test-Path $TempDir) {
            Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Context 'When aim.json does not exist' {
        It 'Should throw an error' {
            # Act & Assert
            { & $TempBuildScript -TargetPath $TempDir 2>&1 } | Should -Throw '*aim.json not found*'
        }
    }

    Context 'AGENTS.md header generation' {
        BeforeEach {
            # Create a module
            $ModuleContent = New-MockModuleContent -Id 'core/agent-workflow' -Name 'Agent Workflow' -Body 'Test content'
            Set-Content -Path (Join-Path $MockInstructionsDir 'core\agent-workflow.md') -Value $ModuleContent

            # Create config
            $Config = New-MockConfig -Modules @{
                'core/agent-workflow' = $true
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $Config)
        }

        It 'Should generate header with title' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match '# AI Agent Instructions'
        }

        It 'Should include AIM reference and version' {
            # Create CHANGELOG to extract version
            Set-Content -Path (Join-Path $MockAimDir 'CHANGELOG.md') -Value (New-MockChangelog -Version '1.2.3')

            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match 'AIM'
            $AgentsContent | Should -Match 'v1\.2\.3'
        }

        It 'Should include module count' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match 'Enabled modules: 1'
        }

        It 'Should include sync date' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $Today = Get-Date -Format 'yyyy-MM-dd'
            $AgentsContent | Should -Match "Last sync: $Today"
        }
    }

    Context 'Table of contents' {
        BeforeEach {
            # Create multiple modules
            $Module1 = New-MockModuleContent -Id 'core/agent-workflow' -Name 'Agent Workflow' -Body 'Content 1'
            Set-Content -Path (Join-Path $MockInstructionsDir 'core\agent-workflow.md') -Value $Module1

            $Module2 = New-MockModuleContent -Id 'core/code-quality' -Name 'Code Quality' -Body 'Content 2'
            Set-Content -Path (Join-Path $MockInstructionsDir 'core\code-quality.md') -Value $Module2

            # Create config with multiple modules
            $Config = New-MockConfig -Modules @{
                'core/agent-workflow' = $true
                'core/code-quality'   = $true
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $Config)
        }

        It 'Should generate table of contents' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match '## Table of Contents'
        }

        It 'Should include links to each module' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match '\[Agent Workflow\]\(#agent-workflow\)'
            $AgentsContent | Should -Match '\[Code Quality\]\(#code-quality\)'
        }
    }

    Context 'Module content processing' {
        BeforeEach {
            # Create cache directory with cached content to simulate a cached local module
            $CacheDir = Join-Path $TempDir '.aim-cache'
            New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null

            # Create cached content with frontmatter to test stripping
            $CachedContent = @"
---
id: core/agent-workflow
name: Agent Workflow
---

# Agent Workflow

The actual workflow instructions.
"@
            Set-Content -Path (Join-Path $CacheDir 'core_agent-workflow.md') -Value $CachedContent

            # Create config using awesome-copilot so it reads from cache
            $Config = New-MockConfig -Modules @{
                'core/agent-workflow' = 'awesome-copilot'
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $Config)
        }

        It 'Should strip YAML frontmatter' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            # Frontmatter markers should be stripped
            $AgentsContent | Should -Match 'The actual workflow instructions'
        }

        It 'Should wrap content in BEGIN/END markers' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match '<!-- BEGIN: core/agent-workflow -->'
            $AgentsContent | Should -Match '<!-- END: core/agent-workflow -->'
        }

        It 'Should add section headers for modules' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match '## Agent Workflow'
        }
    }

    Context 'Uncached module handling' {
        BeforeEach {
            # Create config referencing an uncached module
            $Config = New-MockConfig -Modules @{
                'core/nonexistent' = 'awesome-copilot'
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $Config)
        }

        It 'Should include sync instructions for uncached modules' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match 'Run sync\.ps1 to fetch'
        }
    }

    Context 'Awesome-copilot cached modules' {
        BeforeEach {
            # Create cache directory with cached content
            $CacheDir = Join-Path $TempDir '.aim-cache'
            New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null

            $CachedContent = @"
# Python Best Practices

Use type hints for all functions.
"@
            Set-Content -Path (Join-Path $CacheDir 'languages_python.md') -Value $CachedContent

            # Create config with awesome-copilot module
            $Config = New-MockConfig -Modules @{
                'languages/python' = 'awesome-copilot'
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $Config)
        }

        It 'Should include cached fallback content' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match 'Use type hints for all functions'
        }

        It 'Should use correct section name from module path' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match '## Python'
        }
    }

    Context 'Uncached fallback modules' {
        BeforeEach {
            # Create config with awesome-copilot module but no cache
            $Config = New-MockConfig -Modules @{
                'languages/python' = 'awesome-copilot'
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $Config)
        }

        It 'Should include sync instructions for uncached modules' {
            # Act
            $Output = & $TempBuildScript -TargetPath $TempDir 2>&1

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match 'Run sync\.ps1 to fetch'
        }
    }

    Context 'Custom instructions' {
        BeforeEach {
            # Create a module
            $ModuleContent = New-MockModuleContent -Id 'core/agent-workflow' -Name 'Agent Workflow' -Body 'Standard content'
            Set-Content -Path (Join-Path $MockInstructionsDir 'core\agent-workflow.md') -Value $ModuleContent

            # Create custom instructions file
            $CustomContent = @"
# Project-Specific Rules

Always use tabs instead of spaces.
Follow our naming conventions.
"@
            Set-Content -Path (Join-Path $TempDir 'CUSTOM.md') -Value $CustomContent

            # Create config with custom instructions path
            $Config = New-MockConfig -Modules @{
                'core/agent-workflow' = $true
            } -CustomInstructionsPath 'CUSTOM.md'
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $Config)
        }

        It 'Should append custom instructions section' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match '## Custom Instructions'
        }

        It 'Should include custom instructions content' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match 'Always use tabs instead of spaces'
            $AgentsContent | Should -Match 'Follow our naming conventions'
        }

        It 'Should wrap custom instructions in markers' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match '<!-- BEGIN: custom -->'
            $AgentsContent | Should -Match '<!-- END: custom -->'
        }
    }

    Context 'No modules enabled' {
        BeforeEach {
            # Create config with no enabled modules
            $Config = New-MockConfig -Modules @{
                'core/agent-workflow' = $false
                'core/code-quality'   = $false
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $Config)
        }

        It 'Should still generate AGENTS.md with header' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsPath = Join-Path $TempDir 'AGENTS.md'
            Test-Path $AgentsPath | Should -BeTrue

            $AgentsContent = Get-Content $AgentsPath -Raw
            $AgentsContent | Should -Match '# AI Agent Instructions'
            $AgentsContent | Should -Match 'Enabled modules: 0'
        }
    }

    Context 'Version extraction' {
        BeforeEach {
            # Create a module
            $ModuleContent = New-MockModuleContent -Id 'core/agent-workflow' -Name 'Agent Workflow' -Body 'Content'
            Set-Content -Path (Join-Path $MockInstructionsDir 'core\agent-workflow.md') -Value $ModuleContent

            # Create config
            $Config = New-MockConfig -Modules @{
                'core/agent-workflow' = $true
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $Config)
        }

        It 'Should extract version from CHANGELOG.md' {
            # Create CHANGELOG
            Set-Content -Path (Join-Path $MockAimDir 'CHANGELOG.md') -Value (New-MockChangelog -Version '2.5.0')

            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match 'v2\.5\.0'
        }

        It 'Should use default version when CHANGELOG not found' {
            # Ensure no CHANGELOG exists (don't create one)

            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match 'v0\.1\.0'
        }
    }

    Context 'File generation' {
        BeforeEach {
            # Create cached module
            $CacheDir = Join-Path $TempDir '.aim-cache'
            New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
            Set-Content -Path (Join-Path $CacheDir 'core_agent-workflow.md') -Value '# Agent Workflow'

            # Create config
            $Config = New-MockConfig -Modules @{
                'core/agent-workflow' = 'awesome-copilot'
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $Config)
        }

        It 'Should generate AGENTS.md file' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsPath = Join-Path $TempDir 'AGENTS.md'
            Test-Path $AgentsPath | Should -BeTrue
        }

        It 'Should create valid markdown file' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $AgentsContent | Should -Match '# AI Agent Instructions'
            $AgentsContent | Should -Match '## Table of Contents'
        }
    }
}
