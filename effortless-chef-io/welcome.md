# Welcome to Effortless Chef Infra and Chef Compliance

Chef's Effortless Config and Effortless Audit patterns simplify deploying your Chef Infra and Chef InSpec workloads with Chef Habitat and give you observability into your running fleet with Chef Automate. The powerful combination of the full Chef technology stack working together can help you better manage your infrastructure swiftly and securely.

## When to Use Effortless

If you already use--or are thinking about using--Chef Infra or Chef InSpec to manage your operating system configuration you should look at using Effortless. Effortless uses the power of Chef Habitat to help with you Chef Infra and Chef InSpec dependency management by pulling in the cookbooks (and profiles) your cookbook (or Chef InSpec profiles) depends on and packaging them as signed artifact. It also helps by packaging the latest best practices for running Chef Infra and Chef InSpec on your systems so you don't have to worry about setting up the Chef Infra Client or the Chef InSpec client to run on your system.

## When Not to Use Effortless

* If you use Chef Infra to deploy complex applications you may not want to use the Effortless pattern.
  * Effortless is a serverless pattern and does not support Chef Infra Server. For example if you use search in your cookbooks or use chef vault for secrets management then Effortless is not going to work for those cookbooks
  * If you have complex applications you should deploy them with Chef Habitat as it has more features that better support complex applications

* If you have a bunch of nested cookbooks or policyfiles in a complex Chef Infra [roles](https://docs.chef.io/roles/) and [environments](https://docs.chef.io/environments/) setup you may not want to move to Effortless.
  * When you have a base cookbook and then a bunch of applications cookbooks that depend on that base cookbook it can become difficult to manage the build graph because a change to the base cookbook will require a build to all the application cookbooks. Complex cookbook dependencies can be difficult to manage.

## Purpose

The purpose of the Effortless pattern is to reduce the amount of code and Chef knowledge a user needs to know to be successful with Chef products.

## Quick Links

* [Chef Infra](https://github.com/chef/chef) - Chef Infra automates infrastructure configuration, ensuring every system is configured correctly and consistently.
* [Chef InSpec](https://github.com/inspec/inspec) - Chef Automate security tests, ensuring consistent standards are enforced in every environment, at every stage of development.
* [Chef Habitat](https://github.com/habitat-sh/habitat) - Codify how the application is built, how it runs, and all of its dependencies to free the app from underlying infrastructure and make updates easy.
* [Chef Automate](https://github.com/chef/automate) - Enterprise dashboard and analytics tool enabling cross-team collaboration with actionable insights for configuration and compliance and an auditable history of changes to environments.
