#######################################
# User plan for ci testing
# This tests a user interacting with the API provided by the scaffolding
#######################################

$pkg_name="user-windows-default"
$pkg_origin="ci"
$pkg_version="1.0.0"
$pkg_scaffolding="ci/scaffolding-chef-infra"
$scaffold_policy_name="ci"
$scaffold_cacerts="core/cacerts"
$scaffold_chef_client="stuartpreston/chef-client-detox"

# Required Metadata for CI
$pkg_description="CI Test Plan for Linux"
$pkg_license="Apache-2.0"
$pkg_maintainer="The Habitat Maintainers humans@habitat.sh"
$pkg_upstream_url="https://chef.sh"
