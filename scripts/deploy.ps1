<#
.SYNOPSIS
    Deploys AIM (AI Agent Instruction Modules) to a target repository.

.DESCRIPTION
    This script sets up AIM in a target repository by:
    1. Creating the aim.json configuration file
    2. Optionally applying a profile preset
    3. Generating the initial AGENTS.md file

.PARAMETER TargetPath
    The path to the target repository. Defaults to parent directory of .aim folder.

.PARAMETER Profile
    Optional profile to apply (minimal, web-developer, python-developer, full-stack).

.PARAMETER Force
    Overwrite existing aim.json if present.

.EXAMPLE
    .\deploy.ps1
    Deploys with default settings to the parent directory.

.EXAMPLE
    .\deploy.ps1 -Profile minimal
    Deploys with the minimal profile.

.EXAMPLE
    .\deploy.ps1 -TargetPath "C:\Projects\MyRepo" -Profile web-developer
    Deploys to a specific path with the web-developer profile.
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$TargetPath,

    [Parameter()]
    [ValidateSet('minimal', 'web-developer', 'python-developer', 'full-stack')]
    [string]$Profile,

    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Determine paths
$scriptRoot = $PSScriptRoot
$aimRoot = Split-Path -Parent $scriptRoot

if ([string]::IsNullOrEmpty($TargetPath)) {
    # Default to parent of .aim folder (assumes .aim is in target repo)
    $TargetPath = Split-Path -Parent $aimRoot
}

$configFile = Join-Path $TargetPath 'aim.json'

Write-Host 'AIM Deploy' -ForegroundColor Cyan
Write-Host '==========' -ForegroundColor Cyan
Write-Host ''
Write-Host "Target path: $TargetPath"
Write-Host "AIM source:  $aimRoot"
Write-Host ''

# Check if aim.json already exists
if ((Test-Path $configFile) -and -not $Force) {
    Write-Host 'aim.json already exists. Use -Force to overwrite.' -ForegroundColor Yellow
    Write-Host 'Running build to regenerate AGENTS.md...' -ForegroundColor Yellow
    & "$scriptRoot\build-agents-md.ps1" -TargetPath $TargetPath
    exit 0
}

# Load profile or create default config
$config = @{
    '$schema' = 'https://raw.githubusercontent.com/tablackburn/ai-agent-instruction-modules/main/schema.json'
    version = '1.0.0'
    modules = @{
        'core/agent-workflow' = $true
        'core/code-quality' = $true
        'core/security' = $true
    }
    fallback = @{
        enabled = $true
        source = 'https://github.com/github/awesome-copilot'
        branch = 'main'
        basePath = 'instructions'
    }
    customInstructionsPath = $null
}

if ($Profile) {
    $profilePath = Join-Path $aimRoot "config\profiles\$Profile.json"
    if (Test-Path $profilePath) {
        Write-Host "Applying profile: $Profile" -ForegroundColor Green
        $profileConfig = Get-Content $profilePath -Raw | ConvertFrom-Json -AsHashtable
        # Merge profile modules into config
        foreach ($key in $profileConfig.modules.Keys) {
            $config.modules[$key] = $profileConfig.modules[$key]
        }
    }
    else {
        Write-Warning "Profile '$Profile' not found at $profilePath. Using defaults."
    }
}

# Write config file
$configJson = $config | ConvertTo-Json -Depth 10
Set-Content -Path $configFile -Value $configJson -Encoding UTF8

Write-Host 'Created aim.json' -ForegroundColor Green

# Generate AGENTS.md
Write-Host ''
Write-Host 'Generating AGENTS.md...' -ForegroundColor Cyan
& "$scriptRoot\build-agents-md.ps1" -TargetPath $TargetPath

Write-Host ''
Write-Host 'Deployment complete!' -ForegroundColor Green
Write-Host ''
Write-Host 'Next steps:' -ForegroundColor Yellow
Write-Host '  1. Edit aim.json to enable/disable modules'
Write-Host '  2. Run .\.aim\scripts\build-agents-md.ps1 to regenerate AGENTS.md'
Write-Host '  3. Commit AGENTS.md and aim.json to your repository'
Write-Host ''
