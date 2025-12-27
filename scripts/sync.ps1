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
$ScriptRoot = $PSScriptRoot
$AimRoot = Split-Path -Parent $ScriptRoot

if ([string]::IsNullOrEmpty($TargetPath)) {
    $TargetPath = Split-Path -Parent $AimRoot
}

$ConfigFile = Join-Path $TargetPath 'aim.json'
$CachePath = Join-Path $TargetPath '.aim-cache'

Write-Host "AIM Sync" -ForegroundColor Cyan
Write-Host "========" -ForegroundColor Cyan
Write-Host ""

# Check for aim.json
if (-not (Test-Path $ConfigFile)) {
    Write-Error "aim.json not found at $ConfigFile. Run deploy.ps1 first."
    exit 1
}

# Pull latest AIM changes
if (-not $SkipPull) {
    Write-Host "Pulling latest AIM updates..." -ForegroundColor Yellow
    Push-Location $AimRoot
    try {
        $GitStatus = git status --porcelain 2>&1
        if ($LASTEXITCODE -eq 0) {
            git pull --ff-only 2>&1 | ForEach-Object { Write-Host "  $_" }
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Git pull failed. Continuing with existing modules."
            }
        }
        else {
            Write-Host "  Not a git repository or git not available. Skipping pull." -ForegroundColor Yellow
        }
    }
    finally {
        Pop-Location
    }
    Write-Host ""
}

# Load configuration
$Config = Get-Content $ConfigFile -Raw | ConvertFrom-Json -AsHashtable

# Fetch awesome-copilot fallback modules
$FallbackModules = @()
foreach ($moduleName in $Config.modules.Keys) {
    $moduleValue = $Config.modules[$moduleName]
    if ($moduleValue -eq 'awesome-copilot') {
        $FallbackModules += $moduleName
    }
}

if ($FallbackModules.Count -gt 0 -and $Config.fallback.enabled) {
    Write-Host "Fetching awesome-copilot fallback modules..." -ForegroundColor Yellow

    # Ensure cache directory exists
    if (-not (Test-Path $CachePath)) {
        New-Item -ItemType Directory -Path $CachePath -Force | Out-Null
    }

    foreach ($moduleName in $FallbackModules) {
        # Map module name to awesome-copilot path
        # e.g., languages/python -> python.instructions.md
        $ModuleParts = $moduleName -split '/'
        $FileName = "$($ModuleParts[-1]).instructions.md"
        $FallbackUrl = "$($Config.fallback.source)/raw/$($Config.fallback.branch)/$($Config.fallback.basePath)/$FileName"
        $CacheFile = Join-Path $CachePath "$($moduleName -replace '/', '_').md"

        Write-Host "  Fetching: $moduleName -> $FileName"
        try {
            $Response = Invoke-WebRequest -Uri $FallbackUrl -UseBasicParsing -ErrorAction Stop
            Set-Content -Path $CacheFile -Value $Response.Content -Encoding UTF8
            Write-Host "    Cached: $CacheFile" -ForegroundColor Green
        }
        catch {
            Write-Warning "    Failed to fetch $FallbackUrl : $_"
        }
    }
    Write-Host ""
}

# Regenerate AGENTS.md
Write-Host "Regenerating AGENTS.md..." -ForegroundColor Cyan
& "$ScriptRoot\build-agents-md.ps1" -TargetPath $TargetPath

Write-Host ""
Write-Host "Sync complete!" -ForegroundColor Green
