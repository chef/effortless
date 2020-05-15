# What is Habitat Scaffolding?

Habitat scaffolding is a way to build a habitat plan that overrides some of the default functions Habitat uses during it's build process. You can find out more about scaffolding on the [Habitat docs page](https://www.habitat.sh/docs/glossary/#sts=Scaffolding).

## Why does the Effortless Pattern use scaffolding?

The reason we use habitat scaffolding is it provides the effortless maintainers a way to better manage the build and runtime steps needed to be successful with Chef Infra and Chef InSpec. This means that the amount of code you the customer needs to maintain in order to build and run Chef Infra and Chef InSpec is in a small plan file. This lets you focus on writing Chef cookbooks and InSpec profiles and not on how to build and run those things.

## How does scaffolding work?

By specifying the `pkg_scaffolding` variable in you plan Chef Habitat will pull in the necessary package dependencies, run the build steps for Chef Infra and/or Chef InSpec, and provide you with a Habitat artifact that contains your cookbooks or profiles and way to run them on your systems. The source code for these steps can be found here: [Chef Infra](https://github.com/chef/effortless/tree/master/scaffolding-chef-infra/lib) [Chef InSpec](https://github.com/chef/effortless/tree/master/scaffolding-chef-inspec/lib).