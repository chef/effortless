# infra-linux-hardening

This example demonstrates a minimum setup for building an Effortless package for Chef Infra. It is designed for new users in mind to use for the first time.

Files in this example are heavily annotated and commented, and include ALL overrides. In practice, if you aren't using override values, you should remove them from any configuration files, such as your `default.toml` and `plan.sh`. This is because the contributors to this project are continually updating default values that are built into the project for functionality and performance.

## Install and setup

1. [Download and install Chef Habitat](https://www.habitat.sh/docs/install-habitat/) for your workstation of choice.

2. Run `hab setup` and follow the prompts. You will need an [origin](https://www.habitat.sh/docs/using-builder/#builder-origin) and a [personal access token](https://www.habitat.sh/docs/using-builder/#upload-and-promote-packages).

The origin you create will be your personal origin for testing packages for local development. You should never use your personal origin for packages running beyond your CI system.

3. [Download and install HashiCorp Terraform](https://www.terraform.io/downloads.html) for your workstation of choice.

## Building, Promoting, and Uploading

1. Enter the directory for this example in a terminal, and enter a Habitat Studio from that directory.

```
cd ~/code/effortless/examples/infra-linux-hardening
hab studio enter
```

2. Build the plan, upload it, and promote it.

```
build
source results/last_build.env
hab pkg upload results/${pkg_artifact}
hab pkg promote ${pkg_ident} stable
```

OR

all in one command:
```
build && source results/last_build.env && hab pkg upload results/${pkg_artifact} && hab pkg promote ${pkg_ident} stable
```

## Testing

See: `terraform/README.md`

## Other Resources

Be sure to familiarize yourself with the [Chef Habitat Docs](https://habitat.sh/docs).
