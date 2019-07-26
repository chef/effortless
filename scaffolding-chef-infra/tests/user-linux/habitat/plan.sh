#######################################
# User plan for ci testing
# This tests a user interacting with the API provided by the scaffolding
#######################################

pkg_name=user-linux
pkg_origin=chef
pkg_version="1.0.0"
pkg_upstream_url="http://chef.io"
pkg_scaffolding="ci/scaffolding-chef-infra"
pkg_svc_user=("root")
scaffold_policy_name="ci"
scaffold_chef_client="chef/chef-client/14.13.11"
