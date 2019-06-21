# scaffolding-chef

`scaffolding-chef` is an implementation of best practices for Chef Infra as a Habitat package. This pattern of using Chef Infra is known as the Effortless pattern.

Effortless for Chef Infra is a strong way to build, run, and manage the chef-client and your cookbooks as a single, deployable package. It is optimized for running without the need for a Chef Server and it provides a pull-based update strategy for continuous delivery of the chef-client and your cookbooks to your infrastructure nodes. It is a full replacement and improvement over the environment and role cookbook patterns or Berkshelf way. It is built on a solid foundation of battle-tested tools, and it is production and enterprise ready.

![Image of scaffolding-chef](/docs/effortless-graphic.png)

You can implement the Effortless pattern for Chef Infra by building a Habitat package and using this scaffolding. All you need to do is make a `policyfile` and a Habitat plan (`plan.sh` or `plan.ps1`). Additionally, you can tune the settings of the chef-client in your `default.toml`.

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
pkg_scaffolding="chef/scaffolding-chef"
scaffold_policy_name="example-app"
# These settings are optional - usually you won't need to use these
scaffold_policyfile_path="$PLAN_CONTEXT" # allows you to use a policyfile in any location in your repo
scaffold_chef_client="chef/chef-client" # allows you to hard-pin to a version of the chef-client
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
$pkg_scaffolding="echohack/scaffolding-chef"
$scaffold_policy_name="example-app"
# These settings are optional - usually you won't need to use these
$scaffold_policyfile_path="$PLAN_CONTEXT" # allows you to use a policyfile in any location in your repo
$scaffold_chef_client="chef/chef-client" # allows you to hard-pin to a version of the chef-client
$scaffold_chef_dk="chef/chef-dk" # allows you to hard-pin to a version of chef-dk
$scaffold_data_bags_path="$PLAN_CONTEXT/../data_bags" # allows you to optionally build data bags into the package
```

#### chef-client settings

Creating a default.toml is optional. If you don't create one, the chef-client will run with the default settings below.

`example-app/default.toml`
```toml
interval = 1800 # The number of seconds to wait between chef-client runs
splay = 1800 # A random number of seconds between 0 and $splay to add to the interval. Used to avoid the thundering herd problem.
splay_first_run = 0 # A random number of seconds between 0 and $splay_first_run to add to the interval, only on the first run. Used to avoid the thundering herd problem on new deployments.
run_lock_timeout = 1800 # The number of seconds to lock the chef-client before allowing another run to begin.
log_level = "warn"
env_path_prefix = "/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin"
ssl_verify_mode = ":verify_peer"

[data_collector]
enable = false
token = "set_to_your_token"
server_url = "set_to_your_url"
```
