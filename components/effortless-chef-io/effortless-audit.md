# Effortless Audit

Effortless Audit is the pattern for managing you Chef InSpec profiles. IT uses [Chef Habitat](https://www.habitat.sh/docs/) and [Chef InSpec](https://www.inspec.io/) to build an artifact that contains your profile and it's dependencies alongside the scripts necessary to run them on you systems.

> Note: To learn more about InSpec profiles checkout the documentation [here](https://www.inspec.io/docs/reference/profiles/).

## Patterns

### Wrapper Profile Pattern

In InSpec a common pattern is to write a wrapper profile that depends on another profile. This pattern is used to pull profiles from a main profile source like the [Chef Automate Profile Store](https://automate.chef.io/docs/profiles/).

> Note: You can find an example of this pattern [here](https://github.com/chef/effortless/tree/master/examples/effortless_audit).

1. To use this pattern navigate to the profile you want to use
   ```
   cd my-profile
   ```
1. Make a habitat directory
   ```
   mkdir habitat
   ```
1. Make a plan file
   
   > Notes: For a profile targeting windows use a `plan.ps1` for Linux use a `plan.sh` if your profile targets both windows and linux you can have both a `plan.ps1` and a `plan.sh` in your habitat directory.
   ```
   touch plan.sh
   ```
1. Add some information about your profile to your plan
   ```
   pkg_name=<YOUR PROFILE NAME>
   pkg_origin=<YOUR ORIGIN>
   pkg_version=<THE VERSION OF YOUR PROFILE>
   pkg_maintainer="YOUR NAME AND EMAIL"
   pkg_license=("Apache-2.0")
   pkg_scaffolding="chef/scaffolding-chef-inspec"
   ```
1. Build the package
   ```
   hab pkg build
   ```
1. Add a kitchen file to your profile with the following content
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

   echo "Running inspec for $pkg_origin/$pkg_name"
   cd $pkg_prefix
   hab pkg exec $pkg_origin/$pkg_name inspec exec $pkg_prefix/*.tar.gz
   ```
1. Run Test Kitchen to ensure your profile executes
   ```
   kitchen converge base-centos
   ```
   > Note: This will spin up a CentOS 7 VM locally and run you profile using the latest Chef InSpec. If you get failures that's okay most vanilla VM's are not fully hardened to your security policies. If you want to fix the failures take a look at using [Chef Infra and the Effortless Config Pattern](effortless-config.md).
1. When you are ready destroy the VM by running `kitchen destroy`
1. You can now upload your profile pkg to builder by running the following
   ```
   source results/lastbuild.env
   hab pkg upload results/$pkg_artifact
   ```
1. To run your profile on a system you just need to install habitat as a service and run `hab svc load <your_origin>/<your_profile_name>`

## Features

### Waivers

With the release of scaffolding-chef-inspec version 0.16.0 (Linux) and version 0.18.0 (Windows) we have added the Chef InSpec waivers feature. This feature allows you to specify a control id's in your habtitat config that you would like to skip/waive. 

1. Build and Effortless Audit profile and load it on your systems
1. Create a waiver toml file like the below example
   ```
   [waivers]
   [waivers.control_id]
   run = false
   expiration_date: 2021-11-31
   justification = I don't want this control to run cause it breaks my app
   ```
1. Apply the new change to your habitat config
   ```
   hab config apply <your profile service>.<your profile service group> $(date) <your config toml file>
   ```
1. Habitat will now see there has been a configuration change and automatically re-run your profile and skip the control you specified in the toml file.
