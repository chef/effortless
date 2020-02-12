$pkg_name="scaffolding-chef-inspec"
$pkg_description="Scaffolding for InSpec Profile"
$pkg_origin="chef"
$pkg_version="$(Get-Content $PLAN_CONTEXT\..\VERSION)"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=("Apache-2.0")
$pkg_upstream_url="https://www.chef.sh"

function Invoke-Install {
    New-Item -ItemType Directory -Path "$pkg_prefix/lib"
    Copy-Item -Path "$PLAN_CONTEXT/lib/scaffolding.ps1" -Destination "$pkg_prefix/lib/scaffolding.ps1"
}
