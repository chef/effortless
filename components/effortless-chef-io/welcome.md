# Welcome to the Chef Effortless Patterns

The Effortless Pattern is a way to better manage Chef Infra and Chef InSpec workloads using Chef Habitat and visualizing your fleet using Chef Automate. We believe that each of these technologies working together can help you better manage your infrastructure.

## Who Should use Effortless
If you use chef or InSpec to manage your operating system configs you should look at using Effortless. Effortless uses the power of Habitat to help with you Chef Infra and Chef InSpec dependency management by pulling in the coookbooks (and profiles) your cookbook (or InSpec profiles) depends on and packaging them as signed artifact. It also helps by packaging the lastest best practices for running Chef Infra and Chef InSpec on your systems so you don't have to worry about setting up the chef-client or the InSpec client to run on your system.

## When is using Effortless not the best approach

* If you use Chef Infra to deploy complex applications you may not want to use the Effortless pattern. 
  * Effortless currently doesn't support situations that require a Chef Infra Server. For example if you use search in your cookbooks or use chef vault for secrets management then Effortless is not going to work for those cookbooks
  * If you have complex applications you should deploy them with Habitat as it has more features that better support complex applications

* If you have a bunch of nested cookbooks or policfiles in a complex [Chef Roles](https://docs.chef.io/roles/) and [Chef Environments](https://docs.chef.io/environments/) setup you may not want to move to effortless.
  * When you have a base cookbook and then a bunch of applications cookbooks that depend on that base cookbook it can become difficult to manage the build graph because a change to the base cookbook will require a build to all the application cookbooks. This can quickly be difficult to manage.

## Purpose
The purpose of the Effortless pattern is to reduce the amount of code and Chef knowledge a user needs in order to be successful with Chef products.

## Quick Links

- [Chef Infra](https://github.com/chef/chef) - Chef Infra automates infrastructure configuration, ensuring every system is configured correctly and consistently.

- [Chef InSpec](https://github.com/inspec/inspec) - Automate security tests, ensuring consistent standards are enforced in every environment, at every stage of development.

- [Chef Habitat](https://github.com/habitat-sh/habitat) - Codify how the application is built, how it runs, and all of its dependencies to free the app from underlying infrastructure and make updates easy.

- [Chef Automate](https://github.com/chef/automate) - Enterprise dashboard and analytics tool enabling cross-team collaboration with actionable insights for configuration and compliance and an auditable history of changes to environments.
