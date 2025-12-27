#Requires -Modules Pester

BeforeAll {
    # Import test helpers
    Import-Module "$PSScriptRoot\TestHelpers.psm1" -Force

    # Get script paths
    $script:Paths = Get-TestScriptPaths
    $script:SyncScript = $Paths.SyncScript
    $script:AimRoot = $Paths.AimRoot
}

Describe 'sync.ps1' {
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

        # Create mock instructions directory with test modules
        $script:MockInstructionsDir = Join-Path $MockAimDir 'instructions\core'
        New-Item -ItemType Directory -Path $MockInstructionsDir -Force | Out-Null

        $testModuleContent = New-MockModuleContent -Id 'core/agent-workflow' -Name 'Agent Workflow' -Body 'Test workflow content'
        Set-Content -Path (Join-Path $MockInstructionsDir 'agent-workflow.md') -Value $testModuleContent

        $script:TempSyncScript = Join-Path $MockScriptsDir 'sync.ps1'
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
            { & $TempSyncScript -TargetPath $TempDir -SkipPull 2>&1 } | Should -Throw '*aim.json not found*'
        }
    }

    Context 'When aim.json exists with cached modules' {
        BeforeEach {
            # Create cache with module content
            $cacheDir = Join-Path $TempDir '.aim-cache'
            New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
            Set-Content -Path (Join-Path $cacheDir 'core_agent-workflow.md') -Value '# Agent Workflow`n`nTest workflow content'

            # Create a valid aim.json using cached module
            $config = New-MockConfig -Modules @{
                'core/agent-workflow' = 'awesome-copilot'
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)
        }

        It 'Should regenerate AGENTS.md' {
            # Act
            & $TempSyncScript -TargetPath $TempDir -SkipPull 2>&1 | Out-Null

            # Assert
            $agentsPath = Join-Path $TempDir 'AGENTS.md'
            Test-Path $agentsPath | Should -BeTrue

            $agentsContent = Get-Content $agentsPath -Raw
            $agentsContent | Should -Match 'Agent Workflow'
        }

        It 'Should generate file without errors using -SkipPull' {
            # Act & Assert - should not throw
            { & $TempSyncScript -TargetPath $TempDir -SkipPull 2>&1 | Out-Null } | Should -Not -Throw

            # Verify AGENTS.md was created
            Test-Path (Join-Path $TempDir 'AGENTS.md') | Should -BeTrue
        }
    }

    Context 'Git operations' {
        BeforeEach {
            # Create cache with module content
            $cacheDir = Join-Path $TempDir '.aim-cache'
            New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
            Set-Content -Path (Join-Path $cacheDir 'core_agent-workflow.md') -Value '# Agent Workflow'

            # Create a valid aim.json
            $config = New-MockConfig -Modules @{
                'core/agent-workflow' = 'awesome-copilot'
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)
        }

        It 'Should handle non-git directory gracefully' {
            # Act - should not throw even though it's not a git repo
            { & $TempSyncScript -TargetPath $TempDir 2>&1 } | Should -Not -Throw
        }

        It 'Should complete sync in non-git directory' {
            # Act
            & $TempSyncScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert - should still generate AGENTS.md
            Test-Path (Join-Path $TempDir 'AGENTS.md') | Should -BeTrue
        }
    }

    Context 'Awesome-copilot fallback modules' {
        BeforeEach {
            # Create config with awesome-copilot module
            $config = New-MockConfig -Modules @{
                'core/agent-workflow' = $true
                'languages/python'    = 'awesome-copilot'
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)
        }

        It 'Should create cache directory when fetching fallbacks' {
            # Mock Invoke-WebRequest to avoid actual network calls
            Mock Invoke-WebRequest {
                return [PSCustomObject]@{
                    Content = '# Python Instructions'
                }
            }

            # Act
            & $TempSyncScript -TargetPath $TempDir -SkipPull 2>&1 | Out-Null

            # Assert
            $cachePath = Join-Path $TempDir '.aim-cache'
            Test-Path $cachePath | Should -BeTrue
        }

        It 'Should fetch and cache fallback modules' {
            # Mock Invoke-WebRequest
            Mock Invoke-WebRequest {
                return [PSCustomObject]@{
                    Content = '# Mocked Python Instructions'
                }
            }

            # Act
            & $TempSyncScript -TargetPath $TempDir -SkipPull 2>&1 | Out-Null

            # Assert
            $cacheFile = Join-Path $TempDir '.aim-cache\languages_python.md'
            Test-Path $cacheFile | Should -BeTrue

            $cachedContent = Get-Content $cacheFile -Raw
            $cachedContent | Should -Match 'Mocked Python Instructions'
        }

        It 'Should include cached content in AGENTS.md' {
            # Mock Invoke-WebRequest
            Mock Invoke-WebRequest {
                return [PSCustomObject]@{
                    Content = '# Python`n`nUse type hints everywhere.'
                }
            }

            # Act
            & $TempSyncScript -TargetPath $TempDir -SkipPull 2>&1 | Out-Null

            # Assert
            $agentsPath = Join-Path $TempDir 'AGENTS.md'
            $agentsContent = Get-Content $agentsPath -Raw
            $agentsContent | Should -Match 'Python'
        }

        It 'Should handle fetch failures gracefully' {
            # Mock Invoke-WebRequest to throw
            Mock Invoke-WebRequest {
                throw '404 Not Found'
            }

            # Act - should not throw
            { & $TempSyncScript -TargetPath $TempDir -SkipPull 2>&1 } | Should -Not -Throw
        }

        It 'Should successfully fetch without errors' {
            # Mock Invoke-WebRequest
            Mock Invoke-WebRequest {
                return [PSCustomObject]@{
                    Content = '# Python'
                }
            }

            # Act & Assert - should complete without throwing
            { & $TempSyncScript -TargetPath $TempDir -SkipPull 2>&1 | Out-Null } | Should -Not -Throw

            # Verify cache was created
            Test-Path (Join-Path $TempDir '.aim-cache') | Should -BeTrue
        }
    }

    Context 'When fallback is disabled' {
        BeforeEach {
            # Create config with fallback disabled
            $config = New-MockConfig -Modules @{
                'languages/python' = 'awesome-copilot'
            } -FallbackEnabled $false
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)
        }

        It 'Should not create cache directory when fallback disabled' {
            Mock Invoke-WebRequest { }

            # Act
            & $TempSyncScript -TargetPath $TempDir -SkipPull 2>&1 | Out-Null

            # Assert
            $cachePath = Join-Path $TempDir '.aim-cache'
            Test-Path $cachePath | Should -BeFalse
        }
    }

    Context 'Cache updates' {
        BeforeEach {
            # Create cache with old content
            $cacheDir = Join-Path $TempDir '.aim-cache'
            New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
            Set-Content -Path (Join-Path $cacheDir 'core_agent-workflow.md') -Value '# Old cached content'

            # Create a config using cached module
            $config = New-MockConfig -Modules @{
                'core/agent-workflow' = 'awesome-copilot'
            }
            Set-Content -Path (Join-Path $TempDir 'aim.json') -Value (ConvertTo-MockConfigJson -Config $config)

            # Create an existing AGENTS.md with old content
            Set-Content -Path (Join-Path $TempDir 'AGENTS.md') -Value '# Old AGENTS.md content'
        }

        It 'Should regenerate AGENTS.md from current cache' {
            # Update the cached module content
            $cacheDir = Join-Path $TempDir '.aim-cache'
            Set-Content -Path (Join-Path $cacheDir 'core_agent-workflow.md') -Value '# Updated workflow content v2'

            # Act
            & $TempSyncScript -TargetPath $TempDir -SkipPull 2>&1 | Out-Null

            # Assert
            $agentsPath = Join-Path $TempDir 'AGENTS.md'
            $agentsContent = Get-Content $agentsPath -Raw
            $agentsContent | Should -Match 'Updated workflow content v2'
            $agentsContent | Should -Not -Match 'Old AGENTS.md content'
        }
    }
}
