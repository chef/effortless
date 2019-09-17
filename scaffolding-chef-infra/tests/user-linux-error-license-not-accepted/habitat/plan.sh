#######################################
# User plan for ci testing
# This tests a user interacting with scaffold API
#######################################

pkg_name=user-linux
pkg_origin=ci
pkg_version="1.0.0"
pkg_scaffolding="ci/scaffolding-chef-infra"
pkg_svc_user=("root")
scaffold_policy_name="ci"
# When the user doesn't accept the license, then all builds will
# fail with the error message:
#
# The Chef License must be accepted in your plan
# through the variable 'scaffold_chef_license=<value>'.
#
# More info: https://docs.chef.io/chef_license_accept.html
#
#scaffold_chef_license="accept-no-persist"

# Required Metadata for CI
pkg_description="CI Test Plan for Linux"
pkg_license="Apache-2.0"
pkg_maintainer="The Habitat Maintainers humans@habitat.sh"
pkg_upstream_url="https://chef.sh"
