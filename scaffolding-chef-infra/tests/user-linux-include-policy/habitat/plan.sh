#######################################
# User plan for ci testing
# This tests a user interacting with scaffold API
#######################################

#@IgnoreInspection BashAddShebang
if [ -z "${CHEF_POLICYFILE+x}" ]; then
  policy_name="ci"
else
  policy_name="${CHEF_POLICYFILE}"
fi

pkg_name=user-linux-nested-policy
pkg_origin=ci
pkg_version="1.0.0"
pkg_scaffolding="ci/scaffolding-chef-infra"
pkg_svc_user=("root")
scaffold_policy_name="$policy_name"
scaffold_chef_license="accept-no-persist"

# Required Metadata for CI
pkg_description="CI Test Plan for include policy Linux"
pkg_license="Apache-2.0"
pkg_maintainer="The Habitat Maintainers humans@habitat.sh"
pkg_upstream_url="https://chef.sh"
