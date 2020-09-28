# Effortless Audit

Effortless Audit is a way to package up your InSpec profiles into a Habitat Application allowing you to easily update them promote them through channels using Habitat Builder and be deterministic about the version of Inspec you are using with your profiles.

## Introduction

Welcome to the Effortless Audit Pattern! This set of examples provides an opinionated structure and usage methodology alongside documentation on the motivations for this pattern and it's typical usage.

## Directory Stucture

This example demonstrates how to use the scaffolding to build a wrapper profile for a profile that is stored in Chef Automate. Since the profiles in automate are OS or platform specific this example is broken into two folders one for `Windows` and one for `Linux`. They are very similar and only differ in the source profiles they are wrapping.

Also included is a reference for `linux-multi-profile` which includes the `scaffold_profiles` plan configuration option, showing how to include multiple discreet profiles in a single package.

## Requirements
To configure and build a Effortless Audit application, you will need Habitat installed and configured on your development workstation. If you want to upload the package to Habitat Builder, you'll also need to have configured an origin and downloaded its keys into your local Habitat key cache.

You can find instructions on how to work with Habitat Builder [here](https://www.habitat.sh/docs/using-builder/)

## Build

To build the app you just need to copy the habitat folder into your profile folder.
> Note: You can also just run the next steps out of the linux or windows folder

Once you have completed the above steps, the process for building this application is the same as any other Habitat application:

> (please note lines beginning ```[1][default:/src:0]#``` indicate commands run inside hab studio - this portion of the line should not be typed. For Windows builds, you should cd into the `habitat-win/` directory before running the build command)

```
$> hab studio enter
[1][default:/src:0]# build
```

Once the build process has successfully completed, you should see lines similar to the following at the end of the build output:

```
   compliance: Source Path: /src
   compliance: Installed Path: /hab/pkgs/jonlives/compliance/0.1.0/20190116131348
   compliance: Artifact: /src/results/jonlives-compliance-0.1.0-20190116131348-x86_64-linux.hart
   compliance: Build Report: /src/results/last_build.env
   compliance: SHA256 Checksum: a5abe6dde45baf4db5e4441d3bd6defa2f77fd372c634aa366c431ce854c86b4
   compliance: Blake2b Checksum: e1074c38b79ac3d61f46d7db595ef0bf0567b6d6e8818c1f86d6c0c153496a52
   compliance:
   compliance: I love it when a plan.sh comes together.
   compliance:
   compliance: Build time: 0m21s
```
The artifact line shows you the path to your newly-build Effortless Audit artifact which can now be uploaded to Habitat Builder or exported to a Docker container to run locally.
