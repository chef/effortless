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
#   chef/chef-infra-client       ->  latest from unstable (pre-installed before build)
#   core/* and all other deps    ->  base-2025 (stable, prevents flakiness from
#                                    unrelated core package churn in unstable)
#
# HOW IT WORKS (Windows):
#   Unlike Linux, Windows Habitat studios share the host package cache. We pre-install
#   exact idents from unstable on the host before the build. The build runs with
#   --refresh-channel base-2025 so core/* deps are resolved from base-2025, while
#   the pre-installed scaffolding and chef-infra-client are found in the shared cache.
#   Exact idents are injected via HAB_STUDIO_SECRET_* so plan.ps1 can pin to them.
#
# USAGE:
#   Normally invoked by the Buildkite integration-test pipeline. Can also be run
#   locally with HAB_AUTH_TOKEN set:
#     $env:HAB_AUTH_TOKEN = "<token>"
#     .\bin\ci\integration-test.ps1 scaffolding-chef-infra user-windows-integration
#

#Requires -Version 5

param(
    [string]$Plan,
    [string]$test_plan
)

$ErrorActionPreference = 'Stop'

$env:HAB_ORIGIN = 'ci'
$env:HAB_BLDR_CHANNEL = if ($env:HAB_BLDR_CHANNEL) { $env:HAB_BLDR_CHANNEL } else { "base-2025" }
$UNSTABLE_CHANNEL = "unstable"

if ($env:HAB_AUTH_TOKEN) {
  Write-Host "    HAB_AUTH_TOKEN is set"
} else {
  Write-Host "--- :key: Fetching HAB_AUTH_TOKEN from Vault"
  $env:HAB_AUTH_TOKEN = (vault kv get -field auth_token account/static/habitat/chef-ci 2>$null)
  if ($env:HAB_AUTH_TOKEN) {
    Write-Host "    HAB_AUTH_TOKEN retrieved from Vault successfully"
  } else {
    Write-Host "    WARNING: HAB_AUTH_TOKEN is still empty"
  }
}

# Pass token and channel into the Hab studio via HAB_STUDIO_SECRET_ mechanism.
$env:HAB_STUDIO_SECRET_HAB_BLDR_CHANNEL = $env:HAB_BLDR_CHANNEL
$env:HAB_STUDIO_SECRET_HAB_AUTH_TOKEN = $env:HAB_AUTH_TOKEN

Write-Host "--- :habicat: Installing latest Habitat"
Invoke-Expression "& { $(Invoke-RestMethod https://raw.githubusercontent.com/habitat-sh/habitat/main/components/hab/install.ps1) }"

Write-Host "--- :key: Generating fake origin key"
hab origin key generate $env:HAB_ORIGIN

$project_root = "$(git rev-parse --show-toplevel)"
Set-Location $project_root

Write-Host "--- :habicat: Installing chef/scaffolding-chef-infra from $UNSTABLE_CHANNEL"
# Install from unstable so the package lands in the host's package cache, which is
# shared with the Windows studio. After install, capture the exact 4-part ident
# so the test plan pins to this specific version rather than re-resolving.
hab pkg install chef/scaffolding-chef-infra --channel $UNSTABLE_CHANNEL
$scaffoldingPath = hab pkg path chef/scaffolding-chef-infra
$SCAFFOLDING_IDENT = $scaffoldingPath -replace "^C:\\hab\\pkgs\\", "" -replace "\\", "/"
Write-Host "    Resolved scaffolding: $SCAFFOLDING_IDENT"

Write-Host "--- :habicat: Installing chef/chef-infra-client from $UNSTABLE_CHANNEL"
hab pkg install chef/chef-infra-client --channel $UNSTABLE_CHANNEL
$clientPath = hab pkg path chef/chef-infra-client
$CHEF_CLIENT_IDENT = $clientPath -replace "^C:\\hab\\pkgs\\", "" -replace "\\", "/"
Write-Host "    Resolved chef-infra-client: $CHEF_CLIENT_IDENT"

# Inject exact idents into the studio so plan.ps1 can pin to them.
$env:HAB_STUDIO_SECRET_INTEGRATION_SCAFFOLDING_IDENT = $SCAFFOLDING_IDENT
$env:HAB_STUDIO_SECRET_INTEGRATION_CHEF_CLIENT_IDENT = $CHEF_CLIENT_IDENT

Write-Host "--- :construction: :windows: Building $test_plan"
Write-Host "    scaffolding:        $SCAFFOLDING_IDENT"
Write-Host "    chef-infra-client:  $CHEF_CLIENT_IDENT"
Write-Host "    dep channel:        $($env:HAB_BLDR_CHANNEL)"

# Build the test user package. The scaffolding and chef-infra-client are already
# in the host package cache (shared with the Windows studio), so Habitat uses
# those cached idents. All core/* deps are resolved from base-2025.
hab pkg build "$Plan/tests/$test_plan" --refresh-channel $env:HAB_BLDR_CHANNEL

. .\results\last_build.ps1
$TEST_PKG_ARTIFACT = $pkg_artifact
$TEST_PKG_IDENT = $pkg_ident

Write-Host "--- :mag: Testing $TEST_PKG_IDENT"

if (!(Test-Path "$Plan\tests\$test_plan\tests\test.ps1")) {
    Write-Host ":warning: :windows: $test_plan has no Windows tests to run."
    exit 1
}

powershell -File ".\$Plan\tests\$test_plan\tests\test.ps1" -PackageIdentifier $TEST_PKG_IDENT -PackageSource ".\results\$TEST_PKG_ARTIFACT"
