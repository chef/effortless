# Linux Effortless Audit Example

This example is meant to serve as an example of testing a Habitat + Chef InSpec
Scaffolding package. It works by sharing `results/` with a Kitchen VM and then
running `test/scripts/provisioner.sh` which will:

  - Install the Habitat CLI in the Kitchen instance
  - Configure the `hab` user and group
  - Install the latest Habitat `.hart` package in `/tmp/results`
    - Don't forget to run build your package on each change!
  - Run `inspec` inside the package to converge the Kitchen instance

## Prerequisites

1. [Install Chef Workstation](https://downloads.chef.io/chef-workstation/)

2. [Install Chef Habitat](https://www.habitat.sh/docs/install-habitat/)

3. Run `hab setup` and follow the prompts. The origin you create will be your
   personal origin for testing packages for local development. You should never
   use your personal origin for packages running beyond your CI system.

## Testing with Kitchen

1. Run: `hab studio enter`
2. Run: `CHEF_LICENSE='accept-no-persist' build`
3. Exit the studio: `exit`
4. Use the usual Test Kitchen commands:
   - `kitchen create`
   - `kitchen converge`
   - `kitchen verify`
   - `kitchen destroy`
