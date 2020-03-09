# Effortless Config

Effortless Config is the pattern for managing your Chef Infra workloads. It uses [Habitat](https://www.habitat.sh/docs/) and [Chef Policyfiles](https://docs.chef.io/policyfile/) to build an artifact that contains the cookbooks and their dependencies alongside the scripts necessary to run them on your systems.

## Patterns

## Chef Repo Cookbook pattern

This pattern is used to build policyfiles using the chef_repo pattern for organizing your cookbooks. The chef-repo pattern can be found [here](https://docs.chef.io/chef_repo/).

1. To use this pattern navigate to the cookbook you want to use
   ```
   cd chef-repo
   ```
1. Make a habitat directory
   ```
   mkdir habitat
   ```
1. Make a plan file
   
   > Notes: For a cookbook targeting windows use a `plan.ps1` for Linux use a `plan.sh` if your cookbook targets both windows and linux you can have both a `plan.ps1` and a `plan.sh` in your habitat directory.
   ```
   touch plan.sh
   ```
1. Add some information about your cookbok to your plan
   plan.sh
   ```bash
   pkg_name=<NAME FOR YOUR POLICYFILE>
   pkg_origin=<YOUR ORIGIN>
   pkg_version="0.1.0"
   pkg_maintainer="YOUR NAME AND EMAIL"
   pkg_license=("Apache-2.0")
   pkg_scaffolding="chef/scaffolding-chef-infra"
   pkg_svc_user=("root")
   scaffold_policy_name="<YOUR POLICYFILE NAME>"
   ```
1. Create a policyfile directory in your chef-repo and build a policyfile
   
   Example of a policyfile.rb:
   ```ruby
   # Policyfile.rb - Describe how you want Chef Infra to build your system.
   #
   # For more information on the Policyfile feature, visit
   # https://docs.chef.io/policyfile.html

   name "base"

   # Where to find external cookbooks
   default_source :supermarket
   default_source :chef_repo, "../"

   # run_list: run these recipes in the order specified.
   run_list [
   "patching::default",
   "hardening::default"
   ]

   # attributes: set attributes from your cookbooks
   default['hardening'] = {}

   default['patching'] = {}

   ```
1. Build the package
   ```
   hab pkg build
   ```
1. Modify your `kitchen.yml` file to look like this
   ```
   ---
   driver:
   name: vagrant
   synced_folders:
      - ["./results", "/tmp/results"]

   provisioner:
   name: shell

   verifier:
   name: inspec

   platforms:
   - name: centos-7.6

   suites:
   - name: base
      provisioner:
         arguments: ["<YOUR ORIGIN>", "<YOUR PACKAGE NAME>"]
      verifier:
         inspec_tests:
         test/integration/base
   ```
1. Create a `bootstrap.sh` script
   ```
   #!/bin/bash
   export HAB_LICENSE="accept-no-persist"
   export CHEF_LICENSE="accept-no-persist"

   if [ ! -e "/bin/hab" ]; then
   curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash
   fi

   if grep "^hab:" /etc/passwd > /dev/null; then
   echo "Hab user exists"
   else
   useradd hab && true
   fi

   if grep "^hab:" /etc/group > /dev/null; then
   echo "Hab group exists"
   else
   groupadd hab && true
   fi

   pkg_origin=$1
   pkg_name=$2

   echo "Starting $pkg_origin/$pkg_name"

   latest_hart_file=$(ls -la /tmp/results/$pkg_origin-$pkg_name* | tail -n 1 | cut -d " " -f 9)
   echo "Latest hart file is $latest_hart_file"

   echo "Installing $latest_hart_file"
   hab pkg install $latest_hart_file

   echo "Determing pkg_prefix for $latest_hart_file"
   pkg_prefix=$(find /hab/pkgs/$pkg_origin/$pkg_name -maxdepth 2 -mindepth 2 | sort | tail -n 1)

   echo "Found $pkg_prefix"

   echo "Running chef for $pkg_origin/$pkg_name"
   cd $pkg_prefix
   hab pkg exec $pkg_origin/$pkg_name chef-client -z -c $pkg_prefix/config/bootstrap-config.rb
   ```
1. Run Test Kitchen to ensure your cookbook works on Linux
   ```
   kitchen converge base-centos
   ```
   > Note: This will spin up a CentOS 7 VM locally and run your cookbook using the latest Chef Client. If you get errors in the Chef run you may need to supply attributes to your policyfile or make modifications so that your cookbook can run using the latest Chef Client
1. When you are ready destroy the VM by running `kitchen destroy`
1. You can now upload your habitat pkg to builder by running the following
   ```
   source results/lastbuild.env
   hab pkg upload results/$pkg_artifact
   ```
1. To run your policyfile on a system you just need to install habitat as a service and run `hab svc load <your_origin>/<your_policyfile_name>`

### Policyfile Cookbook pattern

This is a pattern of building an artifact for a single cookbook. 

1. To use this pattern navigate to the cookbook you want to use
   ```
   cd chef-repo/cookbooks/foo_cookbook
   ```
1. Make a habitat directory
   ```
   mkdir habitat
   ```
1. Make a plan file
   
   > Notes: For a cookbook targeting windows use a `plan.ps1` for Linux use a `plan.sh` if your cookbook targets both windows and linux you can have both a `plan.ps1` and a `plan.sh` in your habitat directory.
   ```
   touch plan.sh
   ```
1. Add some information about your cookbok to your plan
   plan.sh
   ```
   pkg_name=<Name of your cookbook artifact>
   pkg_origin=<your Origin>
   pkg_version="<Cookbook version>"
   pkg_maintainer="<Your Name>"
   pkg_license=("<License for you cokbook example Apache-2.0>")
   pkg_scaffolding="chef/scaffolding-chef-infra"
   scaffold_policy_name="Policyfile"
   scaffold_policyfile_path="$PLAN_CONTEXT/../" # habitat/../Policyfile.rb
   ```
1. Ensure you have a policyfile at in your cookbook directory
   
   Example of a policyfile:
   ```
   # Policyfile.rb - Describe how you want Chef to build your system.
   #
   # For more information on the Policyfile feature, visit
   # https://docs.chef.io/policyfile.html

   # A name that describes what the system you're building with Chef does.
   name '<Your Cookbook Name>'

   # Where to find external cookbooks:
   default_source :supermarket

   # run_list: chef-client will run these recipes in the order specified.
   run_list '<Your Cookbook Name>::default'

   # Specify a custom source for a single cookbook:
   cookbook '<Your Cookbook Name>', path: '.'
   ```
1. Build the package
   ```
   hab pkg build <Your Cookbook Name>
   ```
1. Modify your `kitchen.yml` file to look like this
   ```
   ---
   driver:
   name: vagrant
   synced_folders:
      - ["./results", "/tmp/results"]

   provisioner:
   name: shell

   verifier:
   name: inspec

   platforms:
   - name: centos-7.6

   suites:
   - name: base
      provisioner:
         arguments: ["<YOUR ORIGIN>", "<YOUR COOKBOOK NAME>"]
      verifier:
         inspec_tests:
         test/integration/base
   ```
1. Create a `bootstrap.sh` script
   ```
   #!/bin/bash
   export HAB_LICENSE="accept-no-persist"
   export CHEF_LICENSE="accept-no-persist"

   if [ ! -e "/bin/hab" ]; then
   curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash
   fi

   if grep "^hab:" /etc/passwd > /dev/null; then
   echo "Hab user exists"
   else
   useradd hab && true
   fi

   if grep "^hab:" /etc/group > /dev/null; then
   echo "Hab group exists"
   else
   groupadd hab && true
   fi

   pkg_origin=$1
   pkg_name=$2

   echo "Starting $pkg_origin/$pkg_name"

   latest_hart_file=$(ls -la /tmp/results/$pkg_origin-$pkg_name* | tail -n 1 | cut -d " " -f 9)
   echo "Latest hart file is $latest_hart_file"

   echo "Installing $latest_hart_file"
   hab pkg install $latest_hart_file

   echo "Determing pkg_prefix for $latest_hart_file"
   pkg_prefix=$(find /hab/pkgs/$pkg_origin/$pkg_name -maxdepth 2 -mindepth 2 | sort | tail -n 1)

   echo "Found $pkg_prefix"

   echo "Running chef for $pkg_origin/$pkg_name"
   cd $pkg_prefix
   hab pkg exec $pkg_origin/$pkg_name chef-client -z -c $pkg_prefix/config/bootstrap-config.rb
   ```
1. Run Test Kitchen to ensure your cookbook works on Linux
   ```
   kitchen converge base-centos
   ```
   > Note: This will spin up a CentOS 7 VM locally and run your cookbook using the latest Chef Client. If you get errors in the Chef run you may need to supply attributes to your policyfile or make modifications so that your cookbook can run using the latest Chef Client
1. When you are ready destroy the VM by running `kitchen destroy`
1. You can now upload your habitat pkg to builder by running the following
   ```
   source results/lastbuild.env
   hab pkg upload results/$pkg_artifact
   ```
1. To run your cookbook on a system you just need to install habitat as a service and run `hab svc load your_origin/your_cookbook`
