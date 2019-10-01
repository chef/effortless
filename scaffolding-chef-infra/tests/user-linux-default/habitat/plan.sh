#######################################
# User plan for ci testing
# This tests a user interacting with scaffold API
#######################################

pkg_name=user-linux-default
pkg_origin=ci
pkg_version="1.0.0"
pkg_scaffolding="ci/scaffolding-chef-infra"
pkg_svc_user=("root")
scaffold_policy_name="ci"

# Required Metadata for CI
pkg_description="CI Test Plan for Linux"
pkg_license="Apache-2.0"
pkg_maintainer="The Habitat Maintainers humans@habitat.sh"
pkg_upstream_url="https://chef.sh"
