## v0.23.0 (2020-02-19)

#### Features

- Adds ability to specify attribute persistence in configuration #271
#### Bug Fixes

- Updates expiditor configuration for release management #272

## v0.22.1 (2020-01-28)

#### Features

#### Bug Fixes

- fix issue with automate dependency when using 1 profile. Issue #262

## v0.22.0 (2020-09-29)
required version of habitat: 1.5.0 or greater. Tested with Habitat 1.6.0

#### Features
- Add an option configuration option to select a ruby gems url to use for the chef client
- Add an option to allow Effortless Audit to specify multiple profiles

#### Bug Fixes

## v0.21.0 (2020-08-20)
Bump version of chef-cli
Remove the ffi gem pin

## v0.21.0 (2020-05-18)
required version of habitat: 1.5.0 or greater. Tested with Habitat 1.6.0

#### Features
 - Remove the Chef-DK dependency for linux
 - Add an output option to output a json file
 - Add new docs to the repo

#### Bug fixes

## v0.20.0 (2020-04-20)
required version of habitat: 1.5.0 or greater

#### Features
 - Add inputs for Effortless Audit
 - Add an insecure option for build when connecting to Automate to pull profiles
 - Update the examples folder

#### Bug fixes
 - Fix issues with kitchen in examples folder

## v0.19.0 (2020-02-27)
required version of habitat: 1.5.0 or greater

#### Features

#### Bug Fixes
 - Fix issue #206 with version check before using waivers command in InSpec on windows
 - Hard code the paths for all clients to prevent wrong client being used
 - Add Changelog.md with histroical data

#### Bug Fixes

## v0.18.0 (2020-02-13)
required version of habitat: 1.5.0 or greater

#### Features
 - Set the default client for Chef official chef builds for windows
 - Add vendor of `chef-cli` gem to windows scaffolding
 - Remove dependency on windows chef-dk
 - Add Waivers for Windows InSpec profiles

#### Bug Fixes
 - Fix pkg_dep conflict in windows scaffolding if building with newer InSpec
 - Fix data_bag issue in scaffolding-chef-infra where data_bags feature disabled

## v0.17.0 (2020-02-06)
required version of habitat: 1.5.0 or greater

#### Features
 - Change scaffolding-chef-inspec to use the official chef builds for Windows

#### Bug Fixes
 - Fix issues introduced when habitat fixed the Load-Scaffolding function in habitat 1.5.0
 - Add current channel to expeditor promotion

## v0.16.0 (2019-12-19)
required version of habitat: 0.85.0 or greater

#### Features
 - Adds ability to pin to a version of InSpec for windows scaffolding
 - Adds Waivers feature for Linux
 - Adds `environment` option for InSpec Automate reporting

#### Bug fixes
 - Add `verify_api_cert` option so chef client can report to Automate with self signed cert
 - Set license acceptance in build to `accept-no-persist`
 - Add additional testing

## v0.15.0 (2019-10-02)

#### Features

#### Bug Fixes
 - Fix issue with chef-dk and license
 - Fix issue with license in chef-client run
 - Fix issue with 0.14.0 release re-write

## v0.14.0 (2019-09-24)

#### Features
 - Refactor Chef Infra scaffolding to templates
#### Bug Fixes
 - Fix issues with `include_policy` when using single quotes
 - Make linux and windows config the same

## v0.13.0 (2019-08-01)

#### Features
 - Add ability to pull profiles from Automate
 - Add ability to use a custome cacerts package
#### Bug Fixes
 - Fix issues with `scaffold_policyfile_path` variable
 - Add testing for scaffolding-chef-infra

## v0.12.0 (2019-07-26)
not promoted to stable

## v0.11.0 (2019-07-24)

#### Features
 - Updates to the examples
 - Add scaffolding-chef-inspec for windows

#### Bug Fixes
 - Fix issues with paths on windows so they are created only if they don't exist

## v0.10.0 (2019-07-24)

#### Features

#### Bug Fixes

## v0.9.0 (2019-07-17)

#### Features

### Bug Fixes

## v0.8.0 (2019-07-16)

#### Features

### Bug Fixes

## v0.7.0 (2019-07-09)

#### Features

### Bug Fixes

## v0.6.0 (2019-07-09)

#### Features

#### Bug Fixes

## v0.5.0 (2019-07-02)

#### Features
 - change scaffolding-chef to scaffolding-chef-infra

#### Bug Fixes

## v0.5.0 (2019-06-21)

#### Features
 - move from core plans scaffolding-chef to own repo
 - deprecate core plans core/scaffolding-chef

#### Bug Fixes
---- End Changelog ----
