# Plan Variables and Habitat Configurations

This documents the options for both your plan and your habitat configurations file.

## Effortless Config

### Plan Variables

You can use all the default plan variables that are shipped with habitat you cand find a list of these [here](https://www.habitat.sh/docs/reference/#plan-variables).

**$scaffold_chef_client**: Variable to change the chef-client habitat package that is used. Default is `chef/chef-infra-client`

**$scaffold_cacerts**: Variable to change the CACerts habitat package that is used during the chef-client run. Default is `chef/cacerts`

**$scaffold_policyfile_path**: Path to the policyfile to be built. Default is `$PLAN_CONTEXT/../policyfiles`

**$scaffold_data_bags_path**: Path to the data_bags folder containing data_bags that the cookbook may need to run. Default is `$PLAN_CONTEXT/../data_bags`

### Habitat Config Settings

**interval**: Interval the chef-client with run at. Default is 1800 seconds (30 minutes).

**splay**: Number that will be used as the last number in a range to create a random number that will be added to the interval to determine when the chef-client is run again. Default is 1800 seconds.

**splay_first_run**: Splay for the first run of the chef-client. Default 0 seconds.

**run_lock_timeout**: Setting for the run lock timeout for chef-client run. Default is 1800 seconds

**log_level**: Log level for the chef-client. Default is `warn`

**env_path_prefix**: String that will be the Enivironment Path variable for the chef-client run. default is

  Linux:
  
  `/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin`

  Windows:
  
  `;C:/WINDOWS;C:/WINDOWS/system32/;C:/WINDOWS/system32/WindowsPowerShell/v1.0;C:/ProgramData/chocolatey/bin`

**ssl_verify_mode**: SSL Verification mode for the chef client. Default is `:verify_peer`

**verify_api_cert**: Boolean option on to determine if the api cert should be verified. Default is `false`

#### Chef License
This configuration needs to be under the `[chef_license]` block in the toml file.

**acceptance**: Determines the chef license acceptance at run time. This setting is required for chef-client to run successfully. See Chef License [here](https://docs.chef.io/chef_license_accept/#accepting-the-chef-license). Default `undefined`

#### Automate
These configurations need to be under the `[automate]` block in your toml file.

**enable**: Boolean to determine if the reporting to Chef Automate is turned on. Default is `false`

**server_url**: The server url of the Chef Automate Server. Example: `https://automate.foo.com/data-collector/v0/`. Default: `https://<automate_url>`

**token**: Chef Automate API token. Example: `GR4_yqRNUtWFVgnVh57GQL9Hh9I=`. Default: `<automate_token>`

## Effortless Audit

### Plan Variables

**scaffold_inspec_client**: Variable to change the inspec habitat package that is used. Default is `chef/inspec`

**scaffold_cacerts**: Variable to change the CACerts habitat package that is used during the chef-client run. Default is `chef/cacerts`

> These variables are required if the profile had a depends line for compliance in the `inspec.yml` as shown below.
inspec.yml
```
depends:
  - name: cis-rhel7-level1-server
    compliance: admin/cis-rhel7-level1-server
```

**scaffold_automate_server_url**: Variable to point to the automate server to pull down profile dependencies from the Chef Automate Asset Store. Example: `https://automate.foo.com`. This variable is required if the profile had a depends line for compliance in the `inspec.yml` as shown below.

**scaffold_automate_user**: Chef Automate User the profile has been installed for.

**scaffold_automate_token**: Chef Automate API token.

### Habitat Config Variables

**interval**: Interval inspec with run at. Default is 1800 seconds (30 minutes).

**splay**: Number that will be used as the last number in a range to create a random number that will be added to the interval to determine when the inspec client is run again. Default is 1800 seconds.

**splay_first_run**: Splay for the first run of the inspec client. Default 0 seconds.

**log_level**: Log level for the inspec client. Default is `warn`

#### Chef License
This configuration needs to be under the `[chef_license]` block in the toml file.

**acceptance**: Determines the chef license acceptance at run time. This setting is required for chef-client to run successfully. See Chef License [here](https://docs.chef.io/chef_license_accept/#accepting-the-chef-license). Default `undefined`

#### Automate
These configurations need to be under the `[automate]` block in your toml file.

**enable**: Boolean to determine if the reporting to Chef Automate is turned on. Default is `false`

**server_url**: The server url of the Chef Automate Server. Example: `https://automate.foo.com/data-collector/v0/`. Default: `https://<automate_url>`

**token**: Chef Automate API token. Example: `GR4_yqRNUtWFVgnVh57GQL9Hh9I=`. Default: `<automate_token>`

**environment**: (Optional) Environment tag for the InSpec report. This can be use to help with filtering in Chef Automate.
