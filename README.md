# Effortless

[![Build status](https://badge.buildkite.com/7ed9be7c2b2a9f812f68e4f0fc654e0ac857e6e854d48caec1.svg?branch=master)](https://buildkite.com/chef/chef-effortless-master-habitat-build)

`Effortless` is pattern to better manage Chef and Chef InSpec workloads using Chef Habitat.

## Quick Links

- [Chef Infra](https://github.com/chef/chef) - Chef Infra automates infrastructure configuration, ensuring every system is configured correctly and consistently.

- [Chef InSpec](https://github.com/inspec/inspec) - Automate security tests, ensuring consistent standards are enforced in every environment, at every stage of development.

- [Chef Habitat](https://github.com/habitat-sh/habitat) - Codify how the application is built, how it runs, and all of its dependencies to free the app from underlying infrastructure and make updates easy.

- [Chef Automate](https://github.com/chef/automate) - Enterprise dashboard and analytics tool enabling cross-team collaboration with actionable insights for configuration and compliance and an auditable history of changes to environments.

## Existing Users

If you're already familiar with the Chef stack, here's a quick rundown of how Effortless works.

1. Effortless uses a build process to pull down all your cookbooks or profiles. The build creates a single, deployable package. For Chef Infra, it contains your cookbooks, an up-to-date Chef Infra client, and the latest best practices. For Chef InSpec, it contains your profiles, an up-to-date Chef InSpec client, and the latest best practices.

1. At runtime, Chef Infra works without Chef Infra Server. It uses Chef Solo mode.

1. At runtime, Chef InSpec works without pulling profiles from Chef Automate. All profiles, including those from Chef Automate, are vendored at build time.

1. Chef Habitat manages Chef Infra and Chef InSpec, and provides a pull-based update strategy for continuous delivery.

1. This workflow is a replacement for the environment and role cookbook patterns or Berkshelf way.

![Image of the Effortless pattern](/docs/effortless-graphic.png)

## Chef 19 Support

As of `v0.26.0`, the `scaffolding-chef-infra` has been updated to support **Chef Infra Client 19**:

| Change | Details |
|--------|---------|
| Ruby version (Linux/ARM) | `core/ruby3_4` (was `core/ruby31`) |
| Ruby version (Windows) | `core/ruby3_4-plus-devkit` (was `chef/ruby31-plus-devkit`) |
| Habitat Builder channel | `base-2025` (required for Chef 19 packages) |

### Certified Platforms for Chef 19

| Platform | Architecture | Status |
|----------|-------------|--------|
| Linux | x86_64 | ✅ Certified |
| Linux | ARM | ✅ Certified |
| Windows | x86_64 | ✅ Certified |
| Windows | ARM | 🔄 In progress ([CHEF-33898](https://progresssoftware.atlassian.net/browse/CHEF-33898)) |
| macOS | x86_64 | 🔄 In progress ([CHEF-33898](https://progresssoftware.atlassian.net/browse/CHEF-33898)) |
| macOS | ARM | 🔄 In progress ([CHEF-33898](https://progresssoftware.atlassian.net/browse/CHEF-33898)) |

### Migrating from Chef 18 to Chef 19 Effortless

If you are currently using the Effortless pattern with Chef 18, no changes to your user-facing `plan.sh` or `plan.ps1` are required. The scaffolding automatically resolves the correct Ruby and Chef client versions. Simply update your `pkg_scaffolding` to pick up the latest `chef/scaffolding-chef-infra` from the `base-2025` channel.

If you pin `scaffold_chef_client` explicitly, ensure it points to a Chef 19 package (e.g., `chef/chef-infra-client/19.x.x`).

> **Note:** The scaffolding defaults `HAB_BLDR_CHANNEL` to `base-2025`. You can override this per-package by setting `scaffold_hab_bldr_channel` in your `plan.sh` / `plan.ps1`.

## Next Steps

If you are new to the `Effortless` pattern checkout some of the below examples and walk throughs that will help you understand what you can do with this pattern.

## Examples

1. [Effortless Audit](examples/effortless_audit/Readme.md)
1. [Effortless Config](examples/effortless_config/Readme.md)
