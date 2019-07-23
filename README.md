# Effortless

[![Build status](https://badge.buildkite.com/7ed9be7c2b2a9f812f68e4f0fc654e0ac857e6e854d48caec1.svg?branch=master)](https://buildkite.com/chef/chef-effortless-master-habitat-build)

`Effortless` is automated best practices for Chef Infra and Chef InSpec.

## Quick Links

- [Chef Infra](#chef-infra)
- [Chef InSpec](#chef-inspec)

## Chef Infra

Automated best practices for Chef Infra is this simple:

```bash
pkg_name=example-app
pkg_origin=example-corporation
pkg_version=1.0.0
pkg_scaffolding=chef/scaffolding-chef-infra
scaffold_policy_name=example-app
```

Effortless for Chef Infra is a strong way to build, run, and manage the Chef Infra Client and your cookbooks as a single, deployable package. It is optimized for running without the need for a Chef Infra Server and it provides a pull-based update strategy for continuous delivery of the Chef Infra Client and your cookbooks to your infrastructure nodes. It is a full replacement and improvement over the environment and role cookbook patterns or Berkshelf way. It is built on a solid foundation of battle-tested tools, and it is production and enterprise ready.

Setting `pkg_scaffolding="chef/scaffolding-chef-infra"` in your `plan.sh` or `plan.ps1` automatically keeps you up-to-date on the latest best practices.

![Image of the Effortless pattern](/docs/effortless-graphic.png)

You can implement the Effortless pattern for Chef Infra by building a Habitat package. All you need to do is make a `policyfile` and a Habitat plan (`plan.sh` or `plan.ps1`). Additionally, you can tune the settings of the Chef Infra Client by using the configuration methods described below.

### Policyfile

`example-app/example-app.rb`

```ruby
name 'example-app'

default_source :supermarket
default_source :chef_repo, '../' do |s|
  s.preferred_for 'example-app'
end

cookbook 'hostsfile'
cookbook 'line'
cookbook 'tar'
cookbook 'os-hardening'

run_list [
  'hardening::default', 'example-app::default'
]
```

### Windows Infra Plan

`example-app/plan.ps1`

```powershell
$pkg_name="example-app"
$pkg_origin="example-corporation"
$pkg_version="0.1.0"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_upstream_url="http://chef.io"
$pkg_deps=@(
  "core/cacerts"
  "stuartpreston/chef-client" # https://github.com/habitat-sh/habitat/issues/6671
)
$pkg_scaffolding="chef/scaffolding-chef-infra"
$scaffold_policy_name="example-app"
# These settings are optional - usually you won't need to use these
$scaffold_policyfile_path="$PLAN_CONTEXT" # allows you to use a policyfile in any location in your repo
$scaffold_chef_client="chef/chef-infra-client" # allows you to hard-pin to a version of the chef-infra-client
$scaffold_chef_dk="chef/chef-dk" # allows you to hard-pin to a version of chef-dk
$scaffold_data_bags_path="$PLAN_CONTEXT/../data_bags" # allows you to optionally build data bags into the package
$scaffold_cacerts="origin/cacerts" # allows you to optionally specify a custom cacert package for Chef Infra Client
```

## Chef InSpec

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
