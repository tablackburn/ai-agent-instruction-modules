#Requires -Modules Pester

<#
.SYNOPSIS
    Shared test helpers for AIM PowerShell script tests.

.DESCRIPTION
    Provides mock configurations, file system helpers, and assertion utilities
    for testing deploy.ps1, sync.ps1, and build-agents-md.ps1.
#>

# Default test configuration
function New-MockConfig {
    <#
    .SYNOPSIS
        Creates a mock aim.json configuration object.
    #>
    [CmdletBinding()]
    param(
        [hashtable]$Modules = @{
            'core/agent-workflow' = $true
            'core/code-quality'   = $true
            'core/security'       = $true
        },
        [bool]$FallbackEnabled = $true,
        [string]$CustomInstructionsPath = $null
    )

    return @{
        '$schema' = 'https://raw.githubusercontent.com/tablackburn/ai-agent-instruction-modules/main/schema.json'
        version   = '1.0.0'
        modules   = $Modules
        fallback  = @{
            enabled  = $FallbackEnabled
            source   = 'https://github.com/github/awesome-copilot'
            branch   = 'main'
            basePath = 'instructions'
        }
        customInstructionsPath = $CustomInstructionsPath
    }
}

function ConvertTo-MockConfigJson {
    <#
    .SYNOPSIS
        Converts a mock config to JSON string.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config
    )

    return $Config | ConvertTo-Json -Depth 10
}

# Mock module content generators
function New-MockModuleContent {
    <#
    .SYNOPSIS
        Creates mock module content with YAML frontmatter.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Id,

        [Parameter(Mandatory)]
        [string]$Name,

        [string]$Description = 'Test module description',

        [string]$Body = 'This is the module content.'
    )

    return @"
---
id: $Id
name: $Name
description: $Description
applyTo: "**/*"
requires: []
recommends: []
tags: ["test"]
---

# $Name

$Body
"@
}

function New-MockModuleContentWithoutFrontmatter {
    <#
    .SYNOPSIS
        Creates mock module content without YAML frontmatter.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$Body = 'This is the module content.'
    )

    return @"
# $Name

$Body
"@
}

# Profile helpers
function New-MockProfile {
    <#
    .SYNOPSIS
        Creates a mock profile configuration.
    #>
    [CmdletBinding()]
    param(
        [hashtable]$Modules = @{
            'core/agent-workflow' = $true
            'core/code-quality'   = $true
            'core/security'       = $true
        }
    )

    return @{
        modules = $Modules
    }
}

# Changelog helpers
function New-MockChangelog {
    <#
    .SYNOPSIS
        Creates mock CHANGELOG.md content.
    #>
    [CmdletBinding()]
    param(
        [string]$Version = '0.1.0'
    )

    return @"
# Changelog

All notable changes to this project will be documented in this file.

## [$Version] - 2025-01-01

### Added
- Initial release
"@
}

# Web response mock helper
function New-MockWebResponse {
    <#
    .SYNOPSIS
        Creates a mock web response object.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Content,

        [int]$StatusCode = 200
    )

    return [PSCustomObject]@{
        Content    = $Content
        StatusCode = $StatusCode
    }
}

# Script path helpers
function Get-TestScriptPaths {
    <#
    .SYNOPSIS
        Returns paths to the scripts being tested.
    #>
    [CmdletBinding()]
    param()

    $TestRoot = $PSScriptRoot
    $AimRoot = Split-Path -Parent $TestRoot
    $ScriptsPath = Join-Path $AimRoot 'scripts'

    return @{
        AimRoot       = $AimRoot
        ScriptsPath   = $ScriptsPath
        DeployScript  = Join-Path $ScriptsPath 'deploy.ps1'
        SyncScript    = Join-Path $ScriptsPath 'sync.ps1'
        BuildScript   = Join-Path $ScriptsPath 'build-agents-md.ps1'
        Instructions  = Join-Path $AimRoot 'instructions'
        Profiles      = Join-Path $AimRoot 'config\profiles'
    }
}

# Output capture helpers
$script:CapturedOutput = @{
    Host     = @()
    Warning  = @()
    Error    = @()
    Files    = @{}
}

function Clear-CapturedOutput {
    <#
    .SYNOPSIS
        Clears all captured output.
    #>
    $script:CapturedOutput = @{
        Host     = @()
        Warning  = @()
        Error    = @()
        Files    = @{}
    }
}

function Get-CapturedOutput {
    <#
    .SYNOPSIS
        Returns captured output for assertions.
    #>
    return $script:CapturedOutput
}

function Add-CapturedHost {
    param([string]$Message)
    $script:CapturedOutput.Host += $Message
}

function Add-CapturedWarning {
    param([string]$Message)
    $script:CapturedOutput.Warning += $Message
}

function Add-CapturedFile {
    param(
        [string]$Path,
        [string]$Content
    )
    $script:CapturedOutput.Files[$Path] = $Content
}

# Export functions
Export-ModuleMember -Function @(
    'New-MockConfig'
    'ConvertTo-MockConfigJson'
    'New-MockModuleContent'
    'New-MockModuleContentWithoutFrontmatter'
    'New-MockProfile'
    'New-MockChangelog'
    'New-MockWebResponse'
    'Get-TestScriptPaths'
    'Clear-CapturedOutput'
    'Get-CapturedOutput'
    'Add-CapturedHost'
    'Add-CapturedWarning'
    'Add-CapturedFile'
)
