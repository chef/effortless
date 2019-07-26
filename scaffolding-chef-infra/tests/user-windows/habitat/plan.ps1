#######################################
# User plan for ci testing
# This tests a user interacting with the API provided by the scaffolding
#######################################

$pkg_name="user-windows
$pkg_origin="ci"
$pkg_version="0.1.0"
$pkg_upstream_url="http://chef.io"
$pkg_build_deps=@("core/chef-dk")
$pkg_deps=@(
  "core/cacerts"
  "stuartpreston/chef-client"
)
$pkg_scaffolding="ci/scaffolding-chef-infra"
$scaffold_policy_name="ci"
$scaffold_cacerts="core/cacerts"
scaffold_chef_client="chef/chef-client/14.13.11"
