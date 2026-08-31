#!/usr/bin/env powershell
#
# Integration test: chef/scaffolding-chef-infra + chef/chef-infra-client (Windows)
#
# PURPOSE:
#   The verify pipeline (verify.scaffolding-chef-infra.yml) tests scaffolding
#   built FROM SOURCE on every PR using a fake 'ci' origin. This pipeline tests
#   the PUBLISHED scaffolding package (just promoted to unstable by habitat/build)
#   against the LATEST chef-infra-client from unstable. It catches integration
#   issues before packages are promoted to base-2025 for release.
#
# TRIGGER:
#   Triggered automatically via the buildkite_hab_build_group_published workload
#   subscription in .expeditor/config.yml, immediately after the habitat/build
#   pipeline publishes scaffolding packages to the unstable channel on Builder.
#
# CHANNEL STRATEGY:
#   chef/scaffolding-chef-infra  ->  latest from unstable (just published by habitat/build)
#   chef/chef-infra-client       ->  latest from unstable (pre-installed into studio)
#   core/* and all other deps    ->  base-2025 (stable, prevents flakiness from
#                                    unrelated core package churn in unstable)
#
# HOW IT WORKS (Windows):
#   Unlike Linux, Windows Habitat studios do NOT bind-mount the host package cache.
#   Instead we resolve the latest unstable idents first (without downloading), then
#   start a studio session and install those exact packages from unstable inside the
#   studio before running the build. The build step runs with HAB_BLDR_CHANNEL=base-2025
#   so core/* deps are resolved from base-2025 while the pre-installed exact idents
#   are used for scaffolding and chef-infra-client.
#
# USAGE:
#   Normally invoked by the Buildkite integration-test pipeline. Can also be run
#   locally with HAB_AUTH_TOKEN set:
#     $env:HAB_AUTH_TOKEN = "<token>"
#     .\bin\ci\integration-test.ps1 scaffolding-chef-infra user-windows-chef19
#

#Requires -Version 5

param(
    [string]$Plan,
    [string]$test_plan
)

$env:HAB_ORIGIN = 'ci'
$env:HAB_BLDR_CHANNEL = if ($env:HAB_BLDR_CHANNEL) { $env:HAB_BLDR_CHANNEL } else { "base-2025" }
$UNSTABLE_CHANNEL = "unstable"

# Pass channel and auth token into the Hab studio via HAB_STUDIO_SECRET_ mechanism.
# On Windows, outer-process env vars are not reliably inherited by the studio process.
$env:HAB_STUDIO_SECRET_HAB_BLDR_CHANNEL = $env:HAB_BLDR_CHANNEL
$env:HAB_STUDIO_SECRET_HAB_AUTH_TOKEN = $env:HAB_AUTH_TOKEN

Write-Host "--- :habicat: Installing latest Habitat"
Invoke-Expression "& { $(Invoke-RestMethod https://raw.githubusercontent.com/habitat-sh/habitat/main/components/hab/install.ps1) }"

Write-Host "--- :key: Generating fake origin key"
hab origin key generate $env:HAB_ORIGIN

$project_root = "$(git rev-parse --show-toplevel)"
Set-Location $project_root

Write-Host "--- :habicat: Resolving latest chef/scaffolding-chef-infra from $UNSTABLE_CHANNEL"
# Resolve the latest ident without downloading — we will install inside the studio below.
$scaffoldingInfo = (hab pkg show "chef/scaffolding-chef-infra" --channel $UNSTABLE_CHANNEL 2>&1) -join "" | ConvertFrom-Json
$SCAFFOLDING_IDENT = "$($scaffoldingInfo.origin)/$($scaffoldingInfo.name)/$($scaffoldingInfo.version)/$($scaffoldingInfo.release)"
Write-Host "    Resolved scaffolding: $SCAFFOLDING_IDENT"

Write-Host "--- :habicat: Resolving latest chef/chef-infra-client from $UNSTABLE_CHANNEL"
$clientInfo = (hab pkg show "chef/chef-infra-client" --channel $UNSTABLE_CHANNEL 2>&1) -join "" | ConvertFrom-Json
$CHEF_CLIENT_IDENT = "$($clientInfo.origin)/$($clientInfo.name)/$($clientInfo.version)/$($clientInfo.release)"
Write-Host "    Resolved chef-infra-client: $CHEF_CLIENT_IDENT"

Write-Host "--- :construction: :windows: Building $test_plan"
Write-Host "    scaffolding:        $SCAFFOLDING_IDENT"
Write-Host "    chef-infra-client:  $CHEF_CLIENT_IDENT"
Write-Host "    dep channel:        $($env:HAB_BLDR_CHANNEL)"

# Inject exact idents into the studio so plan.ps1 can pin to them.
$env:HAB_STUDIO_SECRET_INTEGRATION_SCAFFOLDING_IDENT = $SCAFFOLDING_IDENT
$env:HAB_STUDIO_SECRET_INTEGRATION_CHEF_CLIENT_IDENT = $CHEF_CLIENT_IDENT

# Pre-install exact unstable idents inside the studio, then build with base-2025
# channel so core/* deps are resolved from base-2025. All commands run in a single
# studio session so the installed packages are available to the build step.
$buildScript = @"
`$env:HAB_BLDR_CHANNEL = '$($env:HAB_BLDR_CHANNEL)'
Write-Host '--- Pre-installing scaffolding from unstable inside studio'
hab pkg install '$SCAFFOLDING_IDENT' --channel $UNSTABLE_CHANNEL
Write-Host '--- Pre-installing chef-infra-client from unstable inside studio'
hab pkg install '$CHEF_CLIENT_IDENT' --channel $UNSTABLE_CHANNEL
Write-Host '--- Building test plan'
hab pkg build '$Plan/tests/$test_plan' --refresh-channel '$($env:HAB_BLDR_CHANNEL)'
"@

hab studio run $buildScript

. ./results/last_build.ps1
$TEST_PKG_ARTIFACT = $pkg_artifact
$TEST_PKG_IDENT = $pkg_ident

Write-Host "--- :mag: Testing $TEST_PKG_IDENT"

if (!(Test-Path "$Plan\tests\$test_plan\tests\test.ps1")) {
    Write-Host ":warning: :windows: $test_plan has no Windows tests to run."
    exit 1
}

powershell -File ".\$Plan\tests\$test_plan\tests\test.ps1" -PackageIdentifier $TEST_PKG_IDENT -PackageSource ./results/$TEST_PKG_ARTIFACT
