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

        $TestModuleContent = New-MockModuleContent -Id 'core/agent-workflow' -Name 'Agent Workflow' -Body 'Test content'
        Set-Content -Path (Join-Path $MockInstructionsDir 'agent-workflow.md') -Value $TestModuleContent

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
            $ConfigPath = Join-Path $TempDir 'aim.json'
            Test-Path $ConfigPath | Should -BeTrue

            $Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            $Config.modules.'core/agent-workflow' | Should -BeTrue
            $Config.modules.'core/code-quality' | Should -BeTrue
            $Config.modules.'core/security' | Should -BeTrue
        }

        It 'Should include schema reference in config' {
            # Act
            & $TempDeployScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $ConfigPath = Join-Path $TempDir 'aim.json'
            $Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            $Config.'$schema' | Should -Match 'schema\.json'
        }

        It 'Should include fallback configuration' {
            # Act
            & $TempDeployScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $ConfigPath = Join-Path $TempDir 'aim.json'
            $Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            $Config.fallback.enabled | Should -BeTrue
            $Config.fallback.source | Should -Match 'awesome-copilot'
            $Config.fallback.branch | Should -Be 'main'
        }

        It 'Should generate AGENTS.md file' {
            # Act
            & $TempDeployScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsPath = Join-Path $TempDir 'AGENTS.md'
            Test-Path $AgentsPath | Should -BeTrue
        }

        It 'Should include module sections in AGENTS.md' {
            # Act
            & $TempDeployScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $AgentsPath = Join-Path $TempDir 'AGENTS.md'
            $AgentsContent = Get-Content $AgentsPath -Raw
            $AgentsContent | Should -Match 'Agent Workflow'
            $AgentsContent | Should -Match 'Code Quality'
            $AgentsContent | Should -Match 'Security'
        }
    }

    Context 'When aim.json already exists' {
        BeforeEach {
            # Create existing config
            $ExistingConfig = @{
                version = '1.0.0'
                modules = @{ 'custom/module' = $true }
            }
            $ConfigPath = Join-Path $TempDir 'aim.json'
            Set-Content -Path $ConfigPath -Value ($ExistingConfig | ConvertTo-Json)
        }

        It 'Should not overwrite without -Force' {
            # Act
            & $TempDeployScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert
            $ConfigPath = Join-Path $TempDir 'aim.json'
            $Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            $Config.modules.'custom/module' | Should -BeTrue
            $Config.modules.'core/agent-workflow' | Should -BeNullOrEmpty
        }

        It 'Should overwrite with -Force' {
            # Act
            & $TempDeployScript -TargetPath $TempDir -Force 2>&1 | Out-Null

            # Assert
            $ConfigPath = Join-Path $TempDir 'aim.json'
            $Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            $Config.modules.'core/agent-workflow' | Should -BeTrue
        }

        It 'Should still regenerate AGENTS.md without -Force' {
            # Create an old AGENTS.md
            $AgentsPath = Join-Path $TempDir 'AGENTS.md'
            Set-Content -Path $AgentsPath -Value '# Old Content'

            # Act
            & $TempDeployScript -TargetPath $TempDir 2>&1 | Out-Null

            # Assert - AGENTS.md should be regenerated
            $AgentsContent = Get-Content $AgentsPath -Raw
            $AgentsContent | Should -Match 'AI Agent Instructions'
        }
    }

    Context 'When profile is specified' {
        BeforeEach {
            # Create mock profiles directory
            $ProfilesDir = Join-Path $MockAimDir 'config\profiles'
            New-Item -ItemType Directory -Path $ProfilesDir -Force | Out-Null

            # Create minimal profile
            $MinimalProfile = @{
                modules = @{
                    'core/agent-workflow' = $true
                    'core/security'       = $true
                }
            }
            Set-Content -Path (Join-Path $ProfilesDir 'minimal.json') -Value ($MinimalProfile | ConvertTo-Json)

            # Create web-developer profile
            $WebDevProfile = @{
                modules = @{
                    'core/agent-workflow'  = $true
                    'languages/javascript' = $true
                    'languages/typescript' = 'awesome-copilot'
                }
            }
            Set-Content -Path (Join-Path $ProfilesDir 'web-developer.json') -Value ($WebDevProfile | ConvertTo-Json)
        }

        It 'Should apply minimal profile' {
            # Act
            & $TempDeployScript -TargetPath $TempDir -Profile 'minimal' 2>&1 | Out-Null

            # Assert
            $ConfigPath = Join-Path $TempDir 'aim.json'
            $Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            $Config.modules.'core/agent-workflow' | Should -BeTrue
            $Config.modules.'core/security' | Should -BeTrue
        }

        It 'Should apply web-developer profile with mixed sources' {
            # Act
            & $TempDeployScript -TargetPath $TempDir -Profile 'web-developer' 2>&1 | Out-Null

            # Assert
            $ConfigPath = Join-Path $TempDir 'aim.json'
            $Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            $Config.modules.'core/agent-workflow' | Should -BeTrue
            $Config.modules.'languages/javascript' | Should -BeTrue
            $Config.modules.'languages/typescript' | Should -Be 'awesome-copilot'
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
