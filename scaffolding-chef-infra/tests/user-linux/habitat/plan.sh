#######################################
# User plan for ci testing
# This tests a user interacting with the API provided by the scaffolding
#######################################

pkg_name=user-linux
pkg_origin=ci
pkg_version="1.0.0"
pkg_scaffolding="chef/scaffolding-chef-infra"
pkg_svc_user=("root")
scaffold_policy_name="ci"
scaffold_chef_client="chef/chef-client/14.13.11"
scaffold_cacerts="ci/cacerts"
