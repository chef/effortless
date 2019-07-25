# Effortless

[![Build status](https://badge.buildkite.com/7ed9be7c2b2a9f812f68e4f0fc654e0ac857e6e854d48caec1.svg?branch=master)](https://buildkite.com/chef/chef-effortless-master-habitat-build)

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

## Existing Users - Effortless for Chef Infra

If you're already familiar with Chef Infra, here's a quick rundown of how Effortless for Chef Infra works.

1. Effortless uses a strong build process for your cookbooks. The build creates a single, deployable package with your cookbooks, an up-to-date Chef Infra Client, and the latest best practices.

2. At runtime, Chef Infra works without Chef Infra Server. It uses Chef Solo mode.

3. Chef Habitat manages Chef Infra, and provides a pull-based update strategy for continuous delivery of the Chef Infra Client and your cookbooks.

4. This workflow is a full replacement and improvement over the environment and role cookbook patterns or Berkshelf way.

5. Effortless is production and enterprise ready because it is built on already battle-tested Chef Infra tools that you know already.

![Image of the Effortless pattern](/docs/effortless-graphic.png)

If you're new to `Effortless`, the `examples` directory has a list of different kinds of packages and workflows that you can use to get started. If you just want to try something, start with `examples/infra-linux-hardening`.

## Effortless for Chef InSpec

Automated best practices for Chef InSpec is this simple:

```bash
pkg_name=example-app-audit
pkg_origin=example-corporation
pkg_version=1.0.0
pkg_scaffolding=chef/scaffolding-chef-inspec
```

Effortless for Chef InSpec allows you to build your Chef InSpec profiles and the Chef InSpec client together into a single deployable package. It provides a pull-based update strategy for continuously delivering your InSpec profiles to your infrastructure. It allows you to report all runs to Chef Automate without any other setup.

Setting `pkg_scaffolding="chef/scaffolding-chef-inspec"` in your `plan.sh` or `plan.ps1` automatically keeps you up-to-date on the latest best practices.

You can implement the Effortless pattern for Chef InSpec by building a Habitat package. A Habitat plan (`plan.sh` or `plan.ps1`). Additionally, you can tune the settings of Chef InSpec using the methods below.

### Linux InSpec Plan

`habitat/plan.sh`

```bash
pkg_name=example-app-audit
pkg_origin=example-corporation
pkg_version="0.1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("Apache-2.0")
pkg_upstream_url="http://chef.io"
pkg_scaffolding="chef/scaffolding-chef-inspec"
```

### Windows InSpec Plan

```powershell
$pkg_name="example-app-audit"
$pkg_origin="example-corporation"
$pkg_version="0.1.0"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=("Apache-2.0")
$pkg_build_deps=@("stuartpreston/inspec")
$pkg_deps=@("stuartpreston/inspec")
$pkg_description="example-app-audit"
$pkg_scaffolding="chef/scaffolding-chef-inspec"
```

### Chef InSpec settings

These are the defaults for the scaffolding. There several ways to override the default configuration. These methods are described below as they apply to both Chef Infra and Chef InSpec.

`default.toml`

```toml
# You must accept the Chef License to use this software: https://www.chef.io/end-user-license-agreement/
# Change [chef_license] from acceptance = "undefined" to acceptance = "accept-no-persist" if you agree to the license.

interval = 1800
splay = 1800
splay_first_run = 0
log_level = 'warn'

[chef_license]
acceptance = "undefined"

[automate]
enable = false
server_url = "https://<automate_url>/data-collector/v0/"
token = '<automate_token>'
user = '<automate_user>'
```

## Configurations

As noted above, there are several methods for applying configurations to an Effortless package. Let's take a look at the different methods in order of most to least recommended.

### user.toml file

By using the `user.toml` file, you can provide overrides for any of the values specified in the scaffolding defaults. This method requires that you place a `user.toml` file in a directory on each node that needs the override. This is the preferred option as the file can be managed in source code and applied via the provisioning tool.

- Linux path: `/hab/user/myservice/config/user.toml`
- Windows path: `C:\hab\user\myservice\config\user.toml`

`user.toml`

``` toml
interval = 3600

[chef_license]
acceptance = "undefined"

[automate]
enable = false
server_url = "https://<automate_url>/data-collector/v0/"
token = '<automate_token>'
user = '<automate_user>'
```

As you can see, we're only overriding specific parameters that we need. This allows us to reuse the same artifact across all environments and still provide environmental specific settings.

Read more [here](https://www.habitat.sh/docs/using-habitat/#apply-configuration-updates-to-an-individual-service).

### default.toml override

This option is at the bottom because it's the least desirable. Since the scaffolding generates a `default.toml` with sane defaults for us, there's no reason to duplicate that work. If you go this route, you'll need to make sure you account for all the variables included in the scaffolding. If there's an update to the scaffolding and the new variable isn't replicated in your package's `default.toml`, it will build, however, the package will fail when you run it on a node.
