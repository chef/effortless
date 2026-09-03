param (
    [Parameter()]
    [string]$PackageIdentifier = $(throw "Usage: test.ps1 [test_pkg_ident] e.g. test.ps1 ci/user-windows-chef19/1.0.0/20260827000000"),
    [string]$PackageSource = $(throw "Usage: test.ps1 [test_pkg_source] e.g. test.ps1 ./results/ci-user-windows-chef19-1.0.0-20260827000000-x86_64-windows.hart")
)

if (-Not (Get-Module -ListAvailable -Name Pester)){
    hab pkg install core/pester
    Import-Module "$(hab pkg path core/pester)\module\pester.psd1"
}

hab pkg install $PackageSource

Get-Process hab-launch -ErrorAction SilentlyContinue | Stop-Process

$SUP_WAIT_SECONDS = 60

Start-Sleep $SUP_WAIT_SECONDS
$hab_supervisor = Start-Process hab -ArgumentList sup,run -NoNewWindow -PassThru
Write-Output "Waiting $SUP_WAIT_SECONDS seconds for hab sup to start..."
Start-Sleep $SUP_WAIT_SECONDS

$LOAD_WAIT_SECONDS = 60

Write-Output "Waiting $LOAD_WAIT_SECONDS seconds for $PackageIdentifier to start...."
hab svc load $PackageIdentifier
Start-Sleep $LOAD_WAIT_SECONDS

$__dir=(Get-Item $PSScriptRoot)
$test_result = Invoke-Pester -Strict -PassThru -Script @{
    Path = "$__dir/test.pester.ps1";
    Parameters = @{PackageIdentifier=$PackageIdentifier}
}

# hab svc unload (called in test.pester.ps1's AfterAll) only unloads the
# service - it does not stop the supervisor itself. Start-Process launched
# hab-sup as a detached background process above, so without explicitly
# stopping it here, hab-sup/hab-launch keeps running after this script
# "finishes", and the Buildkite Windows agent waits for the whole process
# tree to exit - hanging the step until it's eventually killed by the
# step timeout.
Write-Output "--- :habicat: Stopping the supervisor"
hab sup term 2>$null | Out-Null
Start-Sleep 5
Get-Process hab-launch -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process hab-sup -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Exit $test_result.FailedCount
