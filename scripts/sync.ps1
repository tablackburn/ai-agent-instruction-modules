<#
.SYNOPSIS
    Syncs the latest AIM modules and regenerates AGENTS.md.

.DESCRIPTION
    This script updates AIM by:
    1. Pulling the latest changes from the AIM repository
    2. Fetching any awesome-copilot fallback modules
    3. Regenerating AGENTS.md from enabled modules

    The aim.json configuration is preserved during sync.

.PARAMETER TargetPath
    The path to the target repository. Defaults to parent directory of .aim folder.

.PARAMETER SkipPull
    Skip pulling latest changes from the AIM repository.

.EXAMPLE
    .\sync.ps1
    Syncs and regenerates AGENTS.md.

.EXAMPLE
    .\sync.ps1 -SkipPull
    Regenerates AGENTS.md without pulling latest changes.
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$TargetPath,

    [Parameter()]
    [switch]$SkipPull
)

$ErrorActionPreference = 'Stop'

# Determine paths
$scriptRoot = $PSScriptRoot
$aimRoot = Split-Path -Parent $scriptRoot

if ([string]::IsNullOrEmpty($TargetPath)) {
    $TargetPath = Split-Path -Parent $aimRoot
}

$configFile = Join-Path $TargetPath 'aim.json'
$cachePath = Join-Path $TargetPath '.aim-cache'

Write-Host 'AIM Sync' -ForegroundColor Cyan
Write-Host '========' -ForegroundColor Cyan
Write-Host ''

# Check for aim.json
if (-not (Test-Path $configFile)) {
    Write-Error "aim.json not found at $configFile. Run deploy.ps1 first."
    exit 1
}

# Pull latest AIM changes
if (-not $SkipPull) {
    Write-Host 'Pulling latest AIM updates...' -ForegroundColor Yellow
    Push-Location $aimRoot
    try {
        $gitStatus = git status --porcelain 2>&1
        if ($LASTEXITCODE -eq 0) {
            git pull --ff-only 2>&1 | ForEach-Object { Write-Host "  $_" }
            if ($LASTEXITCODE -ne 0) {
                Write-Warning 'Git pull failed. Continuing with existing modules.'
            }
        }
        else {
            Write-Host '  Not a git repository or git not available. Skipping pull.' -ForegroundColor Yellow
        }
    }
    finally {
        Pop-Location
    }
    Write-Host ''
}

# Load configuration
$config = Get-Content $configFile -Raw | ConvertFrom-Json -AsHashtable

# Fetch awesome-copilot fallback modules
$fallbackModules = @()
foreach ($moduleName in $config.modules.Keys) {
    $moduleValue = $config.modules[$moduleName]
    if ($moduleValue -eq 'awesome-copilot') {
        $fallbackModules += $moduleName
    }
}

if ($fallbackModules.Count -gt 0 -and $config.fallback.enabled) {
    Write-Host 'Fetching awesome-copilot fallback modules...' -ForegroundColor Yellow

    # Ensure cache directory exists
    if (-not (Test-Path $cachePath)) {
        New-Item -ItemType Directory -Path $cachePath -Force | Out-Null
    }

    foreach ($moduleName in $fallbackModules) {
        # Map module name to awesome-copilot path
        # e.g., languages/python -> python.instructions.md
        $moduleParts = $moduleName -split '/'
        $fileName = "$($moduleParts[-1]).instructions.md"
        $fallbackUrl = "$($config.fallback.source)/raw/$($config.fallback.branch)/$($config.fallback.basePath)/$fileName"
        $cacheFile = Join-Path $cachePath "$($moduleName -replace '/', '_').md"

        Write-Host "  Fetching: $moduleName -> $fileName"
        try {
            $response = Invoke-WebRequest -Uri $fallbackUrl -UseBasicParsing -ErrorAction Stop
            Set-Content -Path $cacheFile -Value $response.Content -Encoding UTF8
            Write-Host "    Cached: $cacheFile" -ForegroundColor Green
        }
        catch {
            Write-Warning "    Failed to fetch $fallbackUrl : $_"
        }
    }
    Write-Host ''
}

# Regenerate AGENTS.md
Write-Host 'Regenerating AGENTS.md...' -ForegroundColor Cyan
& "$scriptRoot\build-agents-md.ps1" -TargetPath $TargetPath

Write-Host ''
Write-Host 'Sync complete!' -ForegroundColor Green
