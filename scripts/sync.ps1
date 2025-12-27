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

    # Handle both string format ("awesome-copilot") and object format ({ source: "awesome-copilot", sha256: "..." })
    $source = $null
    $expectedHash = $null

    if ($moduleValue -eq 'awesome-copilot') {
        $source = 'awesome-copilot'
    }
    elseif ($moduleValue -is [hashtable] -and $moduleValue.source -eq 'awesome-copilot') {
        $source = 'awesome-copilot'
        $expectedHash = $moduleValue.sha256
    }

    if ($source -eq 'awesome-copilot') {
        $fallbackModules += @{
            Name = $moduleName
            ExpectedHash = $expectedHash
        }
    }
}

if ($fallbackModules.Count -gt 0 -and $config.fallback.enabled) {
    Write-Host 'Fetching awesome-copilot fallback modules...' -ForegroundColor Yellow

    # Security: Validate fallback source URL
    $fallbackSource = $config.fallback.source
    $allowedHosts = @(
        'github.com',
        'raw.githubusercontent.com',
        'gitlab.com'
    )

    try {
        $sourceUri = [System.Uri]::new($fallbackSource)

        # Enforce HTTPS
        if ($sourceUri.Scheme -ne 'https') {
            Write-Error "Security: Fallback source must use HTTPS. Got: $($sourceUri.Scheme)"
            exit 1
        }

        # Validate against allowed hosts
        $isAllowedHost = $false
        foreach ($allowedHost in $allowedHosts) {
            if ($sourceUri.Host -eq $allowedHost -or $sourceUri.Host.EndsWith(".$allowedHost")) {
                $isAllowedHost = $true
                break
            }
        }

        if (-not $isAllowedHost) {
            Write-Error "Security: Fallback source host '$($sourceUri.Host)' is not in the allowed list: $($allowedHosts -join ', ')"
            exit 1
        }
    }
    catch [System.UriFormatException] {
        Write-Error "Security: Invalid fallback source URL: $fallbackSource"
        exit 1
    }

    # Security: Validate branch name (prevent injection)
    $branch = $config.fallback.branch
    if ($branch -notmatch '^[a-zA-Z0-9._-]+$') {
        Write-Error "Security: Invalid branch name '$branch'. Branch names must contain only alphanumeric characters, dots, underscores, and hyphens."
        exit 1
    }

    # Security: Validate basePath (prevent path traversal)
    $basePath = $config.fallback.basePath
    if ($basePath -match '\.\.') {
        Write-Error "Security: Invalid basePath '$basePath'. Path traversal sequences are not allowed."
        exit 1
    }

    # Ensure cache directory exists
    if (-not (Test-Path $cachePath)) {
        New-Item -ItemType Directory -Path $cachePath -Force | Out-Null
    }

    foreach ($moduleInfo in $fallbackModules) {
        $moduleName = $moduleInfo.Name
        $expectedHash = $moduleInfo.ExpectedHash

        # Security: Validate module name format
        if ($moduleName -notmatch '^[a-zA-Z0-9]+/[a-zA-Z0-9_-]+$') {
            Write-Warning "  Skipping invalid module name: $moduleName (must match pattern: category/module-name)"
            continue
        }

        # Map module name to awesome-copilot path
        # e.g., languages/python -> python.instructions.md
        $moduleParts = $moduleName -split '/'
        $fileName = "$($moduleParts[-1]).instructions.md"
        $fallbackUrl = "$($config.fallback.source)/raw/$($config.fallback.branch)/$($config.fallback.basePath)/$fileName"
        $cacheFile = Join-Path $cachePath "$($moduleName -replace '/', '_').md"

        Write-Host "  Fetching: $moduleName -> $fileName"
        try {
            $response = Invoke-WebRequest -Uri $fallbackUrl -UseBasicParsing -ErrorAction Stop
            $content = $response.Content

            # Security: Verify SHA256 hash if specified
            if ($expectedHash) {
                $contentBytes = [System.Text.Encoding]::UTF8.GetBytes($content)
                $hashBytes = [System.Security.Cryptography.SHA256]::Create().ComputeHash($contentBytes)
                $actualHash = [System.BitConverter]::ToString($hashBytes) -replace '-', ''

                if ($actualHash -ne $expectedHash.ToUpper()) {
                    Write-Warning "    Security: Hash mismatch for $moduleName!"
                    Write-Warning "      Expected: $expectedHash"
                    Write-Warning "      Actual:   $actualHash"
                    Write-Warning "    Skipping this module. Update the sha256 in aim.json if the content change is expected."
                    continue
                }
                Write-Host "    Integrity verified (SHA256)" -ForegroundColor Green
            }
            else {
                Write-Host "    Warning: No SHA256 hash specified - content not verified" -ForegroundColor Yellow
            }

            Set-Content -Path $cacheFile -Value $content -Encoding UTF8
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
