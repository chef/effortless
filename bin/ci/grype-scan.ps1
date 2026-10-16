#!/usr/bin/env powershell
#
# Grype scan of the PUBLISHED chef/scaffolding-chef-infra package (Windows)
#
# PURPOSE:
#   After the habitat/build pipeline publishes packages, install the published
#   package on top of a CLEAN Habitat install and scan the whole hab tree
#   (hab itself, the package, and all transitive dependencies) with grype.
#   Reports are uploaded as Buildkite artifacts by the pipeline step.
#
# CLEAN INSTALL:
#   Habitat honours the FS_ROOT environment variable, so the install goes into
#   a fresh temporary root rather than C:\hab. chef/hab is installed into the
#   same root first so the scanned tree matches a fresh `hab` bootstrap.
#
# OUTPUT:
#   grype-reports\<os>-<arch>-<package-identifier>.txt   (grype table)
#   grype-reports\<os>-<arch>-<package-identifier>.json  (grype json)
#   e.g. windows-amd64-chef-scaffolding-chef-infra-0-26-3-20261016115849.txt
#
# USAGE:
#   $env:HAB_AUTH_TOKEN = "<token>"
#   .\bin\ci\grype-scan.ps1 scaffolding-chef-infra
#   Optional env: SCAN_CHANNEL (default unstable), GRYPE_VERSION, REPORT_DIR

#Requires -Version 5

param(
    [string]$Package
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Native commands do not raise terminating errors on failure in PowerShell.
function Assert-Success {
    param([string]$Message)
    if ($LASTEXITCODE -ne 0) {
        throw "FAILED: $Message (exit code $LASTEXITCODE)"
    }
}

$Package = Split-Path -Leaf $Package
$ScanChannel = if ($env:SCAN_CHANNEL) { $env:SCAN_CHANNEL } else { "unstable" }
$GrypeVersion = if ($env:GRYPE_VERSION) { $env:GRYPE_VERSION } else { "0.120.1" }
$HabVersion = if ($env:HAB_VERSION) { $env:HAB_VERSION } else { "2.1.23" }
$ReportDir = if ($env:REPORT_DIR) { $env:REPORT_DIR } else { "grype-reports" }
$Origin = "chef"
$Platform = "windows-amd64"

$env:HAB_LICENSE = "accept-no-persist"
$env:HAB_NONINTERACTIVE = "true"

# Windows Buildkite agents run with `shell=powershell`, so the bash
# .buildkite/hooks/pre-command hook never fires. HAB_AUTH_TOKEN is injected by
# Expeditor from Vault (see the `secrets` block in the pipeline definition).

$workDir = Join-Path ([IO.Path]::GetTempPath()) ("grype-scan-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $workDir -Force | Out-Null

try {
    Write-Host "--- :habicat: Installing Habitat $HabVersion"
    Invoke-Expression "& { $(Invoke-RestMethod https://raw.githubusercontent.com/habitat-sh/habitat/main/components/hab/install.ps1) } -Version $HabVersion"

    Write-Host "--- :mag: Installing grype $GrypeVersion ($Platform)"
    $grypeZip = "grype_${GrypeVersion}_windows_amd64.zip"
    $grypeUrl = "https://github.com/anchore/grype/releases/download/v$GrypeVersion"
    Invoke-WebRequest -UseBasicParsing -Uri "$grypeUrl/$grypeZip" -OutFile (Join-Path $workDir $grypeZip)
    Invoke-WebRequest -UseBasicParsing -Uri "$grypeUrl/grype_${GrypeVersion}_checksums.txt" -OutFile (Join-Path $workDir "checksums.txt")
    $expected = ((Get-Content (Join-Path $workDir "checksums.txt")) | Where-Object { $_ -match " $([regex]::Escape($grypeZip))$" }) -replace '\s.*$', ''
    $actual = (Get-FileHash (Join-Path $workDir $grypeZip) -Algorithm SHA256).Hash
    if (-not $expected -or $expected.ToLower() -ne $actual.ToLower()) {
        throw "FAILED: checksum mismatch for $grypeZip (expected '$expected', got '$actual')"
    }
    $grypeDir = Join-Path $workDir "grype-bin"
    Expand-Archive -Path (Join-Path $workDir $grypeZip) -DestinationPath $grypeDir -Force
    $grype = Join-Path $grypeDir "grype.exe"
    & $grype version
    Assert-Success "grype version"

    Write-Host "--- :habicat: Creating clean Habitat root"
    $root = Join-Path $workDir "root"
    New-Item -ItemType Directory -Path $root -Force | Out-Null
    $env:FS_ROOT = $root
    hab pkg install chef/hab --channel stable
    Assert-Success "hab pkg install chef/hab"

    # The buildkite_hab_build_group_published workload exposes the exact ident
    # published for each package/target, e.g.
    # EXPEDITOR_PKG_IDENTS_SCAFFOLDINGCHEFINFRAX86_64WINDOWS. Scan exactly that
    # release; fall back to the latest in $ScanChannel (manual/local runs).
    $identVar = "EXPEDITOR_PKG_IDENTS_" + (($Package + "x86_64-windows") -replace '-', '').ToUpper()
    $installSpec = [Environment]::GetEnvironmentVariable($identVar)
    $installSpec = if ($installSpec) { ($installSpec.Trim() -split '\s+')[0] } else { "$Origin/$Package" }

    Write-Host "--- :habicat: Installing $installSpec from $ScanChannel"
    hab pkg install $installSpec --channel $ScanChannel
    Assert-Success "hab pkg install $installSpec --channel $ScanChannel"
    $pkgPath = (hab pkg path $installSpec)
    Assert-Success "hab pkg path $installSpec"
    $ident = (($pkgPath -split '[\\/]pkgs[\\/]', 2)[1]) -replace '\\', '/'
    Write-Host "    Resolved: $ident"

    $identKebab = ($ident -replace '[/_.]', '-').ToLower()
    New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
    $reportBase = Join-Path $ReportDir "$Platform-$identKebab"

    Write-Host "--- :mag: Scanning $root\hab"
    & $grype "dir:$root\hab" -o "table=$reportBase.txt" -o "json=$reportBase.json"
    Assert-Success "grype scan"

    Write-Host "--- :page_facing_up: Reports"
    Get-ChildItem $ReportDir | Format-Table Name, Length
    Get-Content "$reportBase.txt" -TotalCount 20
}
finally {
    Remove-Item Env:\FS_ROOT -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force $workDir -ErrorAction SilentlyContinue
}
