param(
    [Parameter()]
    [string]$PackageIdentifier = $(throw "Usage: test.ps1 [test_pkg_ident] e.g. test.ps1 ci/user-windows-chef19/1.0.0/20260827000000")
)

Describe "Chef 19 integration: scaffolding-chef-infra with chef-infra-client from unstable" {
    AfterAll {
        hab svc unload $PackageIdentifier
        Remove-Item "c:/temp" -Recurse -ErrorAction SilentlyContinue
    }

    Context "Integration: Chef 19 successfully executes the run from the run hook" {
        It "File created by the cookbook should exist" {
            Test-Path -LiteralPath "c:/temp/test-chef19" | Should Be $true
        }

        It "File created by the cookbook should have 'Hello from Chef 19!' in it" {
            $TestFileContent = Get-Content "c:/temp/test-chef19"
            $TestFileContent | Should be "Hello from Chef 19!"
        }
    }

    Context "Integration: chef-infra-client is version 19.x" {
        It "Installed chef-infra-client should be Chef 19" {
            $client_path = hab pkg path chef/chef-infra-client
            $client_path | Should Match '\\chef-infra-client\\19\.'
        }
    }

    Context "Build: client-config.rb pkg_svc_data_path renders" {
        It "client-config.rb renders" {
            $config = Get-Content "C:\hab\svc\user-windows-chef19\config\client-config.rb" | Select-String -Pattern 'cache_path'
            $config = $config -split ' '
            $config[1] | Should be "'C:\hab\svc\user-windows-chef19\data/cache'"
        }
    }

    Context "API: scaffold_cacerts matches run hook core/cacerts" {
        It "SSL_CERT_FILE should be core/cacerts" {
            $cert_file = Get-Content "C:\hab\svc\user-windows-chef19\hooks\run" | Select-String -Pattern '\$env:SSL_CERT_FILE'
            $cert_file = $cert_file -split '='
            $cert_file = $cert_file[1].split('\')
            $cert_pkg = $cert_file[3] + '/' + $cert_file[4]
            $cert_pkg | Should be "core/cacerts"
        }
        It "SSL_CERT_DIR should be core/cacerts" {
            $cert_dir = Get-Content "C:\hab\svc\user-windows-chef19\hooks\run" | Select-String -Pattern '\$env:SSL_CERT_DIR'
            $cert_dir = $cert_dir -split '='
            $cert_dir = $cert_dir[1].split('\')
            $cert_pkg_dir = $cert_dir[3] + '/' + $cert_dir[4]
            $cert_pkg_dir | Should be "core/cacerts"
        }
    }

    Context "API: scaffold_chef_client matches run hook chef/chef-infra-client" {
        It "The chef-client should be chef/chef-infra-client" {
            $chef_client_pkg = Get-Content "C:\hab\svc\user-windows-chef19\hooks\run" | Select-String -Pattern '\w+/bin/chef-client.bat -z'
            $chef_client_pkg = $chef_client_pkg -split ' '
            $chef_client_pkg = $chef_client_pkg[2].split('\')
            $chef_client_pkg = $chef_client_pkg[3] + '/' + $chef_client_pkg[4]
            $chef_client_pkg | Should be "chef/chef-infra-client"
        }
    }
}
