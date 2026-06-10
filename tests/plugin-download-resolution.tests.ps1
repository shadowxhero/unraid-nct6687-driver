$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$pluginPath = Join-Path $repoRoot 'nct6687-driver.plg'
$plugin = Get-Content -Raw -Path $pluginPath

$failures = [System.Collections.Generic.List[string]]::new()

function Assert-PluginContains {
  param(
    [string]$Pattern,
    [string]$Message
  )

  if ($plugin -notmatch $Pattern) {
    $failures.Add($Message)
  }
}

Assert-PluginContains 'releases/expanded_assets/\$\{KERNEL_V\}' `
  'Plugin should fall back to the GitHub expanded_assets page when the GitHub API does not return a package name.'

Assert-PluginContains 'if \[ -z "\$LAT_PACKAGE" \]' `
  'Plugin should abort with a clear error when the package name cannot be resolved.'

Assert-PluginContains "Can't find NCT6687d Drivers" `
  'Plugin should print a specific error when no release asset can be found.'

if ($failures.Count -gt 0) {
  throw ($failures -join [Environment]::NewLine)
}

Write-Host 'plugin download resolution checks passed'
