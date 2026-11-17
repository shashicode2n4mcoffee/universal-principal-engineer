<#
.SYNOPSIS  Install Universal Principal Engineer skills (Windows). Mirrors install.sh.
.EXAMPLE   .\install.ps1 -User
.EXAMPLE   .\install.ps1 -Project C:\a,C:\b -Handoffs ignore -DryRun
#>
param(
  [switch]$User,
  [string[]]$Project = @(),
  [ValidateSet('', 'ignore', 'commit')][string]$Handoffs = '',
  [switch]$DryRun,
  [switch]$Help
)
$ErrorActionPreference = 'Stop'
if ($Help -or (-not $User -and $Project.Count -eq 0)) {
  Write-Host "Usage: install.ps1 [-User] [-Project <dir>,<dir>] [-Handoffs ignore|commit] [-DryRun]"
  if ($Help) { exit 0 } else { exit 2 }
}
$Src = Split-Path -Parent $PSScriptRoot
$Ver = '6.0'
$Begin = "<!-- UPE:BEGIN v$Ver -->"; $End = '<!-- UPE:END -->'
$Ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$Utf8 = New-Object System.Text.UTF8Encoding($false)

function Read-Text($p) { [IO.File]::ReadAllText($p, $Utf8) }
function Commit-Text($Dst, $Text) {
  if ((Test-Path $Dst) -and ((Read-Text $Dst) -ceq $Text)) { Write-Host "  unchanged  $Dst"; return }
  if ($DryRun) { Write-Host "  would write $Dst"; return }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Dst) | Out-Null
  if (Test-Path $Dst) { Copy-Item $Dst "$Dst.bak-$Ts" }
  [IO.File]::WriteAllText($Dst, $Text, $Utf8); Write-Host "  wrote      $Dst"
}
function Upsert-Block($File, $Body) {
  $blk = "$Begin`n$($Body.TrimEnd())`n$End`n"
  if (Test-Path $File) {
    $cur = Read-Text $File
    if ($cur -match '<!-- UPE:BEGIN') {
      $new = [regex]::Replace($cur, '(?s)<!-- UPE:BEGIN.*?<!-- UPE:END -->\r?\n?', { param($m) $blk }, 1)
    } else { $new = $cur.TrimEnd() + "`n`n" + $blk }
  } else { $new = $blk }
  Commit-Text $File $new
  $script:Man += "BLOCK $File"
}
function Install-Tree($Root, $Mode) {
  $base = Join-Path $Root '.claude'; $script:Man = @()
  Write-Host "Target ($Mode): $Root"
  Get-ChildItem (Join-Path $Src 'skills') -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring((Join-Path $Src 'skills').Length).TrimStart('\','/')
    $dst = Join-Path (Join-Path $base 'skills') $rel
    Commit-Text $dst (Read-Text $_.FullName); $script:Man += "FILE $dst"
  }
  Get-ChildItem (Join-Path $Src 'agents') -Filter *.md -File -ErrorAction SilentlyContinue | ForEach-Object {
    $dst = Join-Path (Join-Path $base 'agents') $_.Name; Commit-Text $dst (Read-Text $_.FullName); $script:Man += "FILE $dst"
  }
  $d = Join-Path $base 'upe\MODEL-POLICY.md'; Commit-Text $d (Read-Text (Join-Path $Src 'MODEL-POLICY.md')); $script:Man += "FILE $d"
  $d = Join-Path $base 'upe\STAGE-HANDOFF.md'; Commit-Text $d (Read-Text (Join-Path $Src 'templates\STAGE-HANDOFF.md')); $script:Man += "FILE $d"
  $agents = Read-Text (Join-Path $Src 'AGENTS.md')
  if ($Mode -eq 'user') { Upsert-Block (Join-Path $base 'CLAUDE.md') $agents }
  else {
    Upsert-Block (Join-Path $Root 'AGENTS.md') $agents
    Upsert-Block (Join-Path $Root 'CLAUDE.md') '@AGENTS.md'
    if ($script:HandoffMode -ne 'commit') {
      $gi = Join-Path $Root '.gitignore'
      if ((Test-Path $gi) -and ((Get-Content $gi) -contains 'docs/handoff/') -and -not ((Read-Text $gi) -match 'UPE:BEGIN')) {
        Write-Host "  unchanged  $gi (entry already present)"
      } else { Upsert-Block $gi 'docs/handoff/' }
    } else { Write-Host '  handoff docs stay tracked in git' }
  }
  $mf = Join-Path $base '.upe-manifest'
  if ($DryRun) { Write-Host "  would write manifest $mf" } else {
    New-Item -ItemType Directory -Force -Path $base | Out-Null
    $all = @($script:Man); if (Test-Path $mf) { $all += Get-Content $mf }
    [IO.File]::WriteAllText($mf, ((($all | Sort-Object -Unique) -join "`n") + "`n"), $Utf8); Write-Host "  manifest   $mf"
  }
}

$script:HandoffMode = $Handoffs
if ($Project.Count -gt 0 -and -not $script:HandoffMode) {
  if ([Environment]::UserInteractive -and -not $DryRun -and $Host.UI.RawUI) {
    $a = Read-Host 'Commit stage handoff docs (docs/handoff/) to git? [y/N]'
    $script:HandoffMode = if ($a -match '^(y|yes)$') { 'commit' } else { 'ignore' }
  } else { $script:HandoffMode = 'ignore'; Write-Host 'Handoff docs: defaulting to ignore.' }
}
if ($DryRun) { Write-Host 'DRY RUN: nothing will be written.' }
if ($User) { Install-Tree $HOME 'user' }
foreach ($p in $Project) {
  if (-not (Test-Path $p -PathType Container)) { Write-Warning "skipping missing directory: $p"; continue }
  Install-Tree (Resolve-Path $p).Path 'project'
}
Write-Host ""
Write-Host "▶ NEXT"
Write-Host "Context: /clear — install finished"
Write-Host "1. Reload VS Code / restart Claude Code"
Write-Host "2. /do help"
