#######################################
# Integration test user plan for Chef 19 (Linux)
#
# Tests the published chef/scaffolding-chef-infra against the latest
# chef/chef-infra-client from the unstable channel.
#
# The scaffolding ident and chef-infra-client ident are injected by
# bin/ci/integration-test.sh via HAB_STUDIO_SECRET_* so that exact
# published idents are tested rather than resolving from Builder.
# When run locally without those env vars, falls back to unversioned
# package names and resolves from HAB_BLDR_CHANNEL as usual.
#######################################

pkg_name=user-linux-integration
pkg_origin=ci
pkg_version="1.0.0"
pkg_scaffolding="${INTEGRATION_SCAFFOLDING_IDENT:-chef/scaffolding-chef-infra}"
pkg_svc_user=("root")
scaffold_policy_name="ci"
scaffold_chef_client="${INTEGRATION_CHEF_CLIENT_IDENT:-chef/chef-infra-client}"

pkg_description="Integration test plan for Chef 19 Effortless scaffolding"
pkg_license="Apache-2.0"
pkg_maintainer="The Habitat Maintainers humans@habitat.sh"
pkg_upstream_url="https://chef.sh"
