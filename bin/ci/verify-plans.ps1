#!/usr/bin/env powershell

#Requires -Version 5

param(
    # The name of the plan that is to be built.
    [string]$Plan,
    [string]$test_plan
)

$env:HAB_ORIGIN = 'ci'
$env:HAB_BLDR_CHANNEL = if ($env:HAB_BLDR_CHANNEL) { $env:HAB_BLDR_CHANNEL } else { "base-2025" }
# Pass channel and auth token into the Hab studio via HAB_STUDIO_SECRET_ mechanism.
# On Windows, HAB_BLDR_CHANNEL set in the outer process is not reliably inherited
# by the studio process. HAB_STUDIO_SECRET_* vars are the correct way to inject
# env vars into the studio on Windows.
$env:HAB_STUDIO_SECRET_HAB_BLDR_CHANNEL = $env:HAB_BLDR_CHANNEL
$env:HAB_STUDIO_SECRET_HAB_AUTH_TOKEN = $env:HAB_AUTH_TOKEN

Write-Host "--- :habicat: Installing latest Habitat"
Invoke-Expression "& { $(Invoke-RestMethod https://raw.githubusercontent.com/habitat-sh/habitat/main/components/hab/install.ps1) }"

Write-Host "--- :key: Generating fake origin key"
hab origin key generate $env:HAB_ORIGIN

Write-Host "--- :construction: Starting build for $Plan"

$project_root = "$(git rev-parse --show-toplevel)"

Set-Location $project_root

Write-Host "--- :construction: :windows: Building $Plan"
$env:DO_CHECK = $true
hab pkg build $Plan --refresh-channel $env:HAB_BLDR_CHANNEL

Write-Host "--- :construction: :windows: Building user plan for $Plan"

. ./results/last_build.ps1
$SCAFFOLDING_PKG_ARTIFACT = $pkg_artifact

hab pkg install "results\$SCAFFOLDING_PKG_ARTIFACT"
hab pkg build "./$Plan/tests/$test_plan" --refresh-channel $env:HAB_BLDR_CHANNEL

. ./results/last_build.ps1
$TEST_PKG_ARTIFACT = $pkg_artifact
$TEST_PKG_IDENT = $pkg_ident

Write-Host "--- :mag: Testing $TEST_PKG_IDENT"

if (!(Test-path "$Plan\tests\$test_plan\tests\test.ps1")){
    Write-host ":warning: :windows: $Plan has no Windows tests to run."
    exit 1
}

powershell -File ".\$Plan\tests\$test_plan\tests\test.ps1" -PackageIdentifier $TEST_PKG_IDENT -PackageSource ./results/$TEST_PKG_ARTIFACT
