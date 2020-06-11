$pkg_name="scaffolding-chef-infra"
$pkg_description="Scaffolding for Chef Policyfiles"
$pkg_origin="chef"
$pkg_version="$(Get-Content $PLAN_CONTEXT\..\VERSION)"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=("Apache-2.0")
$pkg_upstream_url="https://www.chef.sh"
$pkg_deps=@(
    "core/git",
    "chef/ruby-plus-devkit"
)
$pkg_bin_dirs=@("vendor/bin")

function Invoke-Setupenvironment {
  Push-RuntimeEnv -IsPath GEM_PATH "$pkg_prefix/vendor"
  Push-BuildtimeEnv -IsPath GEM_PATH "$pkg_prefix/vendor"
}

function Invoke-Build {
  $env:GEM_HOME = "$HAB_CACHE_SRC_PATH/$pkg_dirname/vendor"
  # WE NEED TO REMOVE THIS WHEN FFI IS FIXED OR CHEF-CLI PINS FFI
  gem install chef-cli --no-document
  if (-not $?) { throw "Unable to install chef-cli gem." }
}

function Invoke-Install {
  New-Item -ItemType directory -Path "$pkg_prefix/lib/windows"
  Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/*" -Destination $pkg_prefix -Recurse -Exclude @("gem_make.out", "mkmf.log", "Makefile") -Force
  Copy-Item -Path "$PLAN_CONTEXT/lib/windows/*" -Destination "$pkg_prefix/lib" -Recurse
}
