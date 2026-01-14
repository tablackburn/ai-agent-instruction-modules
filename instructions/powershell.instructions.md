---
applyTo: '**/*.ps1,**/*.psm1,**/*.psd1'
description: 'PowerShell coding standards and best practices'
---

# PowerShell Style Guidelines

Style rules for PowerShell code based on Microsoft guidelines and community standards.

## Common Mistakes to Avoid

**IMPORTANT**: These are frequent violations that MUST be avoided:

1. **Plural nouns in function names** - ALWAYS use singular nouns regardless of how many items the
   function returns. Use `Get-User` not `Get-Users`, `Get-Item` not `Get-Items`.

## Function Structure

1. Always start functions with `[CmdletBinding()]` attribute
2. Always include explicit `param()` block
3. Use `process {}` block when accepting pipeline input
4. For system-modifying cmdlets, use `[CmdletBinding(SupportsShouldProcess)]`
5. Document output types with `[OutputType([TypeName])]` attribute
6. Include comment-based help for all functions
7. Do not define nested functions inside other functions; define helper functions at module or
   script scope

```powershell
# Bad - nested function
function Get-Data {
    [CmdletBinding()]
    param()

    function Format-Result {
        param($Value)
        # Helper logic
    }

    $result = Get-RawData
    Format-Result -Value $result
}

# Good - separate functions at module/script scope
function Format-Result {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Value
    )
    # Helper logic
}


function Get-Data {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name
    )

    # Implementation
}

# Function with pipeline input
function Get-PipelineInput {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ValueFromPipeline)]
        [ValidateNotNull()]
        [string]
        $InputData
    )

    process {
        # Process each pipeline item
    }
}
```

## Type Accelerators

Prefer type accelerators over full .NET type names:

- `[string]`, `[int]`, `[bool]`, `[array]`, `[hashtable]`
- `[PSCustomObject]`, `[PSCredential]`, `[datetime]`, `[regex]`

```powershell
# Good - type accelerators in parameter declarations
function Get-Setting {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [hashtable]
        $Configuration
    )
}

# Avoid - full .NET type names
function Get-Setting {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [System.Collections.Hashtable]
        $Configuration
    )
}
```

## Naming Conventions

1. Use approved PowerShell verbs only (verify with `Get-Verb`)
2. Use singular nouns for function names (`Get-Item` not `Get-Items`)
3. Use PascalCase for function names and parameters
4. Use camelCase for local variables (`$userName`, `$itemCount`)
5. Use descriptive variable names that indicate purpose
6. Use full cmdlet names, never aliases (`Get-Process` not `gps`)

```powershell
# Good - descriptive variable names
$backupFiles = Get-ChildItem -Path $backupPath -Filter '*.bak'
$activeUsers = Get-ADUser -Filter { Enabled -eq $true }

# Bad - generic variable names
$files = Get-ChildItem -Path $backupPath -Filter '*.bak'
$users = Get-ADUser -Filter { Enabled -eq $true }
```

### Directory vs Path Naming

Use the appropriate suffix to indicate what the variable represents:

- Use `Path` when the value could be a file or directory
- Use `Directory` when the value is specifically a folder/container

```powershell
# Good - clear distinction
$configurationPath = Join-Path -Path $PSScriptRoot -ChildPath 'settings.json'  # A file
$outputDirectory = Join-Path -Path $PSScriptRoot -ChildPath 'results'          # A folder
$logPath = $Arguments.LogPath  # Could be file or directory, context determines

# Bad - ambiguous or incorrect
$configurationDirectory = 'C:\App\settings.json'  # Not a directory
$outputPath = 'C:\App\results'                    # Actually a directory
```

## Parameters

1. Use full parameter names in scripts and functions
2. Always use quotes around string parameter values
3. Include validation on every parameter
4. Place each component on its own line

```powershell
# Good - string parameter values are quoted
Get-Process -Name 'powershell'
Get-ChildItem -Path 'C:\Program Files' -Filter '*.txt'

# Bad - bare string parameter values
Get-Process -Name powershell
Get-ChildItem -Path C:\Program Files -Filter *.txt
```

```powershell
function Get-UserData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $UserName,

        [Parameter()]
        [ValidateRange(1, 100)]
        [int]
        $MaxResults = 10,

        [Parameter(ValueFromPipeline)]
        [ValidateNotNull()]
        [string[]]
        $ComputerName
    )
}
```

## Formatting

1. Opening brace `{` at end of line, closing brace `}` on new line
2. Use 4 spaces per indentation level
3. Maximum line length: 115 characters
4. Use splatting for long parameter lists
5. Two blank lines before function definitions
6. One blank line at end of file

```powershell
function Test-Code {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(1, 100)]
        [int]
        $Value
    )

    if ($Value -gt 10) {
        Write-Output 'Greater'
    }
    elseif ($Value -eq 10) {
        Write-Output 'Equal'
    }
    else {
        Write-Output 'Lesser'
    }
}

# Good - splatting for readability
$parameters = @{
    Uri     = 'https://api.example.com/endpoint'
    Method  = 'Post'
    Headers = $headers
    Body    = $body
}
Invoke-RestMethod @parameters
```

## Paths and File System

1. Use `$PSScriptRoot` for script-relative paths
2. Use `$Env:UserProfile` or `$HOME` instead of `~`
3. Use `Join-Path` to construct paths

```powershell
# Good
$configPath = Join-Path -Path $PSScriptRoot -ChildPath 'config.json'
$userPath = Join-Path -Path $Env:UserProfile -ChildPath 'Documents'

# Bad
$configPath = '.\config.json'
$userPath = '~\Documents'
```

## Error Handling

1. Use `-ErrorAction 'Stop'` for cmdlets within try/catch
2. Immediately copy `$_` in catch blocks before other commands

```powershell
try {
    Get-Item -Path $path -ErrorAction Stop
}
catch {
    $errorRecord = $_  # Capture immediately
    Write-Error "Failed: $($errorRecord.Exception.Message)"
}
```

## Credential Handling

1. Use `[PSCredential]` for credential parameters, never `[string]` for passwords
2. Make credentials optional when the function can run without them
3. Use `[System.Management.Automation.Credential()]` attribute for flexibility

```powershell
function Connect-Service {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Server,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    # Check if credentials were provided
    if ($Credential -eq [System.Management.Automation.PSCredential]::Empty) {
        # Use current user context
    }
    else {
        # Use provided credentials
    }
}
```

## Output

1. Write objects to pipeline immediately, don't batch into arrays
2. Use `Write-Verbose` for detailed operation information
3. Use `Write-Warning` for potential issues

```powershell
# Good - immediate output
foreach ($item in $collection) {
    $result = Process-Item $item
    $result  # Output immediately
}

# Bad - batching
$results = @()
foreach ($item in $collection) {
    $results += Process-Item $item
}
$results
```

## Documentation

All functions must include comment-based help:

```powershell
function Get-UserData {
    <#
    .SYNOPSIS
    Brief one-line description.

    .DESCRIPTION
    Detailed description of behavior.

    .PARAMETER UserName
    Description of the parameter.

    .EXAMPLE
    Get-UserData -UserName 'jsmith'

    Retrieves data for user jsmith.

    .OUTPUTS
    System.Management.Automation.PSCustomObject
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $UserName
    )

    # Implementation
}
```

## Quotes

1. Use single quotes for string literals
2. Use double quotes only when variable expansion is needed
3. Quote hashtable keys only when necessary (hyphens, spaces)

```powershell
# Good
$headers = @{
    Authorization = "Bearer $token"  # Needs expansion
    'User-Agent'  = 'PowerShell'     # Key has hyphen
}

$branchName = "feature/issue-$issueNumber"
$title = 'Static string'
```

## Spacing

1. Spaces around all operators: `$x = 1 + 2`
2. Spaces around comparison operators: `$value -eq 10`
3. Space after commas and semicolons
4. No trailing spaces

## Semicolons

1. Do not use semicolons as line terminators
2. Place each hashtable element on its own line

```powershell
# Good
$options = @{
    Name = 'Value'
    Size = 100
}

# Bad
$options = @{ Name = 'Value'; Size = 100 }
```

## Build Systems

When a repository uses a build system (psake, Invoke-Build, etc.), use the build system's tasks for
operations like testing, building, publishing, and deployment rather than running commands directly
or creating separate scripts. Check for common build files:

- `psakefile.ps1` or `psake.ps1` (psake)
- `*.build.ps1` (Invoke-Build)
- `build.ps1` (general build script)

```powershell
# Good - use the build system
Invoke-psake -taskList Test
Invoke-Build -Task Test

# Avoid - bypassing the build system
Invoke-Pester -Path .\tests\
```

## Static Analysis

PSScriptAnalyzer warnings indicate real issues. Fix the underlying problem rather than suppressing warnings.

### Warnings to Always Fix

These warnings represent naming and style violations that should be corrected:

- **PSUseSingularNouns** - Rename function to use singular noun (`Get-Item` not `Get-Items`)
- **PSUseApprovedVerbs** - Use an approved verb from `Get-Verb`
- **PSAvoidUsingCmdletAliases** - Replace alias with full cmdlet name
- **PSAvoidUsingWriteHost** - Use `Write-Output`, `Write-Verbose`, or `Write-Information`

```powershell
# Bad - suppressing instead of fixing
function Get-Items {  # PSUseSingularNouns warning
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [CmdletBinding()]
    param()
    # Returns multiple items
}

# Good - fix the naming
function Get-Item {
    [CmdletBinding()]
    param()
    # Returns zero, one, or more items (singular noun is correct regardless)
}
```

### Suppression Requirements

When suppression is genuinely necessary (rare), include a justification:

1. Use `SuppressMessageAttribute` with the `Justification` parameter
2. Explain why the warning cannot be resolved
3. Reference external constraints if applicable

```powershell
# Acceptable - justified suppression for API compatibility
function Get-AWSItems {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseSingularNouns',
        '',
        Justification = 'Matches AWS SDK naming convention for consistency with existing tooling'
    )]
    [CmdletBinding()]
    param()
}
```

### Never Suppress Without Justification

Suppressions without justification are not acceptable:

```powershell
# Never do this
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
```
