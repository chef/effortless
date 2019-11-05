$pkg_name="windows-hardening"
$pkg_origin="effortless"
$pkg_version="0.1.0"
$pkg_upstream_url="http://chef.io"
$pkg_build_deps=@("core/chef-dk")
$pkg_deps=@(
  "core/cacerts"
  "chef/chef-infra-client/15.4.63/20191104181446" # https://github.com/habitat-sh/habitat/issues/6671
)
$pkg_scaffolding="chef/scaffolding-chef-infra"
$scaffold_policy_name="base"

#######################################
# Optional settings
#######################################

# You don't usually need to change these.
# This project provides highly tuned defaults for you.
# If you don't have a strong reason for overriding these
# Then it's a good idea to remove them.

# $scaffold_policyfile_path="$PLAN_CONTEXT"
# allows you to use a policyfile in any location in your repo

# $scaffold_chef_client="chef/chef-client"
# allows you to hard-pin to a version of the chef-infra-client

# $scaffold_chef_dk="chef/chef-dk"
# allows you to hard-pin to a version of chef-dk

# $scaffold_data_bags_path="$PLAN_CONTEXT/../data_bags"
# allows you to build data bags into the package

# $scaffold_cacerts="origin/cacerts"
# allows you to specify a custom cacert package
