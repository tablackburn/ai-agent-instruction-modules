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
    <#
    .SYNOPSIS
    Formats a raw result object for display.

    .PARAMETER Value
    The raw result object to format.
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [psobject]
        $Value
    )
    # Helper logic
}


function Get-Data {
    <#
    .SYNOPSIS
    Retrieves the data record for a named entity.

    .PARAMETER Name
    The name of the entity to retrieve.
    #>
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
    <#
    .SYNOPSIS
    Processes each item received from the pipeline.

    .PARAMETER InputData
    The item to process, accepted from the pipeline.
    #>
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
        [ValidateNotNull()]
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
$backupPath = 'C:\Backups'
$backupFiles = Get-ChildItem -Path $backupPath -Filter '*.bak'
$activeUsers = Get-ADUser -Filter { Enabled -eq $true }

# Bad - generic variable names
$files = Get-ChildItem -Path $backupPath -Filter '*.bak'
$users = Get-ADUser -Filter { Enabled -eq $true }
```

### Path vs Directory Naming

Use the appropriate suffix to indicate what the variable holds:

- Use `Path` for any string that names a location, whether it points at a file or a folder,
  and whether it is absolute, relative, or a bare folder name
- Reserve `Directory` for directory objects (e.g., `[System.IO.DirectoryInfo]`)

```powershell
# Good - Path suffix for path strings
$configurationPath = Join-Path -Path $PSScriptRoot -ChildPath 'config.json'
$outputPath = Join-Path -Path $PSScriptRoot -ChildPath 'results'
$backupPath = 'C:\Backups'
$moduleFolderPath = 'MyModule'

# Good - Directory suffix for a directory object
$logDirectory = [System.IO.DirectoryInfo]::new('C:\Logs')

# Bad - Directory suffix on a path string
$outputDirectory = 'C:\App\results'
$moduleFolderDirectory = 'MyModule'
```

## Parameters

1. Name parameters on calls that pass two or more arguments; a single-argument call may stay
   positional. Naming disambiguates which value maps to which parameter when there are several;
   with one argument there is nothing to disambiguate, so naming it only adds noise.
2. Always use quotes around string parameter values
3. Include validation on every parameter
4. Place each component on its own line

```powershell
# Good - 2+ arguments: name them (no positional guessing)
Get-ChildItem -Path 'C:\Logs' -Filter '*.log' -Recurse
Copy-Item -Path $sourcePath -Destination $destinationPath

# Good - single argument: positional is fine
Test-Path $configurationPath
Import-Module $modulePath

# Avoid - naming the only argument adds noise without removing ambiguity
Test-Path -Path $configurationPath
```

```powershell
# Good - string parameter values are quoted
Get-Process 'powershell'
Get-ChildItem -Path 'C:\Program Files' -Filter '*.txt'

# Bad - bare string parameter values
Get-Process powershell
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
$invokeRestMethodParameters = @{
    Uri     = 'https://api.example.com/endpoint'
    Method  = 'Post'
    Headers = $headers
    Body    = $body
}
Invoke-RestMethod @invokeRestMethodParameters
```

## Line Continuation

1. Do not use backtick (`` ` ``) line continuation
2. Do not use semicolons (`;`) to chain multiple statements on one line
3. Prefer splatting (`@copyItemParameters`) for long parameter lists
4. Use natural continuation inside `()`, `@{}`, or `@()` when grouping expressions or collections
5. Place each hashtable element on its own line in multi-line hashtables
6. Pipelines continue without backticks when the line ends with `|`

```powershell
# Good - splatting for long parameter lists
$copyItemParameters = @{
    Path        = $sourcePath
    Destination = $destinationPath
    Recurse     = $true
    Force       = $true
}
Copy-Item @copyItemParameters

# Good - pipeline continues across lines
Get-ChildItem -Path $sourceDirectory -Recurse |
    Where-Object { $_.Length -gt 1MB } |
    Sort-Object -Property 'Length' -Descending

# Good - natural continuation inside parentheses
$summaryMessage = (
    "Processed $successCount of $totalCount records. " +
    "Skipped $skipCount records. " +
    "Encountered $errorCount errors."
)

# Good - for-loop semicolons are syntactic, not statement chaining
for ($i = 0; $i -lt 10; $i++) {
    Write-Output -InputObject $i
}

# Good - hashtable with each element on its own line
$webRequestOptions = @{
    Name = 'Value'
    Size = 100
}

# Bad - backtick line continuation
Copy-Item -Path $sourcePath `
    -Destination $destinationPath `
    -Recurse `
    -Force

# Bad - semicolons chaining statements
Import-Module -Name 'PSReadLine'; Set-PSReadLineOption -EditMode 'Emacs'

# Bad - hashtable elements chained with semicolons on one line
$webRequestOptions = @{ Name = 'Value'; Size = 100 }
```

## Paths and File System

1. Use `$PSScriptRoot` for script-relative paths
2. Use `$Env:UserProfile` or `$HOME` instead of `~`
3. Use `Join-Path` to construct paths

```powershell
# Good
$configurationPath = Join-Path -Path $PSScriptRoot -ChildPath 'config.json'
$documentsPath = Join-Path -Path $Env:UserProfile -ChildPath 'Documents'

# Bad
$configurationPath = '.\config.json'
$documentsPath = '~\Documents'
```

## Error Handling

1. Use `-ErrorAction 'Stop'` for cmdlets within try/catch
2. Immediately copy `$_` in catch blocks before other commands

```powershell
$filePath = 'C:\Data\settings.json'
try {
    Get-Item -Path $filePath -ErrorAction 'Stop'
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
        [PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [PSCredential]::Empty
    )

    # Check if credentials were provided
    if ($Credential -eq [PSCredential]::Empty) {
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
    $result = Format-Item -InputObject $item
    $result  # Output immediately
}

# Bad - batching
$results = @()
foreach ($item in $collection) {
    $results += Format-Item -InputObject $item
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

## Pester

### Skipping Tests

`Set-ItResult -Skipped` (and `-Inconclusive`) ends the `It` block immediately - it throws an
internal error record that Pester catches and records as the test result. Code after the call
does not run, so a trailing `return` is unreachable dead code; do not add one. Reviewers,
including automated ones, recurrently suggest the redundant `return`.

```powershell
# Good - Set-ItResult ends the test; nothing after it runs
It 'Validates the required version' {
    if (-not $dependency.ContainsKey('RequiredVersion')) {
        Set-ItResult -Skipped -Because 'No RequiredVersion to validate'
    }
    Test-VersionConstraint -Version $dependency.RequiredVersion | Should -BeTrue
}

# Bad - the return can never execute; Set-ItResult already threw
It 'Validates the required version' {
    if (-not $dependency.ContainsKey('RequiredVersion')) {
        Set-ItResult -Skipped -Because 'No RequiredVersion to validate'
        return
    }
    Test-VersionConstraint -Version $dependency.RequiredVersion | Should -BeTrue
}
```

Prefer `-Skip:$condition` on `It`, `Context`, or `Describe` when the condition is known at
discovery time; reserve `Set-ItResult -Skipped` for conditions only known at runtime inside
the test body.

```powershell
# Good - a discovery-time condition uses the -Skip parameter
It 'Runs only on Windows' -Skip:(-not $IsWindows) {
    Get-Service | Should -Not -BeNullOrEmpty
}
```

`-Skip:` is evaluated during discovery, so its expression can only read state that exists at
discovery time: automatic variables, script-scope values, and the current `-ForEach` item. A
`-Skip:` expression that reads a variable assigned in `BeforeAll` sees `$null`, because
`BeforeAll` does not run until execution. The test then skips unconditionally, and a skipped
test reads as a passing build.

```powershell
# Good - the condition reads -ForEach data, which exists during discovery
It 'Reports the expected track count' -ForEach $albums -Skip:($null -eq $_.ExpectedTracks) {
    (Get-Album -Name $_.Name).Tracks.Count | Should -Be $_.ExpectedTracks
}

# Bad - $expectedTracks is assigned in BeforeAll, so -Skip: sees $null and always skips
BeforeAll {
    $expectedTracks = Get-ExpectedTrackCount
}

It 'Reports the expected track count' -Skip:($null -eq $expectedTracks) {
    (Get-Album -Name 'Example').Tracks.Count | Should -Be $expectedTracks
}
```

Compare against `$null` explicitly in skip conditions instead of relying on truthiness.
`-not 0` is `$true`, so a legitimately configured `0` silently skips the test that was meant
to verify it.

```powershell
# Good - only a missing value skips
It 'Honors the retry limit' -ForEach $cases -Skip:($null -eq $_.RetryLimit) {
    (Get-RetryPolicy).Limit | Should -Be $_.RetryLimit
}

# Bad - a configured RetryLimit of 0 skips too
It 'Honors the retry limit' -ForEach $cases -Skip:(-not $_.RetryLimit) {
    (Get-RetryPolicy).Limit | Should -Be $_.RetryLimit
}
```

### Pester Version Pinning

Never pin Pester to an exact version in a dependency manifest such as `*.depend.psd1`; use
`Version = 'latest'`. Pester 6 runs discovery for each test file separately, and resolving
`Describe` triggers PowerShell module autoloading. Autoloading always selects the highest
installed version, overriding whatever version was explicitly imported beforehand. A pin below
the version already baked into the CI runner image therefore can never be honored, and the run
fails during discovery:

```text
Could not load file or assembly 'Pester, Version=6.0.1.0'. Assembly with same name is already loaded
```

This was observed twice on hosted runners: one module repository pinned `6.0.1` against an
image carrying `6.1.0` and all 19 of its test files failed to run, and another repository's CI
was red for eight days for the same reason.

```powershell
# Good - always resolve whatever Pester the runner already has
@{
    Pester = @{
        Version = 'latest'
    }
}

# Bad - a pin below the runner's installed version can never win against autoloading
@{
    Pester = @{
        Version = '6.0.1'
    }
}
```

### Data-Driven Tests with -ForEach

An empty or `$null` `-ForEach` collection throws in Pester 6; Pester 5 silently generated no
tests instead. The throw happens during discovery, so it kills the whole container, and a
container that dies during discovery does not increment `FailedCount`. The build stays green
while every test in that file silently disappears.

Add `-AllowNullOrEmptyForEach` only to collections that can legitimately be empty. Leave it off
wherever an empty collection means something upstream is broken - there the throw is the signal
that is wanted.

```powershell
# Good - an optional set of extra cases may legitimately be empty
Describe 'Optional case' -ForEach $optionalCase -AllowNullOrEmptyForEach {
    It 'Runs when the case exists' {
        $_ | Should -Not -BeNullOrEmpty
    }
}

# Bad - hides a glob that matched no public functions at all
Describe 'Public function' -ForEach $publicFunction -AllowNullOrEmptyForEach {
    It 'Has comment-based help' {
        Get-Help -Name $_.Name | Should -Not -BeNullOrEmpty
    }
}
```

### Gating the Build on Pester Results

Gate the build on `$testResult.FailedContainersCount`, not on filtering `Containers` by
`Passed`. A container that died during discovery still reports `Passed = $true`, so the obvious
filter matches nothing and silently reproduces the very failure it was written to catch.

Also assert that tests actually ran, using `PassedCount + FailedCount`. `TotalCount` includes
tests that never ran, and skipped tests report `Executed = $true` and are not counted in
`NotRunCount`, so only passed plus failed distinguishes a suite that ran from one that did not.

```powershell
# Good - catches failed tests, dead containers, and a suite that never ran
$testResult = Invoke-Pester -Configuration $pesterConfiguration
if ($testResult.FailedCount -gt 0) {
    throw "$($testResult.FailedCount) test(s) failed"
}

if ($testResult.FailedContainersCount -gt 0) {
    throw "$($testResult.FailedContainersCount) container(s) failed during discovery"
}

if (($testResult.PassedCount + $testResult.FailedCount) -eq 0) {
    throw 'No tests executed'
}

# Bad - a container that failed discovery still reports Passed = $true, so this matches nothing
$failedContainer = $testResult.Containers | Where-Object { -not $_.Passed }
if ($failedContainer) {
    throw 'Container failure'
}

# Bad - TotalCount includes tests that never ran, so it hides an empty run
if ($testResult.TotalCount -eq 0) {
    throw 'No tests executed'
}
```

### InModuleScope Placement

Put `InModuleScope` inside the `Context` or `It` that needs it; never wrap it around `Describe`
or `It`. Pester's own documentation advises against that enclosing placement, because a
wrapping `InModuleScope` forces the module to load during discovery rather than execution.
Combined with Pester 6 discovering each test file separately, those discovery-time imports
accumulate across files until a later file's discovery hard-errors:

```text
Multiple script or manifest modules named 'ExampleModule' are currently loaded
```

Prefer the documented `InModuleScope -ModuleName <Name> -ScriptBlock { }` form inside the block
that needs module-internal access.

```powershell
# Good - the module loads during execution, inside the block that needs it
Describe 'Get-Thing' {
    It 'Calls the private helper' {
        InModuleScope -ModuleName 'ExampleModule' -ScriptBlock {
            Get-Thing -Name 'example' | Should -Not -BeNullOrEmpty
        }
    }
}

# Bad - forces a module import during discovery of every file that does this
InModuleScope 'ExampleModule' {
    Describe 'Get-Thing' {
        It 'Calls the private helper' {
            Get-Thing -Name 'example' | Should -Not -BeNullOrEmpty
        }
    }
}
```

### Matching Test Files Cross-Platform

`Get-ChildItem -Filter` is case-sensitive on Linux and case-insensitive on Windows. A build
script that collects test files with `-Filter` therefore finds them on Windows runners and
silently finds none on Linux ones, which reads as a passing build with zero tests. Match on
`Where-Object` with `-like`, which is case-insensitive on every platform.

```powershell
# Good - matches on Windows and Linux runners alike
$testFiles = Get-ChildItem -Path $testPath -Recurse -File |
    Where-Object { $_.Name -like '*.Tests.ps1' }

# Bad - case-sensitive on Linux, so 'Example.tests.ps1' is never found there
$testFiles = Get-ChildItem -Path $testPath -Recurse -File -Filter '*.Tests.ps1'
```
