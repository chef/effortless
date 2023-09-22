param(
    [Parameter()]
    [string]$PackageIdentifier = $(throw "Usage: test.ps1 [test_pkg_ident] e.g. test.ps1 ci/user-windows-api/1.0.0/20190812103929")
)

Describe "Chef client run doesn't fail" {
    AfterAll {
        hab svc unload $PackageIdentifier
        Remove-Item "c:/temp" -Recurse -ErrorAction SilentlyContinue
    }

    Context "Build: Chef successfully executes the run from the run hook " {
        It "File created by the cookbook should exist" {
            Test-Path -LiteralPath "c:/temp/test-default" | Should Be $true
        }

        It "File created by the cookbook should have 'Hello World!' in it" {
            $TestFileContent = Get-Content "c:/temp/test-default"

            $TestFileContent | Should be "Hello World!"
        }
    }

    Context "Build: client-config.rb pkg_svc_data_path renders " {
        It "client-config.rb renders" {
            $config = Get-Content "C:\hab\svc\user-windows-api\config\client-config.rb" | Select-String -Pattern 'cache_path'
            $config = $config -split ' '
            $config[1] | Should be "'C:\hab\svc\user-windows-api\data/cache'"
        }
    }

    Context "API: scaffold_cacerts matches run hook core/cacerts" {
        It "SSL_CERT_FILE should be core/cacerts" {
            $cert_file = Get-Content "C:\hab\svc\user-windows-api\hooks\run" | Select-String -Pattern '\$env:SSL_CERT_FILE'
            $cert_file = $cert_file -split '='
            $cert_file = $cert_file[1].split('\')
            $cert_pkg = $cert_file[3] + '/' + $cert_file[4]

            $cert_pkg | Should be "core/cacerts"
        }
        It "SSL_CERT_DIR should be core/cacerts" {
            $cert_dir = Get-Content "C:\hab\svc\user-windows-api\hooks\run" | Select-String -Pattern '\$env:SSL_CERT_DIR'
            $cert_dir = $cert_dir -split '='
            $cert_dir = $cert_dir[1].split('\')
            $cert_pkg_dir = $cert_dir[3] + '/' + $cert_dir[4]

            $cert_pkg_dir | Should be "core/cacerts"
        }
    }

    Context "API: scaffold_chef_client matches run hook chef/chef-infra-client" {
        It "The chef-client should be the official chef-infra-client" {
            $chef_client_pkg = Get-Content "C:\hab\svc\user-windows-api\hooks\run" | Select-String -Pattern '\w+/bin/chef-client.bat -z'
            $chef_client_pkg = $chef_client_pkg -split ' '
            $chef_client_pkg = $chef_client_pkg[2].split('\')
            $chef_client_pkg = $chef_client_pkg[3] + '/' + $chef_client_pkg[4]

            $chef_client_pkg | Should be "chef/chef-infra-client"
        }
    }
}
