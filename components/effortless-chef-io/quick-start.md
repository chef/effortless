# Quick Start
This is a guide on how to easly get started with Effortless

## Effortless Config 
1. Install [Chef Workstation](https://downloads.chef.io/chef-workstation)
1. Install [Chef Habitat](https://www.habitat.sh/docs/install-habitat/)
1. Configure Habitat on your worksation by runing `hab setup`
1. Change Directory into examples/effortless_config/chef_repo_pattern
1. Change the line 26 of the `kitchen.yml` file to use your origin
   ```
   provisioner:
     arguments: ["<Your Origin>", "effortless-config-baseline"]
   ```
1. Build the package `hab pkg build .`
1. Run Test Kitchen to see the cookbook work
   ```
   kitchen converge base-centos
   ```