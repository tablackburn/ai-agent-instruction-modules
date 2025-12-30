Describe 'AIM Deployment Integration Tests' -Tag 'Integration' {

    BeforeAll {
        # Repository paths
        $script:repoRoot = Join-Path -Path $PSScriptRoot -ChildPath '..'
        $script:templatePath = Join-Path -Path $script:repoRoot -ChildPath 'instruction-templates'
        $script:agentsTemplatePath = Join-Path -Path $script:repoRoot -ChildPath 'AGENTS.template.md'

        # Language to module mapping
        $script:languageModuleMap = @{
            '.ps1'  = 'powershell.instructions.md'
            '.psm1' = 'powershell.instructions.md'
            '.md'   = 'markdown.instructions.md'
        }

        # Core modules that are always deployed
        $script:coreModules = @(
            'agent-workflow.instructions.md'
            'update.instructions.md'
        )

        # Helper: Create a test repository with sample files
        function New-TestRepository {
            param(
                [string[]]$FileExtensions = @('.ps1')
            )

            $tempDir = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "aim-test-$([Guid]::NewGuid().ToString('N').Substring(0,8))"
            New-Item -Path $tempDir -ItemType Directory -Force | Out-Null

            # Create sample files for each extension
            foreach ($ext in $FileExtensions) {
                $fileName = "sample$ext"
                $filePath = Join-Path -Path $tempDir -ChildPath $fileName
                Set-Content -Path $filePath -Value "# Sample file for testing"
            }

            return $tempDir
        }

        # Helper: Detect languages in a repository
        function Get-DetectedLanguages {
            param(
                [string]$RepositoryPath
            )

            $detectedModules = @()
            $files = Get-ChildItem -Path $RepositoryPath -File -Recurse -ErrorAction SilentlyContinue

            foreach ($file in $files) {
                $ext = $file.Extension.ToLower()
                if ($script:languageModuleMap.ContainsKey($ext)) {
                    $module = $script:languageModuleMap[$ext]
                    if ($module -notin $detectedModules) {
                        $detectedModules += $module
                    }
                }
            }

            return $detectedModules
        }

        # Helper: Simulate AIM deployment
        function Invoke-AIMDeployment {
            param(
                [string]$TargetPath,
                [string[]]$AdditionalModules = @()
            )

            # Create instructions directory
            $instructionsDir = Join-Path -Path $TargetPath -ChildPath 'instructions'
            New-Item -Path $instructionsDir -ItemType Directory -Force | Out-Null

            # Copy AGENTS.template.md as AGENTS.md
            $agentsDestPath = Join-Path -Path $TargetPath -ChildPath 'AGENTS.md'
            Copy-Item -Path $script:agentsTemplatePath -Destination $agentsDestPath -Force

            # Detect languages and determine modules to deploy
            $detectedModules = Get-DetectedLanguages -RepositoryPath $TargetPath
            $modulesToDeploy = $script:coreModules + $detectedModules + $AdditionalModules | Select-Object -Unique

            # Copy each module
            $deployedModules = @()
            foreach ($module in $modulesToDeploy) {
                $sourcePath = Join-Path -Path $script:templatePath -ChildPath $module
                if (Test-Path -Path $sourcePath) {
                    $destPath = Join-Path -Path $instructionsDir -ChildPath $module
                    Copy-Item -Path $sourcePath -Destination $destPath -Force
                    $deployedModules += $module
                }
            }

            # Create repository-specific.instructions.md from template
            $repoSpecificSource = Join-Path -Path $script:templatePath -ChildPath 'repository-specific.instructions.md'
            if (Test-Path -Path $repoSpecificSource) {
                $repoSpecificDest = Join-Path -Path $instructionsDir -ChildPath 'repository-specific.instructions.md'
                Copy-Item -Path $repoSpecificSource -Destination $repoSpecificDest -Force
                $deployedModules += 'repository-specific.instructions.md'
            }

            # Create aim.config.json
            $config = @{
                version = 'latest'
                modules = @{
                    include = $deployedModules
                    exclude = @()
                }
                externalSources = @{
                    enabled = $false
                    repositories = @()
                }
            }
            $configPath = Join-Path -Path $TargetPath -ChildPath 'aim.config.json'
            $config | ConvertTo-Json -Depth 4 | Set-Content -Path $configPath

            return @{
                AgentsPath       = $agentsDestPath
                InstructionsDir  = $instructionsDir
                ConfigPath       = $configPath
                DeployedModules  = $deployedModules
            }
        }

        # Helper: Remove test repository
        function Remove-TestRepository {
            param(
                [string]$Path
            )

            if (Test-Path -Path $Path) {
                Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        # Helper: Simulate AIM update on existing deployment
        function Invoke-AIMUpdate {
            param(
                [string]$TargetPath,
                [string[]]$NewModules = @()
            )

            $instructionsDir = Join-Path -Path $TargetPath -ChildPath 'instructions'
            $configPath = Join-Path -Path $TargetPath -ChildPath 'aim.config.json'

            # Read existing config
            $config = Get-Content -Path $configPath | ConvertFrom-Json

            # Sync new modules (simulating what update would do)
            $addedModules = @()
            foreach ($module in $NewModules) {
                $sourcePath = Join-Path -Path $script:templatePath -ChildPath $module
                if (Test-Path -Path $sourcePath) {
                    $destPath = Join-Path -Path $instructionsDir -ChildPath $module
                    # Only copy if not already present (simulating "new" modules)
                    if (-not (Test-Path -Path $destPath)) {
                        Copy-Item -Path $sourcePath -Destination $destPath -Force
                        $addedModules += $module
                    }
                }
            }

            # Update config with new modules
            $updatedInclude = @($config.modules.include) + $addedModules | Select-Object -Unique
            $config.modules.include = $updatedInclude

            # Write updated config
            $config | ConvertTo-Json -Depth 4 | Set-Content -Path $configPath

            return @{
                AddedModules    = $addedModules
                UpdatedConfig   = $config
                InstructionsDir = $instructionsDir
                ConfigPath      = $configPath
            }
        }

        # Helper: Create config with external sources
        function Set-ExternalSourcesConfig {
            param(
                [string]$ConfigPath,
                [bool]$Enabled = $false,
                [array]$Repositories = @()
            )

            $config = Get-Content -Path $ConfigPath | ConvertFrom-Json
            $config.externalSources.enabled = $Enabled
            $config.externalSources.repositories = $Repositories
            $config | ConvertTo-Json -Depth 4 | Set-Content -Path $ConfigPath
            return $config
        }
    }

    Context 'Basic Deployment' {

        BeforeAll {
            $script:testRepo = New-TestRepository -FileExtensions @('.ps1')
            $script:deploymentResult = Invoke-AIMDeployment -TargetPath $script:testRepo
        }

        AfterAll {
            Remove-TestRepository -Path $script:testRepo
        }

        It 'Creates AGENTS.md in target repository' {
            Test-Path -Path $script:deploymentResult.AgentsPath | Should -BeTrue
        }

        It 'Creates instructions directory' {
            Test-Path -Path $script:deploymentResult.InstructionsDir | Should -BeTrue
        }

        It 'Creates aim.config.json' {
            Test-Path -Path $script:deploymentResult.ConfigPath | Should -BeTrue
        }

        It 'Deploys core modules' {
            foreach ($module in $script:coreModules) {
                $modulePath = Join-Path -Path $script:deploymentResult.InstructionsDir -ChildPath $module
                Test-Path -Path $modulePath | Should -BeTrue -Because "$module should be deployed"
            }
        }

        It 'Deploys repository-specific.instructions.md' {
            $repoSpecificPath = Join-Path -Path $script:deploymentResult.InstructionsDir -ChildPath 'repository-specific.instructions.md'
            Test-Path -Path $repoSpecificPath | Should -BeTrue
        }

        It 'Detects PowerShell and deploys powershell.instructions.md' {
            $psModulePath = Join-Path -Path $script:deploymentResult.InstructionsDir -ChildPath 'powershell.instructions.md'
            Test-Path -Path $psModulePath | Should -BeTrue
        }
    }

    Context 'Multi-Language Detection' {

        BeforeAll {
            $script:testRepo = New-TestRepository -FileExtensions @('.ps1', '.md')
            $script:deploymentResult = Invoke-AIMDeployment -TargetPath $script:testRepo
        }

        AfterAll {
            Remove-TestRepository -Path $script:testRepo
        }

        It 'Detects multiple languages' {
            $script:deploymentResult.DeployedModules | Should -Contain 'powershell.instructions.md'
            $script:deploymentResult.DeployedModules | Should -Contain 'markdown.instructions.md'
        }

        It 'Deploys modules for all detected languages' {
            $psPath = Join-Path -Path $script:deploymentResult.InstructionsDir -ChildPath 'powershell.instructions.md'
            $mdPath = Join-Path -Path $script:deploymentResult.InstructionsDir -ChildPath 'markdown.instructions.md'
            Test-Path -Path $psPath | Should -BeTrue
            Test-Path -Path $mdPath | Should -BeTrue
        }

        It 'Config includes all deployed modules' {
            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $config.modules.include | Should -Contain 'powershell.instructions.md'
            $config.modules.include | Should -Contain 'markdown.instructions.md'
        }
    }

    Context 'Module Selection' {

        BeforeAll {
            # Create repo with no matching language files
            $script:testRepo = New-TestRepository -FileExtensions @('.xyz')
            $script:deploymentResult = Invoke-AIMDeployment -TargetPath $script:testRepo
        }

        AfterAll {
            Remove-TestRepository -Path $script:testRepo
        }

        It 'Always deploys core modules regardless of detected languages' {
            foreach ($module in $script:coreModules) {
                $modulePath = Join-Path -Path $script:deploymentResult.InstructionsDir -ChildPath $module
                Test-Path -Path $modulePath | Should -BeTrue -Because "$module is a core module"
            }
        }

        It 'Does not deploy language modules when no matching files found' {
            $psPath = Join-Path -Path $script:deploymentResult.InstructionsDir -ChildPath 'powershell.instructions.md'
            Test-Path -Path $psPath | Should -BeFalse -Because 'No .ps1 files in repo'
        }

        It 'Allows explicit additional modules' {
            $customRepo = New-TestRepository -FileExtensions @('.xyz')
            try {
                $result = Invoke-AIMDeployment -TargetPath $customRepo -AdditionalModules @('git-workflow.instructions.md')
                $gitPath = Join-Path -Path $result.InstructionsDir -ChildPath 'git-workflow.instructions.md'
                Test-Path -Path $gitPath | Should -BeTrue
            }
            finally {
                Remove-TestRepository -Path $customRepo
            }
        }
    }

    Context 'Post-Deployment Integrity' {

        BeforeAll {
            $script:testRepo = New-TestRepository -FileExtensions @('.ps1', '.md')
            $script:deploymentResult = Invoke-AIMDeployment -TargetPath $script:testRepo
        }

        AfterAll {
            Remove-TestRepository -Path $script:testRepo
        }

        It 'AGENTS.md is valid markdown with content' {
            $content = Get-Content -Path $script:deploymentResult.AgentsPath -Raw
            $content | Should -Not -BeNullOrEmpty
            $content | Should -Match '^#' -Because 'Should contain markdown headings'
        }

        It 'aim.config.json is valid JSON' {
            { Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json } | Should -Not -Throw
        }

        It 'aim.config.json has required structure' {
            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $config.version | Should -Not -BeNullOrEmpty
            $config.modules | Should -Not -BeNull
            $config.modules.include | Should -Not -BeNull
            $config.externalSources | Should -Not -BeNull
        }

        It 'All deployed instruction files have valid YAML frontmatter' {
            $instructionFiles = Get-ChildItem -Path $script:deploymentResult.InstructionsDir -Filter '*.instructions.md'
            foreach ($file in $instructionFiles) {
                $content = Get-Content -Path $file.FullName -Raw
                $content | Should -Match '^---\r?\n' -Because "$($file.Name) should have YAML frontmatter"
                $content | Should -Match 'applyTo:' -Because "$($file.Name) should have applyTo field"
                $content | Should -Match 'description:' -Because "$($file.Name) should have description field"
            }
        }

        It 'Config modules.include matches actually deployed files' {
            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            foreach ($module in $config.modules.include) {
                $modulePath = Join-Path -Path $script:deploymentResult.InstructionsDir -ChildPath $module
                Test-Path -Path $modulePath | Should -BeTrue -Because "Config lists $module but file should exist"
            }
        }

        It 'All files in instructions directory are listed in config' {
            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $deployedFiles = Get-ChildItem -Path $script:deploymentResult.InstructionsDir -Filter '*.instructions.md' |
                Select-Object -ExpandProperty Name
            foreach ($file in $deployedFiles) {
                $config.modules.include | Should -Contain $file -Because "$file is deployed but should be in config"
            }
        }
    }

    Context 'Cleanup Verification' {

        It 'Test repository cleanup works correctly' {
            $tempRepo = New-TestRepository -FileExtensions @('.txt')
            Test-Path -Path $tempRepo | Should -BeTrue

            Remove-TestRepository -Path $tempRepo
            Test-Path -Path $tempRepo | Should -BeFalse
        }
    }

    Context 'Update Workflow Simulation' {

        BeforeAll {
            # Create initial deployment
            $script:testRepo = New-TestRepository -FileExtensions @('.ps1')
            $script:deploymentResult = Invoke-AIMDeployment -TargetPath $script:testRepo
        }

        AfterAll {
            Remove-TestRepository -Path $script:testRepo
        }

        It 'Can add new modules via update' {
            $updateResult = Invoke-AIMUpdate -TargetPath $script:testRepo -NewModules @('git-workflow.instructions.md')
            $updateResult.AddedModules | Should -Contain 'git-workflow.instructions.md'

            $gitPath = Join-Path -Path $updateResult.InstructionsDir -ChildPath 'git-workflow.instructions.md'
            Test-Path -Path $gitPath | Should -BeTrue
        }

        It 'Update adds new modules to config' {
            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $config.modules.include | Should -Contain 'git-workflow.instructions.md'
        }

        It 'Update preserves existing modules' {
            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $config.modules.include | Should -Contain 'agent-workflow.instructions.md'
            $config.modules.include | Should -Contain 'powershell.instructions.md'
        }

        It 'Update preserves repository-specific.instructions.md' {
            # Modify repository-specific file
            $repoSpecificPath = Join-Path -Path $script:deploymentResult.InstructionsDir -ChildPath 'repository-specific.instructions.md'
            $customContent = "# Custom Repository Instructions`n`nThis is custom content."
            Set-Content -Path $repoSpecificPath -Value $customContent

            # Run another update
            Invoke-AIMUpdate -TargetPath $script:testRepo -NewModules @('releases.instructions.md')

            # Verify custom content preserved
            $content = Get-Content -Path $repoSpecificPath -Raw
            $content | Should -Match 'This is custom content'
        }

        It 'Update does not duplicate existing modules' {
            # Try to add a module that already exists
            $updateResult = Invoke-AIMUpdate -TargetPath $script:testRepo -NewModules @('powershell.instructions.md')
            $updateResult.AddedModules | Should -Not -Contain 'powershell.instructions.md' -Because 'Module already exists'
        }

        It 'Multiple updates accumulate modules correctly' {
            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            # Should have original + git-workflow + releases from previous tests
            $config.modules.include | Should -Contain 'agent-workflow.instructions.md'
            $config.modules.include | Should -Contain 'powershell.instructions.md'
            $config.modules.include | Should -Contain 'git-workflow.instructions.md'
            $config.modules.include | Should -Contain 'releases.instructions.md'
        }
    }

    Context 'External Sources Configuration' {

        BeforeAll {
            $script:testRepo = New-TestRepository -FileExtensions @('.ps1')
            $script:deploymentResult = Invoke-AIMDeployment -TargetPath $script:testRepo
        }

        AfterAll {
            Remove-TestRepository -Path $script:testRepo
        }

        It 'Default deployment has external sources disabled' {
            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $config.externalSources.enabled | Should -BeFalse
        }

        It 'Default deployment has empty repositories list' {
            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $config.externalSources.repositories | Should -BeNullOrEmpty
        }

        It 'Can enable external sources' {
            Set-ExternalSourcesConfig -ConfigPath $script:deploymentResult.ConfigPath -Enabled $true

            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $config.externalSources.enabled | Should -BeTrue
        }

        It 'Can configure external repositories' {
            $repos = @(
                @{
                    name        = 'awesome-copilot'
                    url         = 'https://github.com/github/awesome-copilot'
                    path        = 'instructions'
                    description = 'Community-contributed instructions'
                }
            )
            Set-ExternalSourcesConfig -ConfigPath $script:deploymentResult.ConfigPath -Enabled $true -Repositories $repos

            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $config.externalSources.repositories | Should -HaveCount 1
            $config.externalSources.repositories[0].name | Should -Be 'awesome-copilot'
        }

        It 'External source config has required fields' {
            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $repo = $config.externalSources.repositories[0]
            $repo.name | Should -Not -BeNullOrEmpty
            $repo.url | Should -Not -BeNullOrEmpty
            $repo.path | Should -Not -BeNullOrEmpty
        }

        It 'Can disable external sources after enabling' {
            Set-ExternalSourcesConfig -ConfigPath $script:deploymentResult.ConfigPath -Enabled $false

            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $config.externalSources.enabled | Should -BeFalse
        }
    }

    Context 'Module Exclusion' {

        BeforeAll {
            $script:testRepo = New-TestRepository -FileExtensions @('.ps1', '.md')
            $script:deploymentResult = Invoke-AIMDeployment -TargetPath $script:testRepo
        }

        AfterAll {
            Remove-TestRepository -Path $script:testRepo
        }

        It 'Can add modules to exclude list' {
            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $config.modules.exclude = @('markdown.instructions.md')
            $config | ConvertTo-Json -Depth 4 | Set-Content -Path $script:deploymentResult.ConfigPath

            $updatedConfig = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $updatedConfig.modules.exclude | Should -Contain 'markdown.instructions.md'
        }

        It 'Exclude list supports multiple items' {
            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $config.modules.exclude = @('markdown.instructions.md', 'readme.instructions.md')
            $config | ConvertTo-Json -Depth 4 | Set-Content -Path $script:deploymentResult.ConfigPath

            $updatedConfig = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $updatedConfig.modules.exclude | Should -HaveCount 2
        }

        It 'Include and exclude can coexist' {
            $config = Get-Content -Path $script:deploymentResult.ConfigPath | ConvertFrom-Json
            $config.modules.include | Should -Not -BeNullOrEmpty
            $config.modules.exclude | Should -Not -BeNullOrEmpty
        }
    }
}
