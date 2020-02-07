param(
    [Parameter()]
    [string]$PackageIdentifier = $(throw "Usage: test.ps1 [test_pkg_ident] e.g. test.ps1 ci/user-windows-default/1.0.0/20190812103929")
)

Describe "Inspec client run doesn't fail" {
    AfterAll {
        hab svc unload $PackageIdentifier
    }

    Context "API: scaffold_cacerts matches run hook core/cacerts" {
        It "SSL_CERT_FILE should be core/cacerts" {
            $cert_file = Get-Content "C:\hab\svc\user-windows-waiver\hooks\run" | Select-String -Pattern '\$env:SSL_CERT_FILE'
            $cert_file = $cert_file -split '='
            $cert_file = $cert_file[1].split('\')
            $cert_pkg = $cert_file[3] + '/' + $cert_file[4]

            $cert_pkg | Should be "core/cacerts"
        }
    }

    Context "Waiver: the yaml renders" {
        It "The waiver.yml has a foo_2 control" {
            $yaml = Get-Content "C:\hab\svc\user-windows-waiver\config\waiver.yaml"
            $yaml[1] | Should be "foo_2:"
        }
    }
}
