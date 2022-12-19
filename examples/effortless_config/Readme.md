# Effortless Config

This is the example for the Effortless Config pattern and is an opinionated example of the a repository structure and usage methodology for this pattern.

## Requirements

In order to get started with example you will need to install [Chef Habitat](https://www.habitat.sh/docs/install-habitat/) on your development workstation. If you would like to upload your package to the [Chef Habitat Builder](https://bldr.habitat.sh) you will also need to have configured your origin, and downloaded or created a key for your origin. You can find instructions on how to work with Chef Habitat Builder [here](https://www.habitat.sh/docs/using-builder/).

## Introduction

Before we build and test an Effortless Config application, it's important to understand what the application actually contains and does. This section will give you an overview of those topics.

The Effortless Config application uses the Policyfiles feature of Chef to encapsulate an application which runs chef-solo against a compiled Policyfile and the collection of cookbooks it needs. This is done in the underlying habitat code by running the chef install command against a Policyfile and then the chef export command to produce a working copy of the compiled Policyfile and all cookbooks. This is then bundled up as a habitat application, and executed using the application hooks provided to actually run Chef on the desired node.

It's possible to leverage the include_policy feature of Policyfiles to layer multiple Policyfiles on top of each other - we provide examples of doing this in the chef_repo_pattern's policyfiles directory.

It's important to note that as the Effortless Config application you're building is specific to the Policyfile it runs, the name of the artifact produced will be the $pkg_name from the plan file. So for example if you build Effortless Config for the base.rb policy in the chef_repo_pattern folder, the resulting application artifact will be called config-baseline.

If you're layering multiple Policyfiles using include_policy, the application will be named for the 'leaf node' in the tree. So for example if you build Effortless Config for the production.rb policy which in turn includes base.rb, the resulting artifact will be called config-baseline.

You can also use the scaffolding and the pattern to just manage a single cookbook that can be seen in the policy_cookbook_pattern folder.

Both of these patterns are greate example of use Effortless Config but the chef_repo_pattern is the most common as it pulls from some best pratices already in place around managing cookbooks and policyfiles.
