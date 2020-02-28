# Policyfile.rb - Describe how you want Chef to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile.html

# A name that describes what the system you're building with Chef does.
name "production"

# Where to find external cookbooks:
default_source :supermarket
default_source :chef_repo, "../"

include_policy "base", path: "./base.lock.json"

run_list ['hardening::default']

# This is an example of how to override an attribute
# default['hardening'] = {
#   'kernel'  => {
#     'disable_filesystems' => ['cramfs', 'freevxfs', 'jffs2', 'hfs', 'hfsplus', 'squashfs', 'udf', 'vfat'],
#   }
# }

default['patching']['timing'] = 'manual'
default['patching']['patchlevel'] = 5