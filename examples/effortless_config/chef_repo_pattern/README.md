# Effortless Config
> ## chef-repo Pattern

For more information on the a chef-repo checkout the docs [here](https://docs.chef.io/chef_repo/)

## Directory Structure
Before we build the app, this section will outline the contents of the directories that comprise it.
  * cookbooks: This directory contains the cookbooks our application will run that aren't downloaded from a supermarket
  * habitat: This directory contains the plan.sh and plan.ps1 files to build the habitat application for Effortless Config
  * policyfiles: This directory contains the chef Policyfiles that will control what Effortless Config runs and the attributes used to configure it

## Building the Effortless Config App


Now that we have prepared the Policyfile we're going to use to build our Effortless Config application, it's time to build the application itself.

The process for building this application is the same as any other habitat application, with the addition of an environment variable we set to let Habitat know which Policyfile we want to build from (we will default to using ``base.rb`` if none is specified). To build your Effortless Config application, run the following commands from the root of the repository and substitute ```<policy>``` for the Policyfile you wish to build:

(please note lines beginning ```[1][default:/src:0]#``` indicate commands run inside hab studio - this portion of the line should not be typed.)

```
$> hab studio enter
[1][default:/src:0]# env CHEF_POLICYFILE=<policy> build
```

Once the build process has successfully completed, you should see lines similar to the following at the end of the build output:

```
   config-baseline: Source Path: /src
   config-baseline: Installed Path: /hab/pkgs/jonlives/config-baseline/0.1.0/20180703121923
   config-baseline: Artifact: /src/results/jonlives-config-baseline-0.1.0-20180703121923-x86_64-linux.hart
   config-baseline: Build Report: /src/results/last_build.env
   config-baseline: SHA256 Checksum: b65874a34e23fae343e2ac235c377a62a11a3476a4a16b09b9b993a01b1865a5
   config-baseline: Blake2b Checksum: 1f5086b25e196dc29fd867e1dd6a406548aff08f19595703cd14121b1a353207
   config-baseline:
   config-baseline: I love it when a plan.sh comes together.
   config-baseline:
   config-baseline: Build time: 1m38s
```

The artifact line shows you the path to your newly-build Effortless Config artifact which can now be uploaded to bldr or exported to a docker container to run locally.

## Testing Effortless Config Locally

Once you have built a local copy of your Effortless Config application as described in the above section, you can use TestKitchen to verify that the chef-run it contains functions as you expect.

First, if you didn't build from the ```base.rb``` Policyfile you'll need to change ```.kitchen.yml``` to specify the correct package name in the ```suites``` section shown here:

```
suites:
  - name: base
    provisioner:
      arguments: ["<%= ENV['HAB_ORIGIN'] %>", "chef-base"]
    verifier:
      inspect_tests:
        test/integration/base
```

Once you've verified the package name, you can run the following commands to create a docker container running your Effortless Config application, and run the tests contained in the ```test``` directory against it:

```
$> kitchen converge
$> kitchen verify
```

## Configuring Effortless Config to report to Automate

One of the benefits of using the scaffolding is that you don't have to maintain a set of default configuration options to correctly run the chef-client. However,
there are times when you want to change the default settings. An example of this is when you have an Automate server that you want the chef-client to report to. You can set this by creating a `user.toml` file at `/hab/svc/config-baseline/` on Linux and 'C:\hab\svc\config-baseline\' on Windows. Here is an example of that `user.toml`

```
[chef_license]
acceptance = "accept-no-persist" 

[automate]
enable = true
server_url = "https://<automate_url>"
token = "<automate_token>"
```

The main benefit of use a `user.toml` is that it only overrides the configuration settings that you want and you can still recieve updates to configuration defaults from the scaffolding.

> **NOTE:** The `[chef_license]` configuration is currently required if you are using a version of the chef-client greater than 15.
