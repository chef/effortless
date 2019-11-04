$pkg_name="scaffolding-chef-infra"
$pkg_description="Scaffolding for Chef Policyfiles"
$pkg_origin="chef"
$pkg_version="$(Get-Content $PLAN_CONTEXT\..\VERSION)"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=("Apache-2.0")
$pkg_upstream_url="https://www.chef.sh"
$pkg_deps=@(
    "core/git"
)

function Invoke-Install {
  New-Item -ItemType directory -Path "$pkg_prefix/lib/windows"
  Copy-Item -Path "$PLAN_CONTEXT/lib/windows/*" -Destination "$pkg_prefix/lib" -Recurse
}
