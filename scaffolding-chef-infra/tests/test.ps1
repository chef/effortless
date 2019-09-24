param (
    [Parameter()]
    [string]$PackageIdentifier = $(throw "Usage: test.ps1 [test_pkg_ident] e.g. test.ps1 ci/user-windows/1.0.0/20190812103929"),
    [string]$PackageSource = $(throw "Usage: test.ps1 [test_pkg_source] e.g. test.ps1 ./results/ci-user-windows-1.0.0-20190812103929-x86_64-windows.hart")
)

if (-Not (Get-Module -ListAvailable -Name Pester)){
    hab pkg install core/pester
    Import-Module "$(hab pkg path core/pester)\module\pester.psd1"
}

# Install the package
hab pkg install $PackageSource

Get-Process hab-sup -ErrorAction SilentlyContinue | Stop-Process
Get-Process hab-launch -ErrorAction SilentlyContinue | Stop-Process

$SUP_WAIT_SECONDS = 20

Start-Sleep $SUP_WAIT_SECONDS
$hab_supervisor = Start-Process hab -ArgumentList sup,run -NoNewWindow -PassThru
Write-Output "Waiting $SUP_WAIT_SECONDS seconds for hab sup to start..."
Start-Sleep $SUP_WAIT_SECONDS

$LOAD_WAIT_SECONDS = 60

Write-Output "Waiting $LOAD_WAIT_SECONDS seconds for $PackageIdentifier to start..."

$sup_secret = (Get-Content "c:/hab/sup/default/CTL_SECRET")
Write-Output "The hab ctl file is: $sup_secret"

Write-Output "$env:HAB_CTL_SECRET"

hab svc load $PackageIdentifier
Start-Sleep $LOAD_WAIT_SECONDS


$__dir=(Get-Item $PSScriptRoot)
$test_result = Invoke-Pester -Strict -PassThru -Script @{
    Path = "$__dir/test.pester.ps1";
    Parameters = @{PackageIdentifier=$PackageIdentifier}
}
Exit $test_result.FailedCount
