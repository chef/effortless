# Plan Variables and Chef Habitat Configuration

This documents the options for both your plans and your Chef Habitat configuration file.

## Effortless Config

### Plan Variables

The Effortless pattern lets you use any default plan variables shipped with Chef Habitat. Read more about [plan variables](https://www.habitat.sh/docs/reference/#plan-variables) in the Chef Habitat Documentation.

scaffold_chef_client
: The Chef Habitat `chef-infra-client` package used. Change to use a different package. Default: `chef/chef-infra-client`

scaffold_cacerts
: The Chef Habitat `cacerts` package used during the Chef Infra Client run. Change to use a different package. Default: `chef/cacerts`

scaffold_policyfile_path
:Path to the policyfile. Default is `$PLAN_CONTEXT/../policyfiles`

scaffold_data_bags_path
:Path to the `data_bags` directory that contains the `data_bags`, if needed by your cookbook. Default is `$PLAN_CONTEXT/../data_bags`

### Chef Habitat Settings in Effortless Config

interval
: Interval at which the Chef Infra Client runs. Default is 1800 seconds (30 minutes).

splay
: Number used as the last number in a range to create a random number that is then added to the interval to determine when the Chef Infra Client runs next. Default is 1800 seconds.

splay_first_run
: Splay for the first run of the Chef Infra Client. Default 0 seconds.

run_lock_timeout
: Setting for the run lock timeout for the Chef Infra Client run. Default is 1800 seconds

log_level
: Log level for the Chef Infra Client. Default is `warn`

env_path_prefix
: String that will be the Environment Path variable for the Chef Infra Client run. default is

  Linux:

  `/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin`

  Windows:

  `;C:/WINDOWS;C:/WINDOWS/system32/;C:/WINDOWS/system32/WindowsPowerShell/v1.0;C:/ProgramData/chocolatey/bin`

ssl_verify_mode
: SSL Verification mode for the Chef Infra Client. Default is `:verify_peer`

verify_api_cert
: Boolean option on to determine if the api cert requires verification. Default is `false`

#### Chef License in Effortless Config

This configuration needs to be under the `[chef_license]` block in the toml file.

acceptance
: Determines the chef license acceptance at run time. Required for Chef Infra Client. See Chef License [here](https://docs.chef.io/chef_license_accept/#accepting-the-chef-license). Default `undefined`

#### Chef Automate in Effortless Config

These configurations need to be under the `[automate]` block in your toml file.

enable
: Enables or disables reporting to Chef Automate. Boolean. Default is `false`

server_url
: Chef Automate server URL. Example: `https://automate.example.com/data-collector/v0/`. Default: `https://<automate_url>`

token
: Chef Automate API token. Default: `<automate_token>`

## Effortless Audit

### Plan Variables in Effortless Audit

scaffold_inspec_client
: The Chef Habitat `inspec` package. Change to use a different package. Default is `chef/inspec`

scaffold_cacerts
: The Chef Habitat `cacerts` package during the Chef Infra Client run. Change to use a different package. Default is `chef/cacerts`

> Required if the profile uses a depends line for compliance in the `inspec.yml` as shown below:

```yaml
depends:
  - name: cis-rhel7-level1-server
    compliance: admin/cis-rhel7-level1-server
```

scaffold_automate_server_url
: Point to the Chef Automate server needed to fetch profile dependencies from the Chef Automate Asset Store. Example: `https://automate.example.com`. Required if the profile uses a line for compliance in the `inspec.yml`.

scaffold_automate_user
: Chef Automate user for the installed profile.

scaffold_automate_token
: Chef Automate API token.

### Chef Habitat Settings in Effortless Audit

interval
: Interval at which the Chef InSpec client runs. Default is 1800 seconds (30 minutes).

splay
: The last number in seconds of a range used to create a random number. The sum of the random number and the `interval` setting determines the start of the next Chef InSpec client run. Default is 1800 seconds.

splay_first_run
: Splay for the first run of the Chef InSpec client. Default 0 seconds.

log_level
: Log level for the Chef InSpec client. Default is `warn`

#### Chef License in Effortless Audit

This configuration needs to be under the `[chef_license]` block in the toml file.

acceptance
: Determines the chef license acceptance at run time. Required for Chef Infra Client. See Chef License [here](https://docs.chef.io/chef_license_accept/#accepting-the-chef-license). Default `undefined`

#### Chef Automate in Effortless Audit

These configurations need to be under the `[automate]` block in your toml file.

enable
: Enables or disables reporting to Chef Automate. Boolean. Default is `false`

server_url
: The Chef Automate server URL. Example: `https://automate.foo.com/data-collector/v0/`. Default: `https://<automate_url>`

token
: Chef Automate API token. Default: `<automate_token>`

environment
: Environment tag for the Chef InSpec report. This can be use to help with filtering in Chef Automate. Optional.
