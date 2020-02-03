# Linux Effortless Audit Example

This example is meant to serve as an example of testing a Habitat + Chef InSpec
Scaffolding package. It works by sharing `results/` with a Kitchen VM and then
running `test/scripts/provisioner.sh` which will:

  - Install the Habitat CLI in the Kitchen instance
  - Configure the `hab` user and group
  - Install the latest Habitat `.hart` package in `/tmp/results`
    - Don't forget to run build your package on each change!
  - Run `inspec` inside the package to converge the Kitchen instance

## Prerequisites

1. [Install Chef Habitat](https://www.habitat.sh/docs/install-habitat/)

1. Run `hab setup` and follow the prompts. The origin you create will be your
   personal origin for testing packages for local development. You should never
   use your personal origin for packages running beyond your CI system.

## Build

1. Enter the directory for this example in a terminal, and enter a Habitat Studio from that directory.

   ```
   cd ~/code/effortless/examples/effortless_audit/windows_audit_pattern
   hab studio enter
   ``` 

1. Build the plan, upload it, and promote it.

   ```
   build
   . ./results/last_build.ps1
   hab pkg upload results/${pkg_artifact}
   hab pkg promote ${pkg_ident} stable
   ```

   OR

   all in one command:
   ```
   build ; . ./results/last_build.ps1 ; hab pkg upload results/${pkg_artifact} ; hab pkg promote ${pkg_ident} stable
   ```

You now have a Habitat artifact ready to test.

### Runtime configuration

Usually, configuration for the package is already set for you in Effortless. You can override that at build time by changing the `default.toml`. But what if you require changes at run time instead, such as injecting secrets or other environment specific information?

By using a `user.toml` file, you can provide overrides for any of the values specified, at run time. You do this by putting a `user.toml` file in a directory on each node that needs the override.

- Linux path: `/hab/user/myservice/config/user.toml`
- Windows path: `C:\hab\user\myservice\config\user.toml`

`user.toml`

``` toml
interval = 3600
```

As you can see, we're only overriding specific parameters that we need. This allows us to reuse the same artifact across all environments and still provide environmental specific settings.

Read more [here](https://www.habitat.sh/docs/using-habitat/#apply-configuration-updates-to-an-individual-service).
