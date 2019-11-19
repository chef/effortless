# Effortless

[![Build status](https://badge.buildkite.com/7ed9be7c2b2a9f812f68e4f0fc654e0ac857e6e854d48caec1.svg?branch=master)](https://buildkite.com/chef/chef-effortless-master-habitat-build)

**Project State**: [Active](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md#active)

**Issues [Response Time Maximum](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md)**: 14 days

**Pull Request [Response Time Maximum](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md)**: 14 days

`Effortless` is automated best practices for Chef Infra and Chef InSpec.

What can you do with Effortless Infrastructure?

- Deliver brand new infrastructure configuration and automated security tests to your entire fleet, in 60 seconds.

- Use a secure, pull-based workflow that scales. Use the same workflow in airgapped environments.

- Update Chef Infra and Chef InSpec automatically, with always up-to-date best practices.

- Report infrastructure configuration and security test runs to [Chef Automate](https://www.chef.io/products/automate/), automatically.

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

1. This workflow is a full replacement and improvement over the environment and role cookbook patterns or Berkshelf way.

1. Effortless is production and enterprise ready because it is built on already battle-tested Chef tools that you know already.

![Image of the Effortless pattern](/docs/effortless-graphic.png)

## Next Steps

If you're new to `Effortless`, the `examples` directory has a list of different kinds of packages and workflows that you can use to get started. If you just want to try something, start with `examples/infra-linux-hardening`.
