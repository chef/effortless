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

Effortless for Chef Infra is a strong way to build, run, and manage the chef-infra-client and your cookbooks as a single, deployable package. It is optimized for running without the need for a Chef Infra Server and it provides a pull-based update strategy for continuous delivery of the chef-infra-client and your cookbooks to your infrastructure nodes. It is a full replacement and improvement over the environment and role cookbook patterns or Berkshelf way. It is built on a solid foundation of battle-tested tools, and it is production and enterprise ready.

Setting `pkg_scaffolding="chef/scaffolding-chef-infra"` in your `plan.sh` or `plan.ps1` automatically keeps you up-to-date on the latest best practices.

![Image of the Effortless pattern](/docs/effortless-graphic.png)

You can implement the Effortless pattern for Chef Infra by building a Habitat package. All you need to do is make a `policyfile` and a Habitat plan (`plan.sh` or `plan.ps1`). Additionally, you can tune the settings of the chef-infra-client in your `default.toml`.

#### Policyfile
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

#### Linux
`example-app/plan.sh`
```bash
pkg_name=example-app
pkg_origin=example-corporation
pkg_version="0.1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("Apache-2.0")
pkg_upstream_url="http://chef.io"
pkg_scaffolding="chef/scaffolding-chef-infra"
scaffold_policy_name="example-app"
# These settings are optional - usually you won't need to use these
scaffold_policyfile_path="$PLAN_CONTEXT" # allows you to use a policyfile in any location in your repo
scaffold_chef_client="chef/chef-client" # allows you to hard-pin to a version of the chef-infra-client
scaffold_chef_dk="chef/chef-dk" # allows you to hard-pin to a version of chef-dk
scaffold_data_bags_path="$PLAN_CONTEXT/../data_bags" # allows you to optionally build data bags into the package
```

#### Windows

`example-app/plan.ps1`
```powershell
$pkg_name="example-app"
$pkg_origin="example-corporation"
$pkg_version="0.1.0"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_upstream_url="http://chef.io"
$pkg_scaffolding="echohack/scaffolding-chef-infra"
$scaffold_policy_name="example-app"
# These settings are optional - usually you won't need to use these
$scaffold_policyfile_path="$PLAN_CONTEXT" # allows you to use a policyfile in any location in your repo
$scaffold_chef_client="chef/chef-infra-client" # allows you to hard-pin to a version of the chef-infra-client
$scaffold_chef_dk="chef/chef-dk" # allows you to hard-pin to a version of chef-dk
$scaffold_data_bags_path="$PLAN_CONTEXT/../data_bags" # allows you to optionally build data bags into the package
```

#### chef-infra-client settings

Creating a default.toml is optional. If you don't create one, the chef-infra-client will run with the default settings below.

`example-app/default.toml`
```toml
interval = 1800 # The number of seconds to wait between chef-infra-client runs
splay = 1800 # A random number of seconds between 0 and $splay to add to the interval. Used to avoid the thundering herd problem.
splay_first_run = 0 # A random number of seconds between 0 and $splay_first_run to add to the interval, only on the first run. Used to avoid the thundering herd problem on new deployments.
run_lock_timeout = 1800 # The number of seconds to lock the chef-infra-client before allowing another run to begin.
log_level = "warn"
env_path_prefix = "/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin"
ssl_verify_mode = ":verify_peer"

[automate]
enable = false
server_url = "https://<automate_url>"
token = "<automate_token>"
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

You can implement the Effortless pattern for Chef InSpec by building a Habitat package. A Habitat plan (`plan.sh` or `plan.ps1`). Additionally, you can tune the settings of Chef InSpec in your `default.toml`.

#### Linux
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

#### Chef InSpec settings

`habitat/default.toml`
```toml
# You must accept the Chef License to use this software: https://www.chef.io/end-user-license-agreement/
# Change [chef_license] from acceptance = "undefined" to acceptance = "accept-no-persist" if you agree to the license.

interval = 1800
splay = 1800
splay_first_run = 0
log_level = 'warn'
report_to_stdout = true

[chef_license]
acceptance = "undefined"

[automate]
enable = false
url = 'https://<automate_url>'
token = '<automate_token>'
user = '<automate_user>'
```
