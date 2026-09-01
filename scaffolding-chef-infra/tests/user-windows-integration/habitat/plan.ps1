#######################################
# Integration test user plan for Chef 19 (Windows)
#
# Tests the published chef/scaffolding-chef-infra against the latest
# chef/chef-infra-client from the unstable channel.
#
# The scaffolding ident and chef-infra-client ident are injected by
# bin/ci/integration-test.ps1 via HAB_STUDIO_SECRET_* so that exact
# published idents are tested rather than resolving from Builder.
# When run locally without those env vars, falls back to unversioned
# package names and resolves from HAB_BLDR_CHANNEL as usual.
#######################################

$pkg_name="user-windows-integration"
$pkg_origin="ci"
$pkg_version="1.0.0"
$pkg_scaffolding=if($env:INTEGRATION_SCAFFOLDING_IDENT){$env:INTEGRATION_SCAFFOLDING_IDENT}else{"chef/scaffolding-chef-infra"}
$scaffold_policy_name="ci"
$scaffold_chef_client=if($env:INTEGRATION_CHEF_CLIENT_IDENT){$env:INTEGRATION_CHEF_CLIENT_IDENT}else{"chef/chef-infra-client"}

$pkg_description="Integration test plan for Chef 19 Effortless scaffolding (Windows)"
$pkg_license="Apache-2.0"
$pkg_maintainer="The Habitat Maintainers humans@habitat.sh"
$pkg_upstream_url="https://chef.sh"
