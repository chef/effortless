param(
    [Parameter()]
    [string]$PackageIdentifier = $(throw "Usage: test.ps1 [test_pkg_ident] e.g. test.ps1 ci/user-windows-default/1.0.0/20190812103929")
)

Describe "Inspec client run doesn't fail" {
    AfterAll {
        hab svc unload $PackageIdentifier
        Remove-Item "c:/temp" -Recurse -ErrorAction SilentlyContinue
    }

    Context "API: scaffold_cacerts matches run hook core/cacerts" {
        It "SSL_CERT_FILE should be core/cacerts" {
            $cert_file = Get-Content "C:\hab\svc\user-windows-default\hooks\run" | Select-String -Pattern '\$env:SSL_CERT_FILE'
            $cert_file = $cert_file -split '='
            $cert_file = $cert_file[1].split('\')
            $cert_pkg = $cert_file[3] + '/' + $cert_file[4]

            $cert_pkg | Should be "core/cacerts"
        }
        It "SSL_CERT_DIR should be core/cacerts" {
            $cert_dir = Get-Content "C:\hab\svc\user-windows-default\hooks\run" | Select-String -Pattern '\$env:SSL_CERT_DIR'
            $cert_dir = $cert_dir -split '='
            $cert_dir = $cert_dir[1].split('\')
            $cert_pkg_dir = $cert_dir[3] + '/' + $cert_dir[4]

            $cert_pkg_dir | Should be "core/cacerts"
        }
    }

    Context "API: scaffold_chef_client matches run hook chef/inspec" {
        It "The chef-client should be Stuart Preston's chef-client" {
            $chef_client_pkg = Get-Content "C:\hab\svc\user-windows-default\hooks\run" | Select-String -Pattern '\env:PATH = "'
            $chef_client_pkg = $chef_client_pkg -split ' '
            $chef_client_pkg = $chef_client_pkg[2].split('\')
            $chef_client_pkg = $chef_client_pkg[3] + '/' + $chef_client_pkg[4]

            $chef_client_pkg | Should be "chef/inspec"
        }
    }
}
