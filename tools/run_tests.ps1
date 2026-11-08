<#
.SYNOPSIS
    Builds the gooey project headlessly with GameMaker's Igor CLI, runs the automated test room and reports the result.

.DESCRIPTION
    1. Copies the project to a temporary folder (so the working tree is never touched), without .git/builds.
    2. Makes `rm_gooey_tests` the first room of the copy.
    3. Copies the GameMaker prefab(s) the project depends on into <copy>/prefabs (Igor otherwise cannot find them).
    4. Runs `Igor windows Run` (VM runtime) and captures the game's console output.
    5. Parses the "[GOOEY-TEST]" lines, prints a summary, writes a JUnit XML report and exits with 0 (all passed) or 1.

    Requirements: Windows with GameMaker installed (any edition that ships the runtime + Igor) and a logged-in desktop session
    (the tests create a real window and use surfaces). See docs/TESTING.md for CI notes.

.PARAMETER Filter
    Only run tests whose "Suite :: test" name contains this text (case-insensitive). Passed to the runner via an environment variable.

.PARAMETER RuntimePath
    GameMaker runtime folder (contains bin\igor). Default: newest runtime found under %ProgramData%\GameMakerStudio2*\Cache\runtimes.

.PARAMETER UserFolder
    GameMaker user folder (contains licence + settings). Default: the first folder under %APPDATA%\GameMakerStudio2*.

.PARAMETER PrefabsFolder
    Folder with installed prefab packages. Default: %ProgramData%\GameMakerStudio2*\Prefabs.

.PARAMETER Output
    Folder where the JUnit XML and raw log are written. Default: tests\results.

.PARAMETER TimeoutSeconds
    Maximum time for the whole build + run. Default: 600.

.PARAMETER Keep
    Keep the temporary project copy (useful for debugging build errors).
#>
[CmdletBinding()]
param(
    [string]$Filter = "",
    [string]$RuntimePath = "",
    [string]$UserFolder = "",
    [string]$PrefabsFolder = "",
    [string]$Output = "",
    [int]$TimeoutSeconds = 600,
    [switch]$Keep
)

$ErrorActionPreference = "Stop"
$repo = Resolve-Path (Join-Path $PSScriptRoot "..")

# Static documentation/implementation consistency check (fast, needs only Python)
$python = Get-Command python -ErrorAction SilentlyContinue
if ($python) {
    & $python.Source (Join-Path $PSScriptRoot "check_docs.py")
    if ($LASTEXITCODE -ne 0) { Write-Host "Documentation check FAILED" -ForegroundColor Red; exit 1 }
}
else { Write-Host "python not found: skipping the documentation check" -ForegroundColor Yellow }
if (-not $Output) { $Output = Join-Path $repo "tests\results" }
New-Item -ItemType Directory -Force $Output | Out-Null

function Find-Newest($patterns) {
    foreach ($p in $patterns) {
        $hit = Get-ChildItem -Path $p -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($hit) { return $hit.FullName }
    }
    return ""
}

if (-not $RuntimePath) {
    $RuntimePath = Find-Newest @("$env:ProgramData\GameMakerStudio2*\Cache\runtimes\runtime-*")
}
if (-not $RuntimePath) { throw "GameMaker runtime not found. Pass -RuntimePath." }
$igor = Join-Path $RuntimePath "bin\igor\windows\x64\Igor.exe"
if (-not (Test-Path $igor)) { throw "Igor not found at $igor" }
if (-not $UserFolder)    { $UserFolder = Find-Newest @("$env:APPDATA\GameMakerStudio2*\*_*") }
if (-not $UserFolder)    { throw "GameMaker user folder not found. Pass -UserFolder." }
if (-not $PrefabsFolder) { $PrefabsFolder = Find-Newest @("$env:ProgramData\GameMakerStudio2*\Prefabs") }

$work = Join-Path ([System.IO.Path]::GetTempPath()) ("gooey_tests_" + [guid]::NewGuid().ToString("N").Substring(0, 8))
$proj = Join-Path $work "project"
New-Item -ItemType Directory -Force $proj | Out-Null
Write-Host "Copying project to $proj ..."
robocopy $repo $proj /E /XD .git builds tests\results .claude /NFL /NDL /NJH /NJS /NP | Out-Null

# Make the test room the first room
$yyp = Get-ChildItem $proj -Filter *.yyp | Select-Object -First 1
$text = [System.IO.File]::ReadAllText($yyp.FullName)
$room = '{"roomId":{"name":"rm_gooey_tests","path":"rooms/rm_gooey_tests/rm_gooey_tests.yy",},},'
if ($text -notmatch [regex]::Escape($room)) { throw "rm_gooey_tests is not registered in the room order of $($yyp.Name)" }
$text = $text -replace ('(\r?\n)\s*' + [regex]::Escape($room)), ''
$text = $text -replace '("RoomOrderNodes":\[\r?\n)', ('$1    ' + $room + "`r`n")
[System.IO.File]::WriteAllText($yyp.FullName, $text)

# Prefabs the project links to (Igor looks in <project>\prefabs)
if ($PrefabsFolder -and (Test-Path $PrefabsFolder)) {
    $links = [regex]::Matches($text, '"link":"([^"]+)"') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
    foreach ($l in $links) {
        $src = Join-Path $PrefabsFolder $l
        if (Test-Path $src) {
            New-Item -ItemType Directory -Force (Join-Path $proj "prefabs") | Out-Null
            Copy-Item -Recurse -Force $src (Join-Path $proj "prefabs")
        }
    }
}

if ($Filter) { $env:GOOEY_TEST_FILTER = $Filter } else { Remove-Item Env:\GOOEY_TEST_FILTER -ErrorAction SilentlyContinue }

$log = Join-Path $Output "igor.log"
$err = Join-Path $Output "igor.err.log"
$args = @(
    "--project=$($yyp.FullName)",
    "--user=$UserFolder",
    "--runtimePath=$RuntimePath",
    "--cache=$(Join-Path $work 'cache')",
    "--temp=$(Join-Path $work 'temp')",
    "--runtime=VM",
    "--timeout=$TimeoutSeconds",
    "--", "windows", "Run"
)
New-Item -ItemType Directory -Force (Join-Path $work "cache"), (Join-Path $work "temp") | Out-Null
Write-Host "Building and running tests with Igor (this takes a little while) ..."
$p = Start-Process -FilePath $igor -ArgumentList $args -RedirectStandardOutput $log -RedirectStandardError $err -NoNewWindow -PassThru
if (-not $p.WaitForExit($TimeoutSeconds * 1000)) {
    try { $p.Kill($true) } catch {}
    Write-Host "TIMEOUT after $TimeoutSeconds s" -ForegroundColor Red
    $timedOut = $true
}

$lines = @(Get-Content $log -ErrorAction SilentlyContinue)
$tests = $lines | Where-Object { $_ -match '\[GOOEY-TEST\]' -and $_ -notmatch 'XML-' }
$buildErrors = $lines | Where-Object { $_ -match '^(Error|error)\s*:' }

# Extract the XML block
$xml = @()
$inXml = $false
foreach ($l in $lines) {
    if ($l -match '\[GOOEY-TEST\] XML-END')   { $inXml = $false }
    if ($inXml) { $xml += $l }
    if ($l -match '\[GOOEY-TEST\] XML-BEGIN') { $inXml = $true }
}
if ($xml.Count -gt 0) { Set-Content -Path (Join-Path $Output "junit.xml") -Value $xml -Encoding UTF8 }

$tests | Where-Object { $_ -match ' (FAIL|ERROR) ' } | ForEach-Object { Write-Host $_ -ForegroundColor Red }
$summary = $tests | Where-Object { $_ -match 'SUMMARY' } | Select-Object -Last 1
$result  = $tests | Where-Object { $_ -match 'RESULT:' } | Select-Object -Last 1

if (-not $Keep) { Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue } else { Write-Host "Kept $work" }

if ($buildErrors) {
    Write-Host "`nBuild errors:" -ForegroundColor Red
    $buildErrors | Select-Object -First 20 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
}
if ($summary) { Write-Host "`n$summary" }
if ($result -and $result -match 'PASS' -and -not $buildErrors -and -not $timedOut) {
    Write-Host "ALL GOOEY TESTS PASSED" -ForegroundColor Green
    Write-Host "Reports: $Output"
    exit 0
}
Write-Host "GOOEY TESTS FAILED (see $log)" -ForegroundColor Red
exit 1
