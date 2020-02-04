#!/usr/bin/env powershell

#Requires -Version 5

param(
    # The name of the plan that is to be built.
    [string]$Plan,
    [string]$test_plan
)

$env:HAB_ORIGIN = 'ci'

Install-Habitat

Write-Host "--- :key: Generating fake origin key"
hab origin key generate $env:HAB_ORIGIN

Write-Host "--- :construction: Starting build for $Plan"

$project_root = "$(git rev-parse --show-toplevel)"

Set-Location $project_root

Write-Host "--- :construction: :windows: Building $Plan"
$env:DO_CHECK=$true; hab pkg build $Plan

Write-Host "--- :construction: :windows: Building user plan for $Plan"

hab studio build "./$Plan/tests/$test_plan" -R
. ./results/last_build.ps1
$TEST_PKG_ARTIFACT = $pkg_artifact
$TEST_PKG_IDENT = $pkg_ident

Write-Host "--- :mag: Testing $TEST_PKG_IDENT"

if (!(Test-path "$Plan\tests\$test_plan\tests\test.ps1")){
    Write-host ":warning: :windows: $Plan has no Windows tests to run."
    exit 1
}

powershell -File ".\$Plan\tests\$test_plan\tests\test.ps1" -PackageIdentifier $TEST_PKG_IDENT -PackageSource ./results/$TEST_PKG_ARTIFACT
