# Policyfile.rb - Describe how you want Chef to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile.html

name "base"

# Where to find external cookbooks:
default_source :supermarket
default_source :chef_repo, "../"

# attributes: set attributes from your cookbooks
default['hardening'] = {}

default['patching'] = {}

default['applications'] = {
  'windows' => {}
}

# run_list: run these recipes in the order specified.
run_list [
  "patching::default",
  "hardening::default"
]

