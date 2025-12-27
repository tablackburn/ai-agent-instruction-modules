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
            $moduleContent = New-MockModuleContent -Id 'core/agent-workflow' -Name 'Agent Workflow' -Body 'Test content'
            Set-Content -Path (Join-Path $MockInstructionsDir 'core\agent-workflow.md') -Value $moduleContent

            # Create config
            $config = New-MockConfig -Modules @{
                'core/agent-workflow' = $true
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)
        }

        It 'Should generate header with title' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match '# AI Agent Instructions'
        }

        It 'Should include AIM reference and version' {
            # Create CHANGELOG to extract version
            Set-Content -Path (Join-Path $MockAimDir 'CHANGELOG.md') -Value (New-MockChangelog -Version '1.2.3')

            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match 'AIM'
            $agentsContent | Should -Match 'v1\.2\.3'
        }

        It 'Should include module count' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match 'Enabled modules: 1'
        }

        It 'Should include sync date' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $today = Get-Date -Format 'yyyy-MM-dd'
            $agentsContent | Should -Match "Last sync: $today"
        }
    }

    Context 'Table of contents' {
        BeforeEach {
            # Create multiple modules
            $module1 = New-MockModuleContent -Id 'core/agent-workflow' -Name 'Agent Workflow' -Body 'Content 1'
            Set-Content -Path (Join-Path $MockInstructionsDir 'core\agent-workflow.md') -Value $module1

            $module2 = New-MockModuleContent -Id 'core/code-quality' -Name 'Code Quality' -Body 'Content 2'
            Set-Content -Path (Join-Path $MockInstructionsDir 'core\code-quality.md') -Value $module2

            # Create config with multiple modules
            $config = New-MockConfig -Modules @{
                'core/agent-workflow' = $true
                'core/code-quality'   = $true
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)
        }

        It 'Should generate table of contents' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match '## Table of Contents'
        }

        It 'Should include links to each module' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match '\[Agent Workflow\]\(#agent-workflow\)'
            $agentsContent | Should -Match '\[Code Quality\]\(#code-quality\)'
        }
    }

    Context 'Module content processing' {
        BeforeEach {
            # Create cache directory with cached content to simulate a cached local module
            $cacheDir = Join-Path $TempDir '.aim-cache'
            New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null

            # Create cached content with frontmatter to test stripping
            $cachedContent = @"
---
id: core/agent-workflow
name: Agent Workflow
---

# Agent Workflow

The actual workflow instructions.
"@
            Set-Content -Path (Join-Path $cacheDir 'core_agent-workflow.md') -Value $cachedContent

            # Create config using awesome-copilot so it reads from cache
            $config = New-MockConfig -Modules @{
                'core/agent-workflow' = 'awesome-copilot'
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)
        }

        It 'Should strip YAML frontmatter' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            # Frontmatter markers should be stripped
            $agentsContent | Should -Match 'The actual workflow instructions'
        }

        It 'Should wrap content in BEGIN/END markers' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match '<!-- BEGIN: core/agent-workflow -->'
            $agentsContent | Should -Match '<!-- END: core/agent-workflow -->'
        }

        It 'Should add section headers for modules' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match '## Agent Workflow'
        }
    }

    Context 'Uncached module handling' {
        BeforeEach {
            # Create config referencing an uncached module
            $config = New-MockConfig -Modules @{
                'core/nonexistent' = 'awesome-copilot'
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)
        }

        It 'Should include sync instructions for uncached modules' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match 'Run sync\.ps1 to fetch'
        }
    }

    Context 'Awesome-copilot cached modules' {
        BeforeEach {
            # Create cache directory with cached content
            $cacheDir = Join-Path $TempDir '.aim-cache'
            New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null

            $cachedContent = @"
# Python Best Practices

Use type hints for all functions.
"@
            Set-Content -Path (Join-Path $cacheDir 'languages_python.md') -Value $cachedContent

            # Create config with awesome-copilot module
            $config = New-MockConfig -Modules @{
                'languages/python' = 'awesome-copilot'
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)
        }

        It 'Should include cached fallback content' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match 'Use type hints for all functions'
        }

        It 'Should use correct section name from module path' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match '## Python'
        }
    }

    Context 'Uncached fallback modules' {
        BeforeEach {
            # Create config with awesome-copilot module but no cache
            $config = New-MockConfig -Modules @{
                'languages/python' = 'awesome-copilot'
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)
        }

        It 'Should include sync instructions for uncached modules' {
            # Act
            $output = & $TempBuildScript -TargetPath $TempDir 2>&1

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match 'Run sync\.ps1 to fetch'
        }
    }

    Context 'Custom instructions' {
        BeforeEach {
            # Create a module
            $moduleContent = New-MockModuleContent -Id 'core/agent-workflow' -Name 'Agent Workflow' -Body 'Standard content'
            Set-Content -Path (Join-Path $MockInstructionsDir 'core\agent-workflow.md') -Value $moduleContent

            # Create custom instructions file
            $customContent = @"
# Project-Specific Rules

Always use tabs instead of spaces.
Follow our naming conventions.
"@
            Set-Content -Path (Join-Path $TempDir 'CUSTOM.md') -Value $customContent

            # Create config with custom instructions path
            $config = New-MockConfig -Modules @{
                'core/agent-workflow' = $true
            } -CustomInstructionsPath 'CUSTOM.md'
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)
        }

        It 'Should append custom instructions section' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match '## Custom Instructions'
        }

        It 'Should include custom instructions content' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match 'Always use tabs instead of spaces'
            $agentsContent | Should -Match 'Follow our naming conventions'
        }

        It 'Should wrap custom instructions in markers' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match '<!-- BEGIN: custom -->'
            $agentsContent | Should -Match '<!-- END: custom -->'
        }
    }

    Context 'Path traversal prevention' {
        BeforeEach {
            # Create a module
            $moduleContent = New-MockModuleContent -Id 'core/agent-workflow' -Name 'Agent Workflow' -Body 'Standard content'
            Set-Content -Path (Join-Path $MockInstructionsDir 'core\agent-workflow.md') -Value $moduleContent

            # Create a file outside target directory to attempt to include
            $script:OutsideDir = Join-Path ([System.IO.Path]::GetTempPath()) "aim-outside-$([Guid]::NewGuid().ToString('N').Substring(0,8))"
            New-Item -ItemType Directory -Path $OutsideDir -Force | Out-Null
            Set-Content -Path (Join-Path $OutsideDir 'secret.md') -Value 'SECRET DATA SHOULD NOT APPEAR'
        }

        AfterEach {
            if (Test-Path $OutsideDir) {
                Remove-Item -Path $OutsideDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        It 'Should reject path traversal attempts with ..' {
            # Create config with path traversal attempt
            $config = New-MockConfig -Modules @{
                'core/agent-workflow' = $true
            } -CustomInstructionsPath '../../../secret.md'
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)

            # Act
            $output = & $TempBuildScript -TargetPath $TempDir 2>&1

            # Assert - should not include secret content
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Not -Match 'SECRET DATA'
            $agentsContent | Should -Not -Match '## Custom Instructions'
        }

        It 'Should warn when path traversal is detected' {
            # Create config with path traversal attempt
            $config = New-MockConfig -Modules @{
                'core/agent-workflow' = $true
            } -CustomInstructionsPath '../outside/secret.md'
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)

            # Act
            $output = & $TempBuildScript -TargetPath $TempDir 3>&1 2>&1

            # Assert - should emit warning
            $warningOutput = $output | Where-Object { $_ -is [System.Management.Automation.WarningRecord] -or $_ -match 'outside target directory' }
            $warningOutput | Should -Not -BeNullOrEmpty
        }

        It 'Should allow valid relative paths within target' {
            # Create subdirectory and custom instructions file
            $subDir = Join-Path $TempDir 'docs'
            New-Item -ItemType Directory -Path $subDir -Force | Out-Null
            Set-Content -Path (Join-Path $subDir 'custom.md') -Value 'Valid custom instructions'

            # Create config with valid relative path
            $config = New-MockConfig -Modules @{
                'core/agent-workflow' = $true
            } -CustomInstructionsPath 'docs/custom.md'
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)

            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert - should include custom content
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match 'Valid custom instructions'
            $agentsContent | Should -Match '## Custom Instructions'
        }
    }

    Context 'No modules enabled' {
        BeforeEach {
            # Create config with no enabled modules
            $config = New-MockConfig -Modules @{
                'core/agent-workflow' = $false
                'core/code-quality'   = $false
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)
        }

        It 'Should still generate AGENTS.md with header' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsPath = Join-Path $TempDir 'AGENTS.md'
            Test-Path $agentsPath | Should -BeTrue

            $agentsContent = Get-Content $agentsPath -Raw
            $agentsContent | Should -Match '# AI Agent Instructions'
            $agentsContent | Should -Match 'Enabled modules: 0'
        }
    }

    Context 'Version extraction' {
        BeforeEach {
            # Create a module
            $moduleContent = New-MockModuleContent -Id 'core/agent-workflow' -Name 'Agent Workflow' -Body 'Content'
            Set-Content -Path (Join-Path $MockInstructionsDir 'core\agent-workflow.md') -Value $moduleContent

            # Create config
            $config = New-MockConfig -Modules @{
                'core/agent-workflow' = $true
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)
        }

        It 'Should extract version from CHANGELOG.md' {
            # Create CHANGELOG
            Set-Content -Path (Join-Path $MockAimDir 'CHANGELOG.md') -Value (New-MockChangelog -Version '2.5.0')

            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match 'v2\.5\.0'
        }

        It 'Should use default version when CHANGELOG not found' {
            # Ensure no CHANGELOG exists (don't create one)

            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match 'v0\.1\.0'
        }
    }

    Context 'File generation' {
        BeforeEach {
            # Create cached module
            $cacheDir = Join-Path $TempDir '.aim-cache'
            New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
            Set-Content -Path (Join-Path $cacheDir 'core_agent-workflow.md') -Value '# Agent Workflow'

            # Create config
            $config = New-MockConfig -Modules @{
                'core/agent-workflow' = 'awesome-copilot'
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)
        }

        It 'Should generate AGENTS.md file' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsPath = Join-Path $TempDir 'AGENTS.md'
            Test-Path $agentsPath | Should -BeTrue
        }

        It 'Should create valid markdown file' {
            # Act
            & $TempBuildScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsContent = Get-Content (Join-Path $TempDir 'AGENTS.md') -Raw
            $agentsContent | Should -Match '# AI Agent Instructions'
            $agentsContent | Should -Match '## Table of Contents'
        }
    }
}
