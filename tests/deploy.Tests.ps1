#Requires -Modules Pester

BeforeAll {
    # Import test helpers
    Import-Module "$PSScriptRoot\TestHelpers.psm1" -Force

    # Get script paths
    $script:Paths = Get-TestScriptPaths
    $script:DeployScript = $Paths.DeployScript
    $script:AimRoot = $Paths.AimRoot
}

Describe 'deploy.ps1' {
    BeforeEach {
        # Create a temp directory for each test
        $script:TempDir = Join-Path ([System.IO.Path]::GetTempPath()) "aim-test-$([Guid]::NewGuid().ToString('N').Substring(0,8))"
        New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

        # Create a mock .aim folder structure that points to the real AIM root
        $script:MockAimDir = Join-Path $TempDir '.aim'
        New-Item -ItemType Directory -Path $MockAimDir -Force | Out-Null
        $script:MockScriptsDir = Join-Path $MockAimDir 'scripts'
        New-Item -ItemType Directory -Path $MockScriptsDir -Force | Out-Null

        # Copy scripts to temp location so PSScriptRoot works correctly
        Copy-Item -Path "$($Paths.ScriptsPath)\*.ps1" -Destination $MockScriptsDir

        # Create mock instructions directory with a test module
        $script:MockInstructionsDir = Join-Path $MockAimDir 'instructions\core'
        New-Item -ItemType Directory -Path $MockInstructionsDir -Force | Out-Null

        $testModuleContent = New-MockModuleContent -Id 'core/agent-workflow' -Name 'Agent Workflow' -Body 'Test content'
        Set-Content -Path (Join-Path $MockInstructionsDir 'agent-workflow.md') -Value $testModuleContent

        $script:TempDeployScript = Join-Path $MockScriptsDir 'deploy.ps1'
    }

    AfterEach {
        # Cleanup temp directory
        if (Test-Path $TempDir) {
            Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Context 'When aim.json does not exist' {
        It 'Should create aim.json with core modules' {
            # Act
            & $TempDeployScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $configPath = Join-Path $TempDir 'aim.json'
            Test-Path $configPath | Should -BeTrue

            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            $config.modules.'core/agent-workflow' | Should -BeTrue
            $config.modules.'core/code-quality' | Should -BeTrue
            $config.modules.'core/security' | Should -BeTrue
        }

        It 'Should include schema reference in config' {
            # Act
            & $TempDeployScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $configPath = Join-Path $TempDir 'aim.json'
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            $config.'$schema' | Should -Match 'schema\.json'
        }

        It 'Should include fallback configuration' {
            # Act
            & $TempDeployScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $configPath = Join-Path $TempDir 'aim.json'
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            $config.fallback.enabled | Should -BeTrue
            $config.fallback.source | Should -Match 'awesome-copilot'
            $config.fallback.branch | Should -Be 'main'
        }

        It 'Should generate AGENTS.md file' {
            # Act
            & $TempDeployScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsPath = Join-Path $TempDir 'AGENTS.md'
            Test-Path $agentsPath | Should -BeTrue
        }

        It 'Should include module sections in AGENTS.md' {
            # Act
            & $TempDeployScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $agentsPath = Join-Path $TempDir 'AGENTS.md'
            $agentsContent = Get-Content $agentsPath -Raw
            $agentsContent | Should -Match 'Agent Workflow'
            $agentsContent | Should -Match 'Code Quality'
            $agentsContent | Should -Match 'Security'
        }
    }

    Context 'When aim.json already exists' {
        BeforeEach {
            # Create existing config
            $existingConfig = @{
                version = '1.0.0'
                modules = @{ 'custom/module' = $true }
            }
            $configPath = Join-Path $TempDir 'aim.json'
            Set-Content -Path $configPath -Value ($existingConfig | ConvertTo-Json)
        }

        It 'Should not overwrite without -Force' {
            # Act
            & $TempDeployScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $configPath = Join-Path $TempDir 'aim.json'
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            $config.modules.'custom/module' | Should -BeTrue
            $config.modules.'core/agent-workflow' | Should -BeNullOrEmpty
        }

        It 'Should overwrite with -Force' {
            # Act
            & $TempDeployScript -TargetPath $TempDir -Force 2>&1 | Out-Null

            # Assert
            $configPath = Join-Path $TempDir 'aim.json'
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            $config.modules.'core/agent-workflow' | Should -BeTrue
        }

        It 'Should still regenerate AGENTS.md without -Force' {
            # Create an old AGENTS.md
            $agentsPath = Join-Path $TempDir 'AGENTS.md'
            Set-Content -Path $agentsPath -Value '# Old Content'

            # Act
            & $TempDeployScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert - AGENTS.md should be regenerated
            $agentsContent = Get-Content $agentsPath -Raw
            $agentsContent | Should -Match 'AI Agent Instructions'
        }
    }

    Context 'When profile is specified' {
        BeforeEach {
            # Create mock profiles directory
            $profilesDir = Join-Path $MockAimDir 'config\profiles'
            New-Item -ItemType Directory -Path $profilesDir -Force | Out-Null

            # Create minimal profile
            $minimalProfile = @{
                modules = @{
                    'core/agent-workflow' = $true
                    'core/security'       = $true
                }
            }
            Set-Content -Path (Join-Path $profilesDir 'minimal.json') -Value ($minimalProfile | ConvertTo-Json)

            # Create web-developer profile
            $webDevProfile = @{
                modules = @{
                    'core/agent-workflow'  = $true
                    'languages/javascript' = $true
                    'languages/typescript' = 'awesome-copilot'
                }
            }
            Set-Content -Path (Join-Path $profilesDir 'web-developer.json') -Value ($webDevProfile | ConvertTo-Json)
        }

        It 'Should apply minimal profile' {
            # Act
            & $TempDeployScript -TargetPath $TempDir -Profile 'minimal' 2>&1 | Out-Null

            # Assert
            $configPath = Join-Path $TempDir 'aim.json'
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            $config.modules.'core/agent-workflow' | Should -BeTrue
            $config.modules.'core/security' | Should -BeTrue
        }

        It 'Should apply web-developer profile with mixed sources' {
            # Act
            & $TempDeployScript -TargetPath $TempDir -Profile 'web-developer' 2>&1 | Out-Null

            # Assert
            $configPath = Join-Path $TempDir 'aim.json'
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            $config.modules.'core/agent-workflow' | Should -BeTrue
            $config.modules.'languages/javascript' | Should -BeTrue
            $config.modules.'languages/typescript' | Should -Be 'awesome-copilot'
        }
    }

    Context 'End-to-end deployment' {
        It 'Should complete without errors' {
            # Act & Assert - should not throw
            { & $TempDeployScript -TargetPath $TempDir 2>&1 | Out-Null } | Should -Not -Throw

            # Verify outputs exist
            Test-Path (Join-Path $TempDir 'aim.json') | Should -BeTrue
            Test-Path (Join-Path $TempDir 'AGENTS.md') | Should -BeTrue
        }
    }
}
