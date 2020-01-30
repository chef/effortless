
if ($env:CHEF_POLICYFILE -eq $null){
  $policy_name = "base"
}
else{
  $policy_name = $env:CHEF_POLICYFILE
}

$pkg_name="effortless-config-baseline"
$pkg_origin="chef"
$pkg_version="0.1.0"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=("Apache-2.0")
$pkg_description="A Chef Policy for $policy_name"
$pkg_upstream_url="http://chef.io"
$pkg_build_deps=@("core/chef-dk")
$pkg_deps=@("stuartpreston/chef-client", "core/cacerts")
$pkg_scaffolding="chef/scaffolding-chef-infra"
$scaffold_policy_name="$policy_name"
